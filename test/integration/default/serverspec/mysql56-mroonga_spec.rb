# -*- coding:utf-8 -*-

require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.os = backend(Serverspec::Commands::Base).check_os
    c.path = '/sbin:/usr/bin'
  end
end

describe service('mysql') do
  it { should be_enabled }
  it { should be_running }
end

%w{
  MySQL-shared
  MySQL-server
  MySQL-devel
  MySQL-client
}.each do |pack|
  describe package(pack) do
    it { should be_installed.with_version('5.6.16-1') }
  end
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
  describe package(pack) do
    it { should be_installed }
  end
end

%w{mysql-mroonga mysql-mroonga-doc}.each do |pack|
  describe package(pack) do
    it { should be_installed.with_version('4.00-2') }
  end
end

describe command('cat /root/.mysql_secret') do
  it { should return_stdout /: password/ }
end

describe command('mysql -uroot -ppassword -e "show databases"') do
  it { should return_stdout /information_schema/ }
end

