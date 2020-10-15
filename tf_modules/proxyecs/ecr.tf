resource "aws_ecr_repository" "registry" {
  name                  = "${var.app_shortcode}-registry"
  image_tag_mutability  = "MUTABLE"

  image_scanning_configuration {
    scan_on_push        = true
  }
  tags                  = var.common_tags
}

