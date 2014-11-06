include_recipe "apt"

# add the Nginx PPA; grab key from keyserver
apt_repository "nginx" do
  uri "http://ppa.launchpad.net/nginx/stable/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "C300EE8C"
end

packages=["nginx"]

packages.each do |pack|
  package pack do
    action :install
  end
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
