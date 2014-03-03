#
# Cookbook Name:: mysql56-mroonga
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "yum"

base_dir = "/usr/local/src/mroonga/build"

if node[:platform] == "amazon" then
  releasever = "6"
else
  releasever = "$releasever"
end

yum_repository "epel" do
  description "epel repo"
  baseurl "http://dl.fedoraproject.org/pub/epel/#{releasever}/$basearch/"
  gpgkey  "http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL"
  enabled true
end

%w{mysql mysql-libs mysql-server}.each do |pack|
  package "mysql-libs" do
    action :remove
  end
end

%w{gcc gcc-c++ make wget yum-utils}.each do |pack|
  package pack do
    action :install
  end
end

%w{BUILD RPMS SOURCES SPECS SRPMS}.each do |dir|
  directory "#{base_dir}/rpmbuild/#{dir}" do
    action :create
    recursive true
  end
end

directory "#{base_dir}/rpmbuild/RPMS/x86_64" do
  action :create
end

execute "set .rpmmacros" do
  command <<-EOH
  echo '%_topdir #{base_dir}/rpmbuild' > ~/.rpmmacros
  echo '%debug_package %{nil}' >> ~/.rpmmacros
  EOH
end

mysql_packages = [
  "MySQL-shared-#{node['mysql56-mroonga']['mysql_version']}.el6.x86_64.rpm",
  "MySQL-server-#{node['mysql56-mroonga']['mysql_version']}.el6.x86_64.rpm",
  "MySQL-devel-#{node['mysql56-mroonga']['mysql_version']}.el6.x86_64.rpm",
  "MySQL-client-#{node['mysql56-mroonga']['mysql_version']}.el6.x86_64.rpm"
]
mysql_packages.each do |rpm|
  remote_file "#{base_dir}/rpmbuild/RPMS/x86_64/#{rpm}" do
    source "http://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.6/#{rpm}"
  end
  rpm_package rpm do
    source "#{base_dir}/rpmbuild/RPMS/x86_64/#{rpm}"
    action :install
  end
end

remote_file "#{base_dir}/rpmbuild/SRPMS/MySQL-#{node['mysql56-mroonga']['mysql_version']}.el6.src.rpm" do
  source "http://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.6/MySQL-#{node['mysql56-mroonga']['mysql_version']}.el6.src.rpm"
end

execute "rpm -Uvh MySQL-#{node['mysql56-mroonga']['mysql_version']}.el6.src.rpm" do
  cwd "#{base_dir}/rpmbuild/SRPMS"
end

service "mysql" do
  supports :status => true, :restart => true, :reload => false
  action [:enable, :start]
end

execute "reset root password" do
  command <<-EOH
  mysqladmin -uroot --password=$(head -1 /root/.mysql_secret | awk -F ': ' '{print $2}') password ""
  mysql -uroot -e 'update user SET Password="" where User="root"' mysql
  rm -f /root/.mysql_secret
  EOH
  only_if {File.exist?("/root/.mysql_secret")}
end

remote_file "/usr/local/src/mroonga/groonga-release-1.1.0-1.noarch.rpm" do
  source "http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm"
end

rpm_package "groonga-release-1.1.0-1.noarch.rpm" do
  source "/usr/local/src/mroonga/groonga-release-1.1.0-1.noarch.rpm"
  action :install
end

if node['platform'] == "amazon" then
  execute 'sed  -i "s/¥$releasever/6/" /etc/yum.repos.d/groonga.repo'
end

%w{
  groonga-libs
  groonga-devel
  groonga-normalizer-mysql
  groonga-normalizer-mysql-devel
  gperf
  ncurses-devel
  time
  zlib-devel
  groonga-tokenizer-mecab
  mecab
  mecab-devel 
  mecab-ipadic
}.each do |pack|
  package pack do
    action :install
  end
end

remote_file "#{base_dir}/mysql-mroonga-#{node['mysql56-mroonga']['mroonga_version']}.el6.src.rpm" do
  source "http://packages.groonga.org/centos/6/source/SRPMS/mysql-mroonga-#{node['mysql56-mroonga']['mroonga_version']}.el6.src.rpm"
end

execute "rpm -ivh mysql-mroonga-#{node['mysql56-mroonga']['mroonga_version']}.el6.src.rpm" do
  cwd "#{base_dir}"
end

execute "prepare rpmbuild" do
  command <<-EOH
  cp mysql-mroonga.spec mysql56-mroonga.spec
  MYSQL_RPM_VER=$(rpm -qa|grep MySQL-server|awk -F '-' '{print $3}')
  MYSQL_RPM_REL=$(rpm -qa|grep MySQL-server|awk -F '-' '{print $4}'|awk -F '.' '{print $1}')
  MYSQL_RPM_DIST=$(rpm -qa|grep MySQL-server|awk -F '-' '{print $4}'|awk -F '.' '{print $2}')
  perl -i -pe "s/mysql_version_default\s+5\.6\.[0-9]+$/mysql_version_default $MYSQL_RPM_VER/g" mysql56-mroonga.spec
  perl -i -pe "s/mysql_release_default\s+[a-z0-9\-_]+$/mysql_release_default $MYSQL_RPM_REL/g" mysql56-mroonga.spec
  perl -i -pe "s/mysql_dist_default\s+[a-z0-9\-_]+$/mysql_dist_default $MYSQL_RPM_DIST/g" mysql56-mroonga.spec
  perl -i -pe "s/mysql_spec_file_default\s+mysql\..+\.spec$/mysql_spec_file_default mysql.spec/g" mysql56-mroonga.spec
  perl -i -pe "s/^Name:\s+mysql-mroonga$/Name: mysql56-mroonga/" mysql56-mroonga.spec
  EOH
  cwd "#{base_dir}/rpmbuild/SPECS"
  not_if {File.exist?("#{base_dir}/rpmbuild/SPECS/mysql56-mroonga.spec")}
end

execute "rpmbuild" do
  command "rpmbuild -bb SPECS/mysql56-mroonga.spec"
  cwd "#{base_dir}/rpmbuild"
  not_if {File.exist?("#{base_dir}/rpmbuild/RPMS/x86_64/mysql-mroonga-doc-#{node['mysql56-mroonga']['mroonga_version']}.el6.x86_64.rpm")}
end

rpm_package "mysql-mroonga-#{node['mysql56-mroonga']['mroonga_version']}.el6.x86_64.rpm" do
  source "#{base_dir}/rpmbuild/RPMS/x86_64/mysql-mroonga-#{node['mysql56-mroonga']['mroonga_version']}.el6.x86_64.rpm"
  action :install
end

rpm_package "mysql-mroonga-doc-#{node['mysql56-mroonga']['mroonga_version']}.el6.x86_64.rpm" do
  source "#{base_dir}/rpmbuild/RPMS/x86_64/mysql-mroonga-doc-#{node['mysql56-mroonga']['mroonga_version']}.el6.x86_64.rpm"
  action :install
end


