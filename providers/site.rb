def whyrun_supported?
  true
end

action :enable do
  if 
  template "#{node['nginx']['sites_available']}/"+new_resource.name do
    if new_resource.onlyrewrite
      source 'rewrite_site.conf.erb'
    else
      source new_resource.template
    end
    variables({
      :working_dir => new_resource.working_dir
    })
  end
  new_resource.updated_by_last_action(true) 
  enable(new_resource.name)
end

action :disable do
  disable(new_resource.name)
end

action :delete do
  if disable(new_resource.name)
    file "#{node['nginx']['sites_available']}/"+new_resource.name do
      action :delete
    end
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.error "Could not disable #{new_resource.name}"
  end
end
