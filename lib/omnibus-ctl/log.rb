# Copyright (c) 2016 Chef Software, Inc.
#
# All Rights Reserved
#

require 'mixlib/log'

module Omnibus
  if defined?(::Chef::Log)
    Log = ::Chef::Log
  else
    class Log
      extend Mixlib::Log
      Mixlib::Log::Formatter.show_time = false
    end
  end
end
