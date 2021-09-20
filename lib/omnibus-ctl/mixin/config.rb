#
# 
#

# Revisit whether openstruct is the right choice, or mixlib config
require 'ostruct'
class Omnibus::Mixin::OmnibusConfig < OpenStruct

module Omnibus
  module Mixin
    module Config
      class << self
        def config
          @config ||= 

        
      ALL_SERVICES = %w{leaderl epmd etcd postgresql elasticsearch}
      ALL_SYSPARAMS = %w{disks}
      BASE_PATH = "/opt/opscode"
      CONFIG_PATH = "/etc/opscode/chef-server.rb"
      SERVICE_PATH = "#{BASE_PATH}/service"
      SV_PATH = "#{BASE_PATH}/sv"
      SV_INIT_PATH = "#{BASE_PATH}/init"
    end
  end
end
