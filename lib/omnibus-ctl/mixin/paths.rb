#
# TODO This is config information, and probably should be outsourced
#

module Omnibus
  module Mixin
    module Paths
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
