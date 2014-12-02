Description
===========

Requirements
============

Attributes
==========

Usage
=====

Server Settings:
node['nginx']['server']['default']
node['nginx']['server'][new_resource.name]
new_resource.serveroptions


modifiers hash:
  
type => defaults to 'if'
query => what should match
options => what should happen

  "rewrite www to https" => {
    "type" => "if",
    "query" => '$http_host = "www.runtastic.com"',
    "options" => 'rewrite ^/(.*)$ https://www.runtastic.com/$1'
  },





locations hash:

arbitrary name for hash => only refered to in comment and as a key for a location
base => base url for the location ( e.g. / for all of www.runtastic.com )
options => hash of options, can also contain a hash (1 level in depth)

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


  # default
  location / {
    proxy_pass http://123.123.123.123:80;
    proxy_set_header Host $host;
    proxy_set_header x-forwarded-for $remote_addr;
  }

