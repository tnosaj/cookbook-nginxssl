def whyrun_supported?
  true
end


# ONLY NEEDED IF ITS NATIVE RUBY!
#def load_current_resource
#  @current_resource = Chef::Resource::RtnginxSsl.new(new_resource.name)
#  @current_resource
#end
use_inline_resources
action :configure do
  Chef::Log.info "JAT - Configuring: "+new_resource.name
  t = template node['nginx']['config']['file'] do
    if new_resource.template
      source new_resource.template
    else
      source node['nginx']['config']['template']
    end
    #variables({    })
  end
  new_resource.updated_by_last_action(t.updated_by_last_action?)
end

action :test do
  execute "test-nginx-config" do
    command "nginx -t"
  end
  new_resource.updated_by_last_action(true)
end

action :reload do
  Chef::Log.info "JAT - RELOADING: "+new_resource.name
  service "nginx"
  e = execute "test-nginx-config" do
    command "nginx -t"
    notifies :reload, resources(:service => "nginx"), :immediately
  end
  new_resource.updated_by_last_action(e.updated_by_last_action?)
end

