require 'socket'
module Omnibus
  module Mixin
    module TcpUtils

      def wait_for_listening_port(wait_time, port, host = "127.0.0.1")
        count = 0
        begin
          s = Socket.tcp(host, port, nil, nil, connect_timeout: 1)
          s.close
        rescue Errno::ETIMEDOUT, Errno::ECONNRESET,
               Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
          count += 1
          if count < wait_time
            sleep 1 unless e.class == Errno::ETIMEDOUT
            retry
          else
            raise e
          end
        end
      end
    end
  end
end
