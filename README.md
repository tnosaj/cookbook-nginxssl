Description
===========

Requirements
============

Attributes
==========

Usage
=====



modifiers hash:





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

