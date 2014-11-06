#
# Cookbook Name:: nginx
# Recipe:: logrotate
#
# Copyright 2012, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

nginx_service = service "nginx" do
  action :nothing
end

begin
  include_recipe 'logrotate'
rescue
  Chef::Log.warn("The nginx::logrotate recipe requires the logrotate cookbook. Install the cookbook with `knife cookbook site install logrotate`.")
end
logrotate_app nginx_service.service_name do
  cookbook  'logrotate'
  path ['/var/log/nginx/*.log']
  options   ['missingok', 'delaycompress', 'notifempty']
  frequency 'daily'
  rotate    2
  create    '644 root adm'
  postrotate '[ ! -f /opt/nginx/logs/nginx.pid ] || kill -USR1 `cat /opt/nginx/logs/nginx.pid`'
end
