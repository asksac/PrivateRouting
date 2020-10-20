global
  log stdout format short local0 warning
  maxconn 4096
  user haproxy
  group haproxy

defaults
  log global
  mode tcp
  option tcplog
  option dontlognull
  timeout connect 5000
  timeout check 5000
  timeout client 30000
  timeout server 30000

%{ for name, pm in port_mappings }
listen ${name}_fe: 
  bind *:${pm.proxy_port}
  server ${name}_be ${pm.backend_host}:${pm.backend_port} check
%{ endfor }