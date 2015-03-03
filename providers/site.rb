def whyrun_supported?
  true
end

::Chef::Provider.send(:include, Nginx::Ssl::StringHelper)
# ONLY NEEDED IF ITS NATIVE RUBY!
#def load_current_resource
#  @current_resource = Chef::Resource::RtnginxSsl.new(new_resource.name)
#  @current_resource
#end
use_inline_resources
action :enable do
  tmpservername = [ new_resource.subdomain+"."+new_resource.domain ]
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
      :servername => new_resource.servername | tmpservername,
      :https => new_resource.https,
      :locations => new_resource.locations,
      :modifiers => new_resource.modifiers,
      :serveroptions =>  mergeOptions(node['nginx']['server']['default'], node['nginx']['server'][tmpservername], new_resource.serveroptions)
    })
    cookbook new_resource.cookbook
  end
  l = link node['nginx']['config']['sites_enabled']+new_resource.name do
    to node['nginx']['config']['sites_available']+new_resource.name
    not_if "test -L #{node['nginx']['config']['sites_enabled']+new_resource.name}"
  end
  new_resource.updated_by_last_action(t.updated_by_last_action? || l.updated_by_last_action?) 
end

action :disable do
  l = link node['nginx']['config']['sites_enabled']+new_resource.name do
    action :delete
    only_if "test -L #{node['nginx']['config']['sites_enabled']+new_resource.name}"
  end
  new_resource.updated_by_last_action(l.updated_by_last_action?) 
end

action :delete do
  l = link node['nginx']['config']['sites_enabled']+new_resource.name do
    action :delete
    only_if "test -L #{node['nginx']['config']['sites_enabled']+new_resource.name}"
  end
  f = file ['nginx']['config']['sites_available']+new_resource.name do
    action :delete
  end
  new_resource.updated_by_last_action(l.updated_by_last_action? || f.updated_by_last_action?) 
end
