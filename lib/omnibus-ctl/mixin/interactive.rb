
module Omnibus
  module Mixin
    module Interactive
      def confirm(explanation = nil, allow_override = true)
        require 'highline/import'
        if allow_override
          if config[:yes]
            return true
          else
            if !$stdin.tty?
              puts "To run this command non-interactively, you must pass in the parameter --yes to force it to continue."
              return false
            end
          end
        else
          if !$stdin.tty?
            puts "This command requires explicit approval to continue and must be run interactively."
            return false
          end
        end

        unless explanation.nil?
          puts ""
          puts explanation
          puts ""
        end

        confirmed = ask("Are you sure you wish to proceed? Type 'proceed' to continue, anything else to cancel.")
        confirmed.downcase == 'proceed'
      end

      def confirm!(explanation = nil, allow_override = true)
        if !confirm(explanation, allow_override)
          puts "Canceling operation"
          exit(4)
        end
        true
      end

      #
      # The following functions where taken from omnibus-ctl to ensure
      # that we present a similar experience with respect to license
      # acceptance as other Chef Software tools.
      #
      def check_license_acceptance(override_accept = false)
        license_guard_file_path = "/var/opt/chef-backend/.license.accepted"

        # If the project does not have a license we do not have
        # any license to accept.
        return true unless File.exist?(project_license_path)

        if !File.exist?(license_guard_file_path)
          if override_accept || ask_license_acceptance
            FileUtils.mkdir_p("/var/opt/chef-backend")
            FileUtils.touch(license_guard_file_path)
          else
            log "Please accept the software license agreement to continue."
            exit(1)
          end
        end
        true
      end

      private

      def ask_license_acceptance
        require 'io/console'
        require 'io/wait'
        require 'highline/import'

        log "To use this software, you must agree to the terms of the software license agreement."

        if !$stdin.tty?
          log "Please view and accept the software license agreement, or pass --accept-license."
          exit(1)
        end

        log "Press any key to continue."
        user_input = $stdin.getch
        user_input << $stdin.getch while $stdin.ready?

        pager = ENV["PAGER"] || "less"
        system("#{pager} #{project_license_path}")

        if ask("Type 'yes' to accept the software license agreement, or anything else to cancel: ") == "yes"
          true
        else
          log "You have not accepted the software license agreement."
          false
        end
      end

      def project_license_path
        "/opt/chef-backend/LICENSE"
      end
    end
  end
end
