def initialize(*args)
  @subresources = []
  super
end


actions :enable, :disable, :delete
default_action :enable

attribute :name,                :kind_of => String, :name_attribute => true 
attribute :http,                :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :https,               :kind_of => [ TrueClass, FalseClass ], :default => true
attribute :domain,              :kind_of => String, :default => "runtastic.com"
attribute :subdomain,           :kind_of => String, :default => :name_attribute
attribute :url,                 :kind_of => String, :default => nil
attribute :default_proxy_path,  :kind_of => String, :required => true
attribute :template,            :kind_of => String, :default => "site.conf.erb"
attribute :onlyrewrite,         :kind_of => [ TrueClass, FalseClass ], :default => false

def location(iname, &block)
  loc = Chef::Resource::NginxLocation.new("rtnginx-ssl_location[#{self.name} - #{iname}]", nil)
  loc.path self.path
  loc.proxy self.proxy
  loc.options self.options
  loc.action :create
  @subresources << [iface, block]
end

