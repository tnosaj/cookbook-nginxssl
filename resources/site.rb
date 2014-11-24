def initialize(*args)
  @subresources = []
  super
end


actions :enable, :disable, :delete
default_action :enable

#switches
attribute :template,            :kind_of => String, :default => "site.conf.erb"
attribute :onlyrewrite,         :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :http,                :kind_of => [ TrueClass, FalseClass ], :default => false
attribute :https,               :kind_of => [ TrueClass, FalseClass ], :default => true

#file variables
attribute :name,                :kind_of => String, :name_attribute => true 
attribute :domain,              :kind_of => String, :default => "runtastic.com"
attribute :subdomain,           :kind_of => String, :default => :name_attribute
attribute :servername,          :kind_of => Array, :default => nil
attribute :url,                 :kind_of => String, :default => nil
attribute :default_proxy_path,  :kind_of => String, :required => true
attribute :locations,           :kind_of => Hash, :default => nil
attribute :serveroptions,       :kind_of => Hash, :default => nil
attribute :listenaddr,          :kind_of => String, :default => "0.0.0.0"
attribute :listenport,          :kind_of => String, :default => "443"
