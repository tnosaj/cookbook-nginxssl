include_recipe "ssl-certs"
include_recipe "nginx::nginx-install-from-package"
service "nginx" do
  supports :restart => true, :reload => true
end

file "/etc/nginx/sites-enabled/default" do
  action :delete
  only_if do
    File.exists?("/etc/nginx/sites-enabled/default")
  end
  notifies :reload, resources(:service => "nginx"), :delayed
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  mode 0644
  notifies :run, "execute[test-nginx-config]", :delayed
end

cookbook_file "/etc/nginx/sites-available/grid.runtastic.com" do
  source "nginx/service-sites-available/grid.runtastic.com"
  mode 0644
  notifies :run, "execute[test-nginx-config]", :delayed
end
link "/etc/nginx/sites-enabled/grid.runtastic.com" do
  to "/etc/nginx/sites-available/grid.runtastic.com"
  notifies :run, "execute[test-nginx-config]", :delayed
end
cookbook_file "/etc/nginx/sites-available/grid.runtastic.com-ssl" do
  source "nginx/service-sites-available/grid.runtastic.com-ssl"
  mode 0644
  notifies :run, "execute[test-nginx-config]", :delayed
end
link "/etc/nginx/sites-enabled/grid.runtastic.com-ssl" do
  to "/etc/nginx/sites-available/grid.runtastic.com-ssl"
  notifies :run, "execute[test-nginx-config]", :delayed
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
