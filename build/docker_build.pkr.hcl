variable "profile" {}
variable "region" {
  default = "us-east-1"
}
variable "app_name" {}
variable "proxy_image_repo" {}
variable "proxy_image_tag" {}

source "docker" "ecs_haproxy" {
  image = "haproxy:2.2.4"
  commit = true
  changes = [
    "ENTRYPOINT [\"/docker-entrypoint-override.sh\"]", 
    "CMD [\"haproxy\", \"-db\", \"-d\", \"-f\", \"/usr/local/etc/haproxy/ecs_haproxy.cfg\"]"
  ] 
}

build {
  sources = [
    "source.docker.ecs_haproxy"
  ]

  provisioner "file" {
    source = "./docker-entrypoint-override.sh"
    destination = "/docker-entrypoint-override.sh"
  }

  # add following line to inline block for troubleshooting only: 
  # "apt-get update && apt-get install -y curl vim net-tools procps && apt-get clean" 

  provisioner "shell" {
    inline = [
      "chmod +x /docker-entrypoint-override.sh", 
      "groupadd --gid 1000 haproxy && useradd --uid 1000 --gid haproxy --shell /bin/sh haproxy", 
      "ulimit -n 10000", 
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "${var.proxy_image_repo}"
      tags = [ "${var.proxy_image_tag}" ]
    }

    post-processor "docker-push" {
      ecr_login = true
      login_server = "https://${var.proxy_image_repo}"
    }
  }
}

