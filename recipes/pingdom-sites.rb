#
# Get haproxy's clusterip
#
cluster_ip = nil
cluster_port = nil

data_bag_item('system','pingdom')['sites'].each do |site,data|
  cluster_ip = data_bag_item('system', 'haproxy')[data['backend_override']]['cluster_ip']
  cluster_port = data_bag_item('system',site)['haproxy']['frontend_port']
  if data['http']
    template "/etc/nginx/sites-available/#{site}" do
      source "ssl-service/service.runtastic.com.erb"
      mode 0644
      variables(
        :site => "pingdom-#{site}.runtastic.com",
        :cluster_ip => cluster_ip,
        :cluster_port => cluster_port,
        :allows => data_bag_item('system','pingdom')['pingdom_network']['ips']
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
        :site => "pingdom-#{site}.runtastic.com",
        :cluster_ip => cluster_ip,
        :cluster_port => cluster_port,
        :allows => data_bag_item('system','pingdom')['pingdom_network']['ips']
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
