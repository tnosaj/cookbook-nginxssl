include_recipe "nginxssl::package"

nginxssl_config "instance" 

nginxssl_config "myinstance" do
  action :configure
  notifies :reload, "nginxssl_config[instance]", :delayed
end

logrotate_app "nginx" do
  cookbook  'logrotate'
  path ["#{node['nginx']['config']['logdir']}*.log"]
  options   ['missingok','compress','delaycompress','notifempty','sharedscripts']
  frequency 'daily'
  rotate    2
  create    '0640 www-data adm'
  postrotate "[ ! -f #{node['nginx']['config']['pid']} ] || kill -USR1 `cat #{node['nginx']['config']['pid']}`]"
end
