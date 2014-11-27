include_recipe "rtnginxssl::package"

rtnginxssl_config "instance" 

rtnginxssl_config "myinstance" do
  action :configure
  notifies :reload, "rtnginxssl_config[instance]", :immediately
end

# Site disable default
www_loc = {
  "default" => {
    "base" => "/", 
    "options" => {
      "proxy_pass" => "http://123.123.123.123:80",
      "proxy_set_header" => {
        "Host" => "$host",
        "x-forwarded-for" => "$remote_addr"
      }
    }
  }
}
rtnginxssl_site "www" do
  action :enable
  subdomain "www"
  servername ["www.runtastic.com","runtastic.com"]
  locations www_loc
  notifies :reload, "rtnginxssl_config[instance]", :immediately
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
