global
  log stdout format raw local0 warning
  maxconn 8192
  user haproxy
  group haproxy

defaults
  log global
  mode tcp
  option tcplog
  option dontlognull
  option dontlog-normal
  timeout connect 5000
  timeout check 5000
  timeout client 30000
  timeout server 30000

resolvers default
  parse-resolv-conf

%{ for name, pm in port_mappings }
listen ${name} 
  bind *:${pm.proxy_port}
  server ${name}-svr ${pm.backend_host}:${pm.backend_port} check resolvers default resolve-prefer ipv4
%{ endfor }