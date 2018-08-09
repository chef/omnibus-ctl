# TODO 
# Like the path module this is config information and should be configurable
#

module Omnibus
  module Mixin
    module ErlEnv
      def set_erl_env
        ENV['ERL_EPMD_PORT'] = epmd_port.to_s
        ENV['ERL_EPMD_ADDRESS'] = '127.0.0.1'
      end

      def epmd_bin
        File.join(LibCB.node['chef-backend']['install_path'], 'embedded/bin/epmd')
      end

      def epmd_port
        LibCB.node['chef-backend']['epmd']['port']
      end
    end
  end
end
