data "aws_availability_zones" "azs" {
  state = "available"
  # exclut les Local Zones / Wavelength, que EKS ne supporte pas
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
