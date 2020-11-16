locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Application = var.app_name
    Project     = "${var.app_name} - Demo and Test"
    Environment = var.aws_env
  }

  # Add '6' listen ports for websvr (can go upto 50 - 4 = 46)
  websvr_http_ports     = [ for p in range(0, 6): (8080 + p)]

  # Add new port mappings for each websvr listen port 
  new_port_mappings = [ 
    for p in local.websvr_http_ports: {
      name              = "nginx${p}-http"
      description       = "http port to websvr"
      backend_host      = module.test_websvr.alias_dns
      backend_port      = p 
      nlb_port          = p
      proxy_port        = p
    }
  ] 

  test_websvr_ports = {
    server_http_ports   = [ 80 ]
    server_https_ports  = [ 443 ]
    server_ssh_ports    = [ 22 ]
    nginx_http_ports    = local.websvr_http_ports # [ 8080, 8081, 8082, 8083, 8084, 8085 ]
    nginx_https_ports   = [ 8443 ] # [ 8443, 8444, 8445, 8446, 8447 ]
  }

  ecs_proxy_config = {
    service_name = "myproxy"
    port_mappings = concat([
      {
        name          = "websvr-ssh"
        description   = "ssh connnection to websvr"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 22
        nlb_port      = 7022
        proxy_port    = 7022
      }, 
      {
        name          = "websvr-http"
        description   = "http connnection to websvr"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 80
        nlb_port      = 7080
        proxy_port    = 7080
      }, 
      {
        name          = "websvr-https"
        description   = "https connnection to websvr"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 443
        nlb_port      = 7443
        proxy_port    = 7443
      }, 
      {
        name          = "nginx1-https"
        description   = "https connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8443
        nlb_port      = 9443
        proxy_port    = 9443
      }, 
    ], local.new_port_mappings)
  }

  ec2_proxy_config = {
    service_name = "myec2proxy"
    port_mappings = concat([
      {
        name          = "websvr-ssh"
        description   = "ssh connnection to websvr"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 22
        nlb_port      = 7022
        proxy_port    = 7022
      }, 
      {
        name          = "websvr-http"
        description   = "http connnection to websvr"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 80
        nlb_port      = 7080
        proxy_port    = 7080
      }, 
      {
        name          = "websvr-https"
        description   = "https connnection to websvr"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 443
        nlb_port      = 7443
        proxy_port    = 7443
      }, 
      {
        name          = "nginx1-https"
        description   = "https connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8443
        nlb_port      = 9443
        proxy_port    = 9443
      }
    ], local.new_port_mappings)
  }
}
