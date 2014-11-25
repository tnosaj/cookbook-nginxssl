def whyrun_supported?
  true
end

::Chef::Provider.send(:include, Rtnginx::Ssl::Helper)
::Chef::Provider.send(:include, Rtnginx::Ssl::StringHelper)
# ONLY NEEDED IF ITS NATIVE RUBY!
#def load_current_resource
#  @current_resource = Chef::Resource::RtnginxSsl.new(new_resource.name)
#  @current_resource
#end
use_inline_resources
action :enable do
  t = template node['nginx']['config']['sites_available']+new_resource.name do
    if new_resource.onlyrewrite
      source 'rewrite_site.conf.erb'
    else
      source new_resource.template
    end
    variables({
      :name => new_resource.name,
      :domain => new_resource.domain,
      :subdomain => new_resource.subdomain,
      #if !new_resource.servername.nil?
        :servername => new_resource.servername,
      #else
      #  :servername => [ new_resource.subdomain+"."+new_resource.domain ],
      #end
      :url => new_resource.url,
      :locations => new_resource.locations,
      :serveroptions =>  mergeOptions(node['nginx']['server']['default'], node['nginx']['server'][new_resource.name], new_resource.serveroptions)
    })
  end
  new_resource.updated_by_last_action(t.updated_by_last_action?) 
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
