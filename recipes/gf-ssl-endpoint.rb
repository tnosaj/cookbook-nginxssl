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
  notifies :reload, resources(:service => "nginx"), :immediately
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  mode 0644
  notifies :run, "execute[test-nginx-config]", :immediately
  notifies :reload, resources(:service => "nginx"), :immediately
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

data_bag_item('system','ssl')['ssl-gf']['sites'].each do |site,data|
  alias_name = nil
  if data['alias'].nil? 
  else
    if data['alias'].respond_to? :each
      alias_name = data['alias'].join("." + data['domain']+" ")+"."+data['domain']
    else
      alias_name = "#{data['alias']}.#{data['domain']}"
    end
  end
  if data_bag_item('system', site)['haproxy']['frontend_port']
    cluster_port = data_bag_item('system', site)['haproxy']['frontend_port']
  end
  if data['subdomain']
    site = "#{data['subdomain']}.#{data['domain']}"
  else
    site = "#{site}.#{data['domain']}"
  end
  if data['http']
    template "/etc/nginx/sites-available/#{site}" do
      source "ssl-gf/runtastic.com.erb"
      mode 0644
      variables(
        :site => site,
        :cluster_ip => data['backend_override'] ? data_bag_item('system', 'haproxy')[data['backend_override']]['cluster_ip'] : cluster_ip,
        :cluster_port => cluster_port,
        :alias => alias_name
      )
      notifies :run, "execute[test-nginx-config]", :delayed
    end
    link "/etc/nginx/sites-enabled/#{site}" do
      to "/etc/nginx/sites-available/#{site}"
      notifies :run, "execute[test-nginx-config]", :delayed
    end
  end
  if data['https']
    template "/etc/nginx/sites-available/#{site}-ssl" do
      source "ssl-gf/runtastic.com-ssl.erb"
      mode 0644
      variables(
        :site => site,
        :cluster_ip => data['backend_override'] ? data_bag_item('system', 'haproxy')[data['backend_override']]['cluster_ip'] : cluster_ip,
        :cluster_port => cluster_port,
        :alias => alias_name
      )
      notifies :run, "execute[test-nginx-config]", :delayed
    end
    link "/etc/nginx/sites-enabled/#{site}-ssl" do
      to "/etc/nginx/sites-available/#{site}-ssl"
      notifies :run, "execute[test-nginx-config]", :delayed
    end
  end
end

execute "test-nginx-config" do
  command "nginx -t"
  action :nothing
end

[80,443].each do |port|
  firewall_rule "Public to #{port}" do
    port port
    action :allow
  end
end

