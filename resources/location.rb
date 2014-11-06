actions :create, :delete
default_action :create

attribute :path, :kind_of => String, :required => true
attribute :proxy, :kind_of => String, :required => true
attribute :options, :kind_of => [Array, Hash], :default => nil

