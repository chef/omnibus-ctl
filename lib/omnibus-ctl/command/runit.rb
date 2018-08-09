require 'omnibus/command/base'

module Omnibus
  module Command
    #
    # RunitBase is the base class for all runit-based commands. Since
    # all of the runit based commands simply run a different sv
    # command, we define them all in this file.
    #
    class RunitBase < Base
      include Omnibus::Mixin::ServiceUtils
      
      def self.include_runitopts
        include_stdopts
      end

      def sv_command
        raise NotImplemented
      end

      def run(args)
        parse_options(args)
        services = cli_arguments
        if services_exist?(services)
          run_sv_command(sv_command, services)
        else
          recommend_services(services)
          1
        end
      end
    end

    #
    # Runit supports more commands that these, but these
    # are the commands supported by our -ctl style commands in
    # other products
    #
    RUNIT_COMMANDS = %w{start stop restart once hup
                        term int kill usr1 usr2}

    RUNIT_COMMANDS.each do |cmd_name|
      class_name = cmd_name.delete("-").capitalize
      class_eval(<<-CLASS)
      class #{class_name} < RunitBase
        register_command cmd_name, [:runit]
        banner "Usage: #{Omnibus.config.cmd_name} #{cmd_name} [SERVICE..] (options)"
        include_runitopts
        def sv_command
          "#{cmd_name}"
        end
      end
CLASS
    end
  end
end
