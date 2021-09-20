module Omnibus
  module Mixin
    module ServiceUtils
      def services_exist?(services)
        services.each do |s|
          return false unless ALL_SERVICES.include?(s)
        end
        true
      end
      
      def recommend_services(services, set = ALL_SERVICES, description = "service")
        bad_services = services.reject { |s| set.include?(s) }
        bad_services.each do |s|
          puts "Unknown #{description}: #{s}"
          if rec = find_recommendation(s, set)
            puts "\nDid you mean:"
            puts "    #{rec}"
          end
        end
      end

      def recommend_params(params)
        recommend_services(params, ALL_SERVICES + ALL_SYSPARAMS, "service or system component")
      end

      def graceful_kill(service = nil, quiet = config[:quiet])
        services_to_kill = service.nil? ? ALL_SERVICES : Array(service)
        services_to_kill.each do |svc|
          graceful_kill_service(svc, quiet)
        end
      end

      def graceful_kill_service(service_name, quiet)
        pidfile = "#{SV_PATH}/#{service_name}/supervise/pid"
        pid = File.read(pidfile).chomp if File.exists?(pidfile)
        pgrp = nil

        if pid.nil? || !is_integer?(pid)
          log "could not find #{service_name} runit pidfile (service already stopped?), cannot attempt SIGKILL..." unless quiet
        else
          pgrp = get_pgrp_from_pid(pid)
        end

        if pgrp.nil? || !is_integer?(pgrp)
          log "could not find pgrp of pid #{pid} (not running?), cannot attempt SIGKILL..." unless quiet
        end

        res = run_sv_command("stop", service_name, quiet: quiet)
        if !pgrp.nil?
          pids = get_pids_from_pgrp(pgrp)
          unless pids.empty?
            log "found stuck pids still running in process group: #{pids}, sending SIGKILL" unless quiet
            sigkill_pgrp(pgrp)
          end
        else
          res
        end
      end

      def is_integer?(string)
        return true if Integer(string) rescue false
      end

      def get_pgrp_from_pid(pid)
        ps = `which ps`.chomp
        `#{ps} -p #{pid} -o pgrp=`.chomp
      end

      def get_pids_from_pgrp(pgrp)
        pgrep = `which pgrep`.chomp
        `#{pgrep} -g #{pgrp}`.split(/\n/).join(" ")
      end

      def sigkill_pgrp(pgrp)
        pkill = `which pkill`.chomp
        run_command("#{pkill} -9 -g #{pgrp}")
      end

      
    end
  end
end
