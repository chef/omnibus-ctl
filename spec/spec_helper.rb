#
# Author: adam@opscode.com
#
# Copyright 2012-18, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rspec'
require 'omnibus-ctl'

require 'simplecov'
require 'stringio'

SimpleCov.start do
  track_files "lib/**/*.rb"
  add_filter "spec/*.rb"
end

RSpec.configure do |config|
  config.filter_run focus: true
#  config.order = 'random'
  config.run_all_when_everything_filtered = true
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

RSpec.shared_context "captured output" do
  before do
    # quiet Omnibus::Log
    @old_log_level = Omnibus::Log.level
    Omnibus::Log.level :fatal
    @my_stdout = StringIO.new
    @my_stderr = StringIO.new
    @old_stdout = $stdout
    @old_stderr = $stderr
    $stdout = @my_stdout
    $stderr = @my_stderr
    @old_highline_use_color = HighLine.use_color?
  end

  after do
    Omnibus::Log.level @old_log_level
    $stdout = @old_stdout
    $stderr = @old_stderr
    HighLine.use_color = @old_highline_use_color
  end
end


