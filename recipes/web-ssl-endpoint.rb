include_recipe "ssl-certs"
include_recipe "nginx::nginx-install-from-package"
service "nginx" do
  supports :restart => true, :reload => true
end


domains = data_bag_item('system', 'ssl')['ssl-web']['rewrite_sites']

file "/etc/nginx/sites-enabled/default" do
  action :delete
  only_if do
    File.exists?("/etc/nginx/sites-enabled/default")
  end
  notifies :reload, resources(:service => "nginx"), :immediately
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  mode 0644
  notifies :run, "execute[test-nginx-config]", :immediately
end

#remote_directory "/etc/nginx/sites-available/" do
#  source "nginx/web-sites-available"
#  files_mode "0755"
#end

domains.each do |domain|
  template "/etc/nginx/sites-available/#{domain}" do
    source "ssl-web/rewrite_site.erb"
    mode 0644
    variables(
      :domain => domain
    )
    notifies :run, "execute[test-nginx-config]", :delayed
  end
  link "/etc/nginx/sites-enabled/#{domain}" do
    to "/etc/nginx/sites-available/#{domain}"
    notifies :run, "execute[test-nginx-config]", :delayed
  end
end

#
# Get haproxy's clusterip
#
cluster_ip = data_bag_item('system', 'haproxy')[node['haproxy']['proxy']]['cluster_ip']
cluster_port = nil
if data_bag_item('system', "haproxy")["#{node['haproxy']['proxy']}"]['child']
  cluster_port = data_bag_item('system', "#{data_bag_item('system', "haproxy")["#{node['haproxy']['proxy']}"]['child']}")['haproxy']['frontend_port']
else
  cluster_port = data_bag_item('system', "haproxy")['default_frontend_port']
end

# Get shop backend url
shop_backend_url = data_bag_item('system', 'ssl')['ssl-web']['shop_backend_url']
shop_management_url = data_bag_item('system', 'ssl')['ssl-web']['shop_management_url']
testshop_backend_url = data_bag_item('system', 'ssl')['ssl-web']['testshop_backend_url']
shop_mpay_backend_url = data_bag_item('system', 'ssl')['ssl-web']['shop_mpay_backend_url']
files_backend_url = data_bag_item('system', 'ssl')['ssl-web']['files_backend_url']

["runtastic.com","runtastic.com-ssl"].each do |site|
  template "/etc/nginx/sites-available/#{site}" do
    source "ssl-web/#{site}.erb"
    mode 0644
    variables(
      :cluster_ip => cluster_ip,
      :cluster_port => cluster_port,
      :shop_backend_url => shop_backend_url,
      :shop_management_url => shop_management_url,
      :testshop_backend_url => testshop_backend_url,
      :shop_mpay_backend_url => shop_mpay_backend_url,
      :files_backend_url => files_backend_url
    )
    notifies :run, "execute[test-nginx-config]", :delayed
  end
  link "/etc/nginx/sites-enabled/#{site}" do
    to "/etc/nginx/sites-available/#{site}"
    notifies :run, "execute[test-nginx-config]", :delayed
  end
end

execute "test-nginx-config" do
  command "nginx -t"
  action :nothing
  notifies :reload, resources(:service => "nginx"), :immediately
end

[80,443].each do |port|
  firewall_rule "Public to #{port}" do
    port port
    action :allow
  end
end
