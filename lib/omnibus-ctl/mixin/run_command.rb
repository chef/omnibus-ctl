require 'libcb/log'

module Omnibus
  module Mixin
    module RunCommand
      def run_command(cmd, opts = {})
        cmd_opts = {}
        if opts[:quiet]
          cmd_opts[:out] = "/dev/null"
          cmd_opts[:err] = "/dev/null"
        end
        Omnibus::Log.debug("Running cmd: #{filter_command(cmd)} (options: #{cmd_opts})")
        system(cmd, cmd_opts)
        $?
      end

      # Simple filtering for pgsql commands that might have passwords.
      # The passwords that we generate don't have spaces; however,
      # this filtering may fail on user supplied passwords.
      def filter_command(cmd)
        cmd.gsub(/(password=)(\w*)\b/, '\1<REDACTED>')
      end
    end
  end
end
