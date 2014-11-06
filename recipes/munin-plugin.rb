include_recipe "munin::client"

service "munin-node"


cookbook_file "/usr/share/munin/plugins/nginx_combined" do
        source "nginx_combined"
        mode 0755
        action :create
end

cookbook_file "/usr/share/munin/plugins/nginx_memory" do
        source "nginx_memory"
        mode 0755
        action :create
end

link "/etc/munin/plugins/nginx_combined" do
  to "/usr/share/munin/plugins/nginx_combined"
  notifies :restart, "service[munin-node]", :immediately
end

link "/etc/munin/plugins/nginx_status" do
  to "/usr/share/munin/plugins/nginx_status"
  notifies :restart, "service[munin-node]", :immediately
end

link "/etc/munin/plugins/nginx_request" do
  to "/usr/share/munin/plugins/nginx_request"
  notifies :restart, "service[munin-node]", :immediately
end

link "/etc/munin/plugins/nginx_memory" do
  to "/usr/share/munin/plugins/nginx_memory"
  notifies :restart, "service[munin-node]", :immediately
end


