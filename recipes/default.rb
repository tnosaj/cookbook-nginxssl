#
# Cookbook Name:: nginx-ssl
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "nginxssl::configure"
include_recipe "ssl-certs"
