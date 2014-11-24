include_recipe "rtnginxssl::package"

rtnginxssl_config "instance" 

rtnginxssl_config "myinstance" do
  action :configure
  notifies :reload, "rtnginxssl_config[instance]", :immediately
end

# Site disable default

logrotate_app "nginx" do
  cookbook  'logrotate'
  path ["#{node['nginx']['config']['logdir']}*.log"]
  options   ['missingok','compress','delaycompress','notifempty','sharedscripts']
  frequency 'daily'
  rotate    2
  create    '0640 www-data adm'
  postrotate "[ ! -f #{node['nginx']['config']['pid']} ] || kill -USR1 `cat #{node['nginx']['config']['pid']}`]"
end
