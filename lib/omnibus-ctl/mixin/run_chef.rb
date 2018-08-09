module Omnibus
  module Mixin
    module RunChef
      def run_chef(opts = {})
        remove_old_node_state
        log_level = if opts.has_key?(:log_level)
                      "-l #{opts[:log_level]}"
                    elsif config[:verbose]
                      "-l debug"
                    elsif config[:quiet]
                      "-l fatal"
                    else
                      ""
                    end

        formatter = if opts.has_key?(:formatter)
                      "-F #{opts[:formatter]}"
                    elsif config[:quiet]
                      "-F null"
                    else
                      ""
                    end

        override = opts.has_key?(:override_run_list) ? "-o #{opts[:override_run_list]}" : ""

        int_json_file = nil
        if opts.has_key?(:override_attributes)
          int_json_file = Tempfile.new('cb-attributes')
          int_json_file.write(opts[:override_attributes].to_json)
          int_json_file.flush
          opts[:json_file] = int_json_file.path
        end

        json = opts.has_key?(:json_file) ? "-j #{opts[:json_file]}" : ""

        cmd = "#{BASE_PATH}/embedded/bin/chef-client #{log_level} #{formatter} -z -c #{BASE_PATH}/embedded/cookbooks/solo.rb #{json} #{override}"
        cmd += " #{opts[:args]}" unless opts[:args].nil? || opts[:args].empty?
        run_command(cmd)
      ensure
        if int_json_file
          int_json_file.close
          int_json_file.unlink
        end
      end
    end
  end
end

