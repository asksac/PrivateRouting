provider "aws" {
  profile = var.aws_profile
  region = var.aws_region
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project     = "PrivateRouting"
    Application = "AWS-HSBC-Private-Routing"
    Environment = "dev"
  }
}
