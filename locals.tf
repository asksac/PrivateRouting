locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project     = "PrivateRouting"
    Application = "AWS-OnPrem-Private-Routing"
    Environment = "dev"
  }

  test_websvr_ports = {
    server_http_ports   = [ 80 ]
    server_https_ports  = [ 443 ]
    server_ssh_ports    = [ 22 ]
    nginx_http_ports    = [ 8080, 8081, 8082, 8083, 8084 ]
    nginx_https_ports   = [ 8443, 8444, 8445, 8446, 8447 ]
  }

  ecs_proxy_config = {
    service_name = "myproxy"
    port_mappings = [
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
        name          = "nginx1-http"
        description   = "http connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8080
        nlb_port      = 9080
        proxy_port    = 9080
      }, 
      {
        name          = "nginx1-https"
        description   = "https connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8443
        nlb_port      = 9443
        proxy_port    = 9443
      }, 
      {
        name          = "nginx2-http"
        description   = "2nd http connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8081
        nlb_port      = 9081
        proxy_port    = 9081
      }, 
      {
        name          = "nginx2-https"
        description   = "2nd https connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8444
        nlb_port      = 9444
        proxy_port    = 9444
      }, 
      {
        name          = "nginx3-http"
        description   = "3rd http connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8082
        nlb_port      = 9082
        proxy_port    = 9082
      }, 
      {
        name          = "nginx3-https"
        description   = "3rd https connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8445
        nlb_port      = 9445
        proxy_port    = 9445
      }, 
    ]
  }

  ec2_proxy_config = {
    service_name = "myec2proxy"
    port_mappings = [
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
        name          = "nginx1-http"
        description   = "http connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8080
        nlb_port      = 9080
        proxy_port    = 9080
      }, 
      {
        name          = "nginx1-https"
        description   = "https connnection to nginx"
        backend_host  = module.test_websvr.alias_dns
        backend_port  = 8443
        nlb_port      = 9443
        proxy_port    = 9443
      }
    ]
  }
}
