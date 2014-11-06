template "/opt/nginx/html/50x.html" do
  source "50x.html.erb"
  mode 0644
  owner "root"
  group "root"
  variables({
     :hostname => node[:fqdn]
  })
end
