#
#
#


# This taken from https://6ftdan.com/allyourdev/2015/03/07/configuration-with-a-singleton-instance/
# Revisit whether openstruct is the right choice, or mixlib config
require 'ostruct'
class Omnibus::OmnibusConfig < OpenStruct
  method_missing(:cmd_name) || "omnibus-ctl"
  method_missing(:base_path) || "/opt/omnibus"
end

module Omnibus
  module Config
    class << self
      def config
        @config ||= OmnibusConfig.new
      end
    end
  end
end

Omnibus.Config.config

# ALL_SERVICES = %w{leaderl epmd etcd postgresql elasticsearch}
# ALL_SYSPARAMS = %w{disks}
# BASE_PATH = "/opt/opscode"
# CONFIG_PATH = "/etc/opscode/chef-server.rb"
# SERVICE_PATH = "#{BASE_PATH}/service"
# SV_PATH = "#{BASE_PATH}/sv"
# SV_INIT_PATH = "#{BASE_PATH}/init"
