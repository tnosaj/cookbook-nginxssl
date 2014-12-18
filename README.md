# Nginx SSL Proxy

LWRP collection for configuring nginx as an SSL proxy

## Attributes

```ruby
node['nginx']['config']['template']
```
defaults to "nginx.conf.erb"
```ruby
node['nginx']['config']['dir'] = "/etc/nginx/"
```
```ruby
node['nginx']['config']['file'] = node['nginx']['config']['dir']+"nginx.conf"
```
```ruby
node['nginx']['config']['sites_available'] = node['nginx']['config']['dir']+"sites-available/"
```
```ruby
node['nginx']['config']['sites_enabled'] = node['nginx']['config']['dir']+"sites-enabled/"
```
```ruby
node['nginx']['config']['pid'] = "/run/nginx.pid"
```
```ruby
node['nginx']['config']['logdir'] = "/var/log/nginx/"
```

### knife

Install and manage containers via the knife-remotelxc plugin.

## LWRPs

### lxc

Allows for creation, deletion, and cloning of containers

### lxc_config

Allows configuration of the LXC configuration file

### lxc_fstab

Allows defining mounts to be used within the container

### lxc_interface

Allows configurations of network interfaces within a container

### lxc_ephemeral

Run a command within an ephemeral container

### lxc_container

Creates a container using the `lxc` LWRP and configures the container
as requested. This resource also allows nesting `lxc_fstab` and
`lxc_interface` within the container resource.

## Example

```ruby
include_recipe 'lxc'

lxc_container 'my_container' do
  action :create
  validation_client 'my-validator'
  server_uri 'https://api.opscode.com/organizations/myorg'
  validator_pem content_from_encrypted_dbag
  run_list ['role[base]']
  chef_enabled true
  fstab_mount "Persist" do
    file_system '/opt/file_store'
    mount_point '/opt/file_store'
    type 'none'
    options 'bind,rw'
  end
end

lxc_container 'my_container_clone' do
  action :create
  clone 'my_container'
  chef_enabled true
end

lxc_service 'my_container_clone' do
  action :start
end
```

Containers do not have to be Chef enabled but it does make them
extremely easy to configure. If you want the Omnibus installer
cached, you can set the attribute

```ruby
node['omnibus_updater']['cache_omnibus_installer'] = true
```

in a role or environment (default is false). The `lxc_container`
resource also provides `initialize_commands` which an array of
commands can be provided that will be run after the container is
created.

### Repository:

* https://github.com/hw-cookbooks/lxc

### Contributors

* Sean Porter (https://github.com/portertech)
* Matt Ray (https://github.com/mattray)
