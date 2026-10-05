#!/usr/bin/env bash
# Projet 21 — ressources préalables en CLI : paramètres SSM, bucket, rôles IAM, instance.
# Le projet CodeBuild, l'application CodeDeploy et le pipeline se créent dans la console (étapes 3, 5, 6).
# Usage : DOCKERHUB_USER=... DOCKERHUB_TOKEN=... TMDB_KEY=... MY_IP=1.2.3.4 KEY_NAME=io-key ./setup.sh
set -euo pipefail
REGION="${REGION:-eu-west-3}"
: "${DOCKERHUB_USER:?DOCKERHUB_USER manquant}" "${DOCKERHUB_TOKEN:?DOCKERHUB_TOKEN manquant}"
: "${TMDB_KEY:?TMDB_KEY manquant}" "${MY_IP:?MY_IP manquant}" "${KEY_NAME:?KEY_NAME manquant}"
ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"
export AWS_DEFAULT_REGION="$REGION"

# 1. Secrets dans Parameter Store (--overwrite : rejouable)
aws ssm put-parameter --name /myapp/docker-credentials/username --type String       --value "$DOCKERHUB_USER"  --overwrite
aws ssm put-parameter --name /myapp/docker-credentials/password --type SecureString --value "$DOCKERHUB_TOKEN" --overwrite
aws ssm put-parameter --name /myapp/api/key                     --type SecureString --value "$TMDB_KEY"        --overwrite

# 2. Politique à attacher au rôle CodeBuild (une fois le projet créé dans la console)
cat > /tmp/codebuild-ssm.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["ssm:GetParameters"],
    "Resource": "arn:aws:ssm:${REGION}:${ACCOUNT}:parameter/myapp/*"
  }]
}
JSON
echo "Après création du projet CodeBuild :"
echo "  aws iam put-role-policy --role-name codebuild-netflix-build-service-role --policy-name read-myapp-params --policy-document file:///tmp/codebuild-ssm.json"

# 3. Rôle de l'instance (lecture des artefacts S3 + SSM)
cat > /tmp/ec2-trust.json <<'JSON'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}
JSON
aws iam create-role --role-name io-21-ec2-role --assume-role-policy-document file:///tmp/ec2-trust.json >/dev/null 2>&1 || true
aws iam attach-role-policy --role-name io-21-ec2-role --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy
aws iam attach-role-policy --role-name io-21-ec2-role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam create-instance-profile --instance-profile-name io-21-ec2-role >/dev/null 2>&1 || true
aws iam add-role-to-instance-profile --instance-profile-name io-21-ec2-role --role-name io-21-ec2-role 2>/dev/null || true

# 4. Rôle de service CodeDeploy
cat > /tmp/cd-trust.json <<'JSON'
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"codedeploy.amazonaws.com"},"Action":"sts:AssumeRole"}]}
JSON
aws iam create-role --role-name io-21-codedeploy-role --assume-role-policy-document file:///tmp/cd-trust.json >/dev/null 2>&1 || true
aws iam attach-role-policy --role-name io-21-codedeploy-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole

# 5. Security group + instance Ubuntu 24.04 taguée Name=netflix-codedeploy
VPC_ID="$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)"
SG_ID="$(aws ec2 create-security-group --group-name io-21-sg --description "Projet 21" --vpc-id "$VPC_ID" --query GroupId --output text 2>/dev/null \
  || aws ec2 describe-security-groups --filters Name=group-name,Values=io-21-sg --query 'SecurityGroups[0].GroupId' --output text)"
for port in 22 8080; do
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port "$port" --cidr "${MY_IP}/32" 2>/dev/null || true
done
AMI="$(aws ssm get-parameter --name /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id --query Parameter.Value --output text)"
sleep 10   # propagation du profil d'instance
aws ec2 run-instances --image-id "$AMI" --instance-type t3.micro --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" --iam-instance-profile Name=io-21-ec2-role \
  --metadata-options HttpTokens=required \
  --user-data "file://$(dirname "$0")/install-codedeploy-agent.sh" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=netflix-codedeploy}]' \
  --query 'Instances[0].InstanceId' --output text
