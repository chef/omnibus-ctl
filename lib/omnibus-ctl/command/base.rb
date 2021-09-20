#
# Base infrastructure for a subcommand
#

#
# An expensive require can slow the whole system down; minimize what goes here at all costs
#
require 'mixlib/cli'
require 'omnibus/mixin/recommender'
require 'omnibus/mixin/interactive'
require 'omnibus/mixin/run_command'
require 'omnibus/mixin/runit'
require 'omnibus/mixin/paths'
require 'omnibus/config'

module Omnibus
  module Command
    class Base
      #
      # Register declares 
      #
      class << self; attr_accessor :available_commands end
      available_commands = []
      def self.register_command(class_name, command_name, command_groups = [])
        available_commands += {name: command_name, groups: command_groups}
      end
      
      #
      # Load is called by the ctl before #run is called
      #
      def load(basic_config = {})

        # We put the requires here rather than in deps since we want
        # subclasses to define deps without needing to call super.
        require 'fileutils'
        require 'tempfile'
        require 'highline'
        require 'omnibus'
        require 'omnibus/log'
        log_level = if basic_config[:verbose]
                      :debug
                    else
                      :info
                    end
        Omnibus::Log.level = log_level
        HighLine.use_color = $stdout.tty?
        Omnibus.load
        deps
      end

      #
      # Called before #run
      # Subclasses will override this with their own requires.
      #
      def deps
        
      end

      def help
        puts opt_parser.to_s
        if extended_help.length > 0
          puts "\n#{extended_help}"
        end
      end
      alias :show_help :help

      #
      # Returns a String that is appended to the end of the help
      # output for the command, allowing commands to provide more help
      # text than a simple list of options.
      #
      def extended_help
        ""
      end

      def log(msg)
        $stdout.puts msg unless config[:quiet]
      end

      def warn(msg)
        $stderr.puts HighLine.color(msg, :yellow)
      end

      def err(msg)
        $stderr.puts HighLine.color(msg, :red)
      end

    end
  end
end # module Omnibus
