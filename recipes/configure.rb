include_recipe "rtnginx-ssl::package"

service "nginx"

# Site disable default

template "/etc/nginx/nginx.conf" do
  source node['nginx']['config']['main']
  mode 0644
  notifies :run, "execute[test-nginx-config]", :immediately
end

logrotate_app "nginx" do
  cookbook  'logrotate'
  path ['/var/log/nginx/*.log']
  options   ['missingok', 'delaycompress', 'notifempty']
  frequency 'daily'
  rotate    2
  create    '644 root adm'
  postrotate '[ ! -f /opt/nginx/logs/nginx.pid ] || kill -USR1 `cat /opt/nginx/logs/nginx.pid`'
end

execute "test-nginx-config" do
  command "nginx -t"
  action :nothing
  notifies :reload, resources(:service => "nginx"), :immediately
end

