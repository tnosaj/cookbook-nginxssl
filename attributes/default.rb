default['nginx']['ssl']['recipe'] = []
default['nginx']['config']['template'] = "nginx.conf.erb"
default['nginx']['config']['dir'] = "/etc/nginx/"
default['nginx']['config']['file'] = node['nginx']['config']['dir']+"nginx.conf"
default['nginx']['config']['sites_available'] = node['nginx']['config']['dir']+"sites-available/"
default['nginx']['config']['sites_enabled'] = node['nginx']['config']['dir']+"sites-enabled/"
default['nginx']['config']['pid'] = "/run/nginx.pid"
default['nginx']['config']['logdir'] = "/var/log/nginx/"
default['nginx']['config']['ssl']['example.com'] = {
  "ssl_certificate" => "/etc/ssl/certs/ssl-cert-snakeoil.pem",
  "ssl_certificate_key" => "/etc/ssl/private/ssl-cert-snakeoil.key",
  "ssl_protocols" => "TLSv1 TLSv1.1 TLSv1.2",
  "ssl_ciphers" => "RC4:HIGH:!aNULL:!MD5",
  "ssl_prefer_server_ciphers" => "on"
}

default['nginx']['server']['default'] = {   
  "keepalive_timeout" => "60",
  "access_log" => "off",
  "client_max_body_size" => "10M"
}
