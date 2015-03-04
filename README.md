# Nginx SSL Proxy

LWRP collection for configuring nginx as an SSL proxy

## Attributes

```ruby
node['nginx']['config']['template']
```
Template to use from the cookbook for the nginx.conf: Defaults to *nginx.conf.erb*
```ruby
node['nginx']['config']['dir']
```
Nginx config dir: Defaults to */etc/nginx/*
```ruby
node['nginx']['config']['file']
```
Main  Nginx config file: Defaults to */etc/nginx/nginx.conf*
```ruby
node['nginx']['config']['sites_available']
node['nginx']['config']['sites_enabled']
```
Location of sites_available/sites_enabled directories: Defaults to  */etc/nginx/sites_available/* and */etc/nginx/sites_enabled/* respectively
```ruby
node['nginx']['config']['pid']
```
Nginx pid file location: Defaults to */run/nginx.pid*
```ruby
node['nginx']['config']['logdir']
```
Nginx log directory: Defaults to */var/log/nginx/*

### Aditional Attributes

- SSL settings 

SSL settings for a domain are made via attributes. Nested under
```ruby
node['nginx']['config']['ssl']
```
is a Hash where the domain name is the key.

```ruby
node['nginx']['config']['ssl']['example.com']
```
Under the domain, all the relevant settings for the SSL encryption are passed on. They can be in key -> value, key -> array or hash form, where the cookbook traverses all the way through and flattens the list. These settings are passed directly to the site config, hence they should be nginx options.

Here is the example in the test kitchen configuration:
```ruby
node['nginx']['config']['ssl']['example.com']  = {
  "ssl_certificate" => "/etc/ssl/certs/ssl-cert-snakeoil.pem",
  "ssl_certificate_key" => "/etc/ssl/private/ssl-cert-snakeoil.key",
  "ssl_protocols" => "TLSv1 TLSv1.1 TLSv1.2",
  "ssl_ciphers" => "RC4:HIGH:!aNULL:!MD5",
  "ssl_prefer_server_ciphers" => "on"
}
```
- Site settings

This is a generic setting section to ensure that sensible values are applied to all sites on the server. Again they can be in key -> value, key -> array or hash form, where the cookbook traverses all the way through and flattens the list.
```ruby
node['nginx']['server']['default'] = {   
  "keepalive_timeout" => "60",
  "access_log" => "off",
  "client_max_body_size" => "10M"
}
```
It is also possible to include these settings for a single file on the node directly in the same way as for the afore mentioned default site.
```
node['nginx']['server'][ XZY ]
```
where **XZY** correspond to the name of the resource of the site (see the site LWRP for further details).

## Recipes

### default.rb
Placeholder recipe: does nothing.

### test_kitchen.rb
Using the lwrps, this recipe installs and configures nginx as an SSL proxy for the example.com domain with the ssl-cert-snakeoil included with all (ubuntu) installations.

## LWRPs

### nginxssl

Installs, Configures and checks configuration of an nginx


####Actions 
| **Action** | **Description** | **Default** |
| ------------- | ------------- | -----|
| configure | Configures the main nginx configuration file *nginx.conf*| |
| test | Executes a ```nginx -t``` to ensure that the configuration is sane| |
| reload | Reloads the nginx service after first calling the test action| |
| install | installs *nginx* from the ```ppa:nginx/stable ``` repository along with the *ssl-cert* package| |

####Attributes

| **Action** | **Description** | **Default** |
| ------------- | ------------- | -----|
| template| tempalte to use for the system wide *nginx.conf* |nginx.conf.erb |
|cookbook | name of the cookbook where the aforementioned template for the *nginx.conf* is located |nginxssl|

####Example

install and configure an nginx

```ruby
nginxssl "instance" do
  action :install
end

nginxssl "instance" do
  action :configure
end

```

### nginxssl_site

Configures a single nginx site as a proxy (with or without ssl). It can take a number of options, allowing the complete configuration of rewrites/locations/etc. which nginx supports. All actions of this resourece will update the ```updated_by_last_action?```   the parent resource, allowing a ```notifies``` to be attatched as a callback. 

####Actions 
| **Action** | **Description** | **Default** |
| ------------- | ------------- | -----|
| enable | creates the template for the site under ```node['nginx']['config']['sites_available']``` and links it to the  ```node['nginx']['config']['sites_enabled']```. | **DEFAULT**|
| disable | Removes the link for the site under  ```node['nginx']['config']['sites_enabled']```.| |
| delete | Removes the link for the site under  ```node['nginx']['config']['sites_enabled']``` and deletes the site config under ```node['nginx']['config']['sites_available']```| |

####Attributes

| **Action** | **Description** | **Default** |
| ------------- | ------------- | -----|
|name||resource name|
| template| tempalte to use for the site configuration |site.conf.erb |
|cookbook | name of the cookbook where the aforementioned template for the site is located |nginxssl|
|domain| (see notes bellow) | "example.com"
|subdomain|(see notes bellow)| "www"
|onlyrewrite| it is possible to setup rewrites only: setting this to true will use a special minimal template which only rewrites urls from: ```name``` to ```subdomain```+```domain``` | false
|https |disabling this setting sets the site to http only, where it will listen on port 80 | true
|servername| it is possible to add names to the nginx server_name directive if they vary from ```subdomain```+```domain``` e.g. if you want to include a domain only name aswell (*www.example.com and example.com*) |nil
|serveroptions| (see the note bellow) | nil
|modifiers|| ```{}```
|locations|| nil

Notes about ```domain``` and ```subdomain``` attributes
1. used to lookup ssl configuration where ```node['nginx']['config']['ssl'][DOMAIN]``` defines the ssl configuration for the domain.
2. when using the ```onlyrewrite``` option the ```subdomain``` + ```domain``` are used to determine where to rewrite to.

Notes about ```serveroptions``` attribute
This section is a combination: the following attributes are merged (and overwritten) in the following order:
1. ```node['nginx']['server']['default']```
2. ```node['nginx']['server'][```*subdomain*``` . ```*domain*```]```
3. options passed directly here

## Example

### SSL proxy site
This is a simple configuration as can be taken from the ```test_kitchen.rb``` recipe.

First we fill a hash with the modifiers (*mods*) and location (*locs*)  rules:
```ruby

mods = {
  "rewrite to https" => {
    "query" => '$http_host = "example.com"',
    "options" => 'rewrite ^/(.*)$ https://www.example.com/$1'
  }
}

locs = {
  "shop" => {
    "base" => "/shop",
    "options" => {
      "proxy_pass" => "http://123.123.123.123:80",
      "proxy_set_header" => {
        "Host" => "$host",
        "x-forwarded-for" => "$remote_addr"
      }
    }
  },
  "default" => {
    "base" => "/",
    "options" => {
      "proxy_pass" => "http://123.123.123.123:80",
      "proxy_set_header" => {
        "Host" => "$host",
        "x-forwarded-for" => "$remote_addr"
      }
    }
  }
}
```
Pass the modifiers and locations, along with the other settings to the site:
```ruby
nginxssl_site "www" do
  action :enable
  servername ["www.example.com","example.com"]
  domain "example.com"
  locations locs
  modifiers mods
  notifies :reload, "nginxssl[instance]"
end
```
```ruby
nginxssl_site "totally-not-example.com" do
  action :enable
  subdomain "www"
  domain "example.com"
  onlyrewrite true
  notifies :reload, "nginxssl[instance]"
end
```

### Contributors

* jat [ *Jason Tevnan* ] (https://github.com/tnosaj)