default['nginx']['ssl']['recipe'] = []
default['nginx']['config']['template'] = "nginx.conf.erb"
default['nginx']['config']['dir'] = "/etc/nginx/"
default['nginx']['config']['file'] = node['nginx']['config']['dir']+"nginx.conf"
default['nginx']['config']['sites_available'] = node['nginx']['config']['dir']+"sites-available/"
default['nginx']['config']['sites_enabled'] = node['nginx']['config']['dir']+"sites-enabled/"
default['nginx']['config']['pid'] = "/run/nginx.pid"
default['nginx']['config']['logdir'] = "/var/log/nginx/"
default['nginx']['server']['default'] = {   
  "keepalive_timeout" => "60",
  "access_log" => "off",
  "client_max_body_size" => "10M"
}
