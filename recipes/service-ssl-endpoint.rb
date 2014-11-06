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

#
# Get haproxy's clusterip
#
cluster_ip = nil
if data_bag_item('system', 'haproxy')[node['haproxy']['proxy']]['override_cluster_ip']
  cluster_ip = data_bag_item('system', 'haproxy')[node['haproxy']['proxy']]['override_cluster_ip']
else
  cluster_ip = data_bag_item('system', 'haproxy')[node['haproxy']['proxy']]['cluster_ip']
end
cluster_port = nil
if data_bag_item('system', "haproxy")["#{node['haproxy']['proxy']}"]['child']
  cluster_port = data_bag_item('system', "#{data_bag_item('system', "haproxy")["#{node['haproxy']['proxy']}"]['child']}")['haproxy']['frontend_port']
else
  cluster_port = data_bag_item('system', "haproxy")['default_frontend_port']
end

data_bag_item('system','ssl')['ssl-service']['sites'].each do |site,data|
  #
  # Try to grab appropriate backend from service::databag::haproxy
  #
  gzip = data['gzip'].nil? ? true : data['gzip']
  puts "JAT: #{ gzip } - #{data['gzip']} -#{data["gzip"]}-- #{data.to_s}"
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
      source "ssl-service/service.runtastic.com.erb"
      mode 0644
      variables(
        :site => site,
        :cluster_ip => data['backend_override'] ? data_bag_item('system', 'haproxy')[data['backend_override']]['cluster_ip'] : cluster_ip,
        :cluster_port => cluster_port,
        :overrides => data['overrides'],
        :rewritehttp => !!data['rewritehttp'],
        :gzip => gzip
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
      source "ssl-service/service.runtastic.com-ssl.erb"
      mode 0644
      variables(
        :site => site,
        :cluster_ip => data['backend_override'] ? data_bag_item('system', 'haproxy')[data['backend_override']]['cluster_ip'] : cluster_ip,
        :cluster_port => cluster_port,
        :overrides => data['overrides'],
        :gzip => gzip
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
  notifies :reload, resources(:service => "nginx"), :immediately
end

[80,443].each do |port|
  firewall_rule "Public to #{port}" do
    port port
    action :allow
  end
end
