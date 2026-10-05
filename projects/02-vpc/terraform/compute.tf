data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

locals {
  web_ami = var.golden_ami_id != "" ? var.golden_ami_id : data.aws_ami.al2023.id
}

# ---------------- Bastion ----------------
resource "aws_security_group" "bastion" {
  name   = "io-bastion-sg"
  vpc_id = aws_vpc.bastion.id
  ingress {
    description = "SSH depuis mon IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.bastion_public_a.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.key_name
  tags                   = { Name = "io-bastion" }
}

resource "aws_eip" "bastion" {
  domain   = "vpc"
  instance = aws_instance.bastion.id
  tags     = { Name = "io-bastion-eip" }
}

# ---------------- Configuration dans S3 ----------------
resource "aws_s3_bucket" "config" {
  bucket        = var.config_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket                  = aws_s3_bucket.config.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "app_env" {
  bucket  = aws_s3_bucket.config.id
  key     = "app.env"
  content = "APP_ENV=production\nAPP_MESSAGE=Bienvenue sur le site du projet 02\n"
}

# ---------------- Rôle IAM des serveurs web (moindre privilège) ----------------
resource "aws_iam_role" "web" {
  name = "io-web-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "web" {
  for_each   = toset(["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"])
  role       = aws_iam_role.web.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "read_config" {
  name = "read-io-02-config"
  role = aws_iam_role.web.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "s3:GetObject", Resource = "${aws_s3_bucket.config.arn}/*" },
      { Effect = "Allow", Action = "s3:ListBucket", Resource = aws_s3_bucket.config.arn }
    ]
  })
}

resource "aws_iam_instance_profile" "web" {
  name = "io-web-profile"
  role = aws_iam_role.web.name
}

# ---------------- Load balancer ----------------
resource "aws_security_group" "nlb" {
  name   = "io-nlb-sg"
  vpc_id = aws_vpc.app.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name   = "io-web-sg"
  vpc_id = aws_vpc.app.id
  ingress {
    description     = "HTTP depuis le NLB uniquement"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nlb.id]
  }
  ingress {
    description = "SSH depuis le subnet du bastion (via le Transit Gateway)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.bastion_public_a.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "web" {
  name               = "io-web-nlb"
  load_balancer_type = "network"
  internal           = false
  subnets            = [for s in aws_subnet.app_public : s.id]
  security_groups    = [aws_security_group.nlb.id]
}

resource "aws_lb_target_group" "web" {
  name     = "io-web-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.app.id
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ---------------- Launch Template + Auto Scaling ----------------
resource "aws_launch_template" "web" {
  name                   = "io-web-lt"
  image_id               = local.web_ami
  instance_type          = "t3.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile { arn = aws_iam_instance_profile.web.arn }
  metadata_options {
    http_tokens = "required" # IMDSv2 uniquement
  }
  user_data = base64encode(templatefile("${path.module}/../user-data.sh", {
    bucket       = aws_s3_bucket.config.id
    repo_url     = var.repo_url
    install_pkgs = var.golden_ami_id == "" ? "true" : "false"
  }))
}

resource "aws_autoscaling_group" "web" {
  name                      = "io-web-asg"
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  vpc_zone_identifier       = [for s in aws_subnet.app_private : s.id]
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "io-web"
    propagate_at_launch = true
  }
  depends_on = [aws_route_table_association.app_private, aws_nat_gateway.app]
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "cpu-50"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification { predefined_metric_type = "ASGAverageCPUUtilization" }
    target_value = 50
  }
}

# ---------------- DNS (optionnel) ----------------
data "aws_route53_zone" "zone" {
  count = var.domain_zone == "" ? 0 : 1
  name  = var.domain_zone
}

resource "aws_route53_record" "site" {
  count   = var.domain_zone == "" ? 0 : 1
  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "projet02.${var.domain_zone}"
  type    = "A"
  alias {
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
    evaluate_target_health = true
  }
}
