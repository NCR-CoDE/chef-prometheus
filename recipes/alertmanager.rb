#
# Cookbook Name:: prometheus
# Recipe:: alertmanager
#
# Author: Paul Magrath <paul@paulmagrath.com>
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


dir_name = ::File.basename(node['prometheus']['dir'])
dir_path = ::File.dirname(node['prometheus']['dir'])
alertmanager_dir="#{node['prometheus']['dir']}/alertmanager"


user node['prometheus']['user'] do
  system true
  shell '/bin/false'
  home node['prometheus']['dir']
  not_if { node['prometheus']['use_existing_user'] == true || node['prometheus']['user'] == 'root' }
end

directory node['prometheus']['dir'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end

directory node['prometheus']['log_dir'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end


log "download and unpackage alertmanager in #{alertmanager_dir}"
ark 'alertmanager' do
  url node['prometheus']['alertmanager']['package_url']
  checksum node['prometheus']['alertmanager']['package_checksum']
  path node['prometheus']['dir']
  owner node['prometheus']['user']
  group node['prometheus']['group']
  action :put
end

log 'setting up alertmanager service'
alertmanager_command="#{node['prometheus']['alertmanager']['binary']} -config.file=#{node['prometheus']['alertmanager']['config.file']}"
 supervisor_service "alertmanager" do
  action :enable
  autostart true
  user "prometheus"
	directory alertmanager_dir
  command alertmanager_command
end


