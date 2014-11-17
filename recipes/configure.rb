include_recipe "rtnginxssl::package"

rtnginxssl_config "myinstance" do
  action :configure
  notifies :reload, "rtnginxssl_config[myinstance]", :immediately
end

# Site disable default

logrotate_app "nginx" do
  cookbook  'logrotate'
  path ["#{node['nginx']['config']['logdir']}*.log"]
  options   ['missingok', 'delaycompress', 'notifempty']
  frequency 'daily'
  rotate    2
  create    '644 root adm'
  postrotate "[ ! -f #{node['nginx']['config']['pid']} ] || kill -USR1 `cat #{node['nginx']['config']['pid']}`"
end
