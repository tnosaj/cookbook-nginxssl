def initialize(*args)
  @subresources = []
  super
end

actions :configure, :test, :reload, :install
default_action :nothing

attribute :name,      :kind_of => String, :name_attribute => true
attribute :template,  :kind_of => String, :default => "nginx.conf.erb"
attribute :cookbook,  :kind_of  => String, :default => "nginxssl"
