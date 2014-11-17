def whyrun_supported?
  true
end

action :enable do
  template ['nginx']['config']['sites_available']+new_resource.name do
    if new_resource.onlyrewrite
      source 'rewrite_site.conf.erb'
    else
      source new_resource.template
    end
    variables({
      :name => new_resource.name,
      :http => new_resource.http,
      :https => new_resource.https,
      :domain => new_resource.domain,
      :subdomain => new_resource.subdomain,
      :url => new_resource.url,
      :default_proxy_path  => new_resource.default_proxy_path,
      :locations => new_resource.locations
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
    file ['nginx']['config']['sites_available']+new_resource.name do
      action :delete
    end
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.error "Could not disable #{new_resource.name}"
  end
end
