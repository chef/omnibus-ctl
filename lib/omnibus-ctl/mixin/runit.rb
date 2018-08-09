require 'libcb/mixin/run_command'
require 'libcb/mixin/paths'

module Omnibus
  module Mixin
    module Runit

      include Omnibus::Mixin::RunCommand
      include Omnibus::Mixin::Paths

      def run_sv_command(cmd, service_list = [], opts = {})
        service_list = Array(service_list)
        exit_status = 0
        cmd = "1" if cmd == "usr1"
        cmd = "2" if cmd == "usr2"
        service_list = ALL_SERVICES if service_list.empty?
        service_list.each do |service_name|
          exit_status += run_sv_command_for_service(cmd, service_name, opts).exitstatus
        end
        exit_status
      end

      def remove_down_file(service)
        FileUtils.rm_rf(File.join([Paths::SERVICE_PATH,service,"down"]))
      end

      def run_sv_command_for_service(cmd, service_name, opts = {})
        run_command("#{init_path(service_name)} #{cmd}", opts)
      end

      def init_path(svc)
        File.join([Omnibus::Mixin::Paths::SV_INIT_PATH,svc]"
      end

      def known_services
        Dir.glob(init_path("*")).map do |s|
          File.basename(s)
        end
      end
    end
  end
end
