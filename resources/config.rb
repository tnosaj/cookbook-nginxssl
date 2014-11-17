def initialize(*args)
  @subresources = []
  super
end

actions :configure, :test, :reload
default_action :test

attribute :name,      :kind_of => String, :name_attribute => true
attribute :template,  :kind_of => String, :default => nil
