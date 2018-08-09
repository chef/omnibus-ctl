module Omnibus
  module Mixin
    #
    # Helper functions for dealing with operations
    # that may fail and should be retried
    #
    module Retry
      def try_with_retries(retry_count, opts = {}, &block)
        rescue_class = opts[:exception_class] || StandardError
        retries = 0
        begin
          yield
        rescue rescue_class => e
          if retries < retry_count
            retries += 1
            if opts[:sleep_time]
              sleep opts[:sleep_time]
            end
            retry
          else
            case opts[:on_fail]
            when :ignore
            else
              raise e
            end
          end
        end
      end
    end
  end
end
