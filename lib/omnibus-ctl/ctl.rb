require 'mixlib/cli'
require 'libcb/mixin/recommender'

module Omnibus
  #
  # The Ctl class is the main entry point for chef-backend-ctl. This
  # class is responsible for handling dispatching into the subcommands
  # and handling basic options such as help and version.
  #
  # Command dispatching happens via a Hash of command names to a Hash
  # containing the class name that contains the subcommand,
  # description, and path to require to instantiate the subcommand
  # class.
  #
  class Ctl
    include Mixlib::CLI

    banner <<-USAGE
Usage:
   #{Config.cmd_name} -h/--help
   #{Config.cmd_name} -v/--version
   #{Config.cmd_name} COMMAND [arguments...] [options...]
USAGE

    #
    # We use a static list of subcommand names to the file to require
    # and the class to instantiate.
    #
    
    COMMAND_MAP =
      
    include Omnibus::Mixin::Recommender

    attr_reader :argv
    def initialize(argv)
      @argv = argv
      super()
    end

    #
    # Having multiple classes controlling mixlib-cli gets a bit hairy.
    # For now, we use manual option handling in this top-level
    # dispatcher since we only need a few options at this leven.
    #
    def quiet?
      argv.include?("--quiet") || argv.include?("-q")
    end

    def verbose?
      argv.include?("--verbose") || argv.include?("-V")
    end

    def version_requested?
      argv.include?("--version") || argv.include?("-v")
    end

    def help_requested?
      argv.include?("--help") || argv.include?("-h")
    end

    def option?(arg)
      arg[0] == "-"
    end

    def run
      subcommand, *args = argv
      if subcommand.nil? || option?(subcommand)
        if version_requested?()
          show_version_info
        else
          show_help
        end
        exit 0
      else
        exit_status = run_subcommand(subcommand, args)
        if exit_status.is_a? Integer
          exit exit_status
        else
          exit 0
        end
      end
    end

    def run_help(args)
      pos_args = args.reject { |a| option?(a) }
      if pos_args.empty?
        show_help
      else
        subcommand_name = pos_args.first
        if subcommand_exists?(subcommand_name)
          subcommand = load_subcommand(subcommand_name)
          if subcommand.respond_to?(:help)
            subcommand.help
          else
            show_help
          end
        else
          handle_unknown_subcommand(subcommand_name)
        end
      end
    end

    def handle_unknown_subcommand(command_name, args = [])
      $stderr.puts "Unknown command: #{command_name}"
      if rec = find_recommendation(command_name, COMMAND_MAP.keys)
        $stderr.puts "\nDid you mean:"
        $stderr.puts "   #{rec}"
      elsif args.first && subcommand_exists?(args.first)
        $stderr.puts "\nDid you mean:"
        $stderr.puts "   chef-backend-ctl #{args.first} #{command_name}"
      else
        show_help
      end
    end

    def load_subcommand(subcommand_name)
      s = COMMAND_MAP[subcommand_name]
      require s[:path]
      subcommand_class = Omnibus::Command.const_get(s[:class_name])
      subcommand_class.new
    end

    def run_subcommand(subcommand_name, args)
      # We handle "help" specially so that we can keep all of the
      # command dispatching in once place.
      if subcommand_name == "help"
        run_help(args)
        return 0
      end

      if subcommand_exists?(subcommand_name)
        subcommand = load_subcommand(subcommand_name)

        if help_requested?
          subcommand.help
          0
        elsif version_requested?
          show_version_info
          0
        else
          subcommand.load(verbose: verbose?, quiet: quiet?)
          run_with_pretty_errors(subcommand, args)
        end
      else
        handle_unknown_subcommand(subcommand_name, args)
        exit(1)
      end
    # Errors that occur in this function are likely the result of a major
    # programming error (missing require statements, bad requires)
    rescue StandardError
      $stderr.puts <<EOF
A major error has occurred. If you are seeing this in a released
version of Chef Backend, please report it to Chef Support by emailing
support@chef.io.

EOF
      raise
    end

    def run_with_pretty_errors(subcommand, args)
      subcommand.run(args)
    rescue StandardError => e
      $stderr.puts "An unexpected error occurred:"
      $stderr.puts "  #{e}\n"
      if verbose?
        e.backtrace.each do |line|
          $stderr.puts "#{line}"
        end
      else
        $stderr.puts "For more information run the command with the --verbose flag."
      end
      1
    end

    WRAP_AT = 80
    def show_help
      print banner
      max_name_length = COMMAND_MAP.map { |k, v| k.length }.max
      puts "\nInstall and Configuration Commands:\n\n"
      print_map(INSTALL_COMMANDS, max_name_length)
      puts "\nCluster-level Commands:\n\n"
      print_map(CLUSTER_COMMANDS, max_name_length)
      puts "\nService-level Commands:\n\n"
      print_map(SERVICE_COMMANDS, max_name_length)
      if verbose?
        puts "\nInternal Commands (USE WITH CAUTION)\n"
        print_map(INTERNAL_COMMANDS, max_name_length)
      end
    end

    def print_map(command_map, max_name_length)
      command_map.each do |name, spec|
        name_for_print = name.ljust(max_name_length + 2)
        puts "  #{name_for_print}#{wrap_col(spec[:description], max_name_length + 4, WRAP_AT)}"
      end
    end

    def wrap_col(str, start_pos, end_pos)
      col_size = (end_pos - start_pos)
      return str if str.length <= col_size
      out_buf = ""
      cur_line = ""
      words = str.split(/\s+/)
      words.each do |w|
        if cur_line.empty?
          cur_line << "#{w}"
        elsif (cur_line.length + w.length + 1) < col_size
          cur_line << " #{w}"
        else
          if !out_buf.empty?
            out_buf << " " * (start_pos)
          end
          out_buf << cur_line.dup
          out_buf << "\n"
          cur_line = w
        end
      end
      out_buf << " " * (start_pos)
      out_buf << cur_line.dup
      out_buf << "\n"
      out_buf
    end

    def subcommand_exists?(name)
      COMMAND_MAP.has_key?(name)
    end

    VERSION_FILE = "/opt/chef-backend/version-manifest.txt"
    def show_version_info
      print File.open(VERSION_FILE) { |f| f.readline }
    end
  end
end
