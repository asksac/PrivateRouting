global
  log stdout format raw local0 info
  maxconn 4096
  user haproxy
  group haproxy

defaults
  log global
  mode tcp
  timeout connect 60s
  timeout client 600s
  timeout server 1h

%{ for name, pm in port_mappings }
listen ${name}_fe: 
  bind *:${pm.proxy_port}
  server ${name}_be ${pm.backend_host}:${pm.backend_port}
%{ endfor }