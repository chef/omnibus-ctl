#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require File.join(File.dirname(__FILE__), "spec_helper")

describe Omnibus::Ctl do
  standard_commands = %w{
          show-config
          reconfigure
          cleanse
          uninstall
          service-list
          status
          tail
          start
          stop
          restart
          once
          hup
          term
          int
          kill
          graceful-kill
          help
  }

  before(:each) do
    @ctl = Omnibus::Ctl.new("chef-server")
    @ctl.fh_output = StringIO.new
  end

  describe "initialize" do
    it "returns an Omnibus::Ctl instance" do
      Omnibus::Ctl.new("chef-server").should be_a_kind_of(Omnibus::Ctl)
    end

    it "sets the name accessor to the first argument" do
      Omnibus::Ctl.new("chef-server").name.should == "chef-server"
    end

    it "sets the fh_output to STDOUT" do
      Omnibus::Ctl.new("chef-server").fh_output.should === STDOUT
    end
  end

  describe "command_map" do
    standard_commands.each do |cmd|
      it "has #{cmd} by default" do
        @ctl.command_map.has_key?(cmd).should == true
      end
    end

    it "has no commands that are not tested by default" do
      @ctl.command_map.each_key do |cmd|
        standard_commands.include?(cmd).should == true
      end
    end
  end

  describe "log" do
    it "puts to the fh_output" do
      @ctl.log("you really should see this!")
      @ctl.fh_output.rewind
      @ctl.fh_output.gets(nil).should == "you really should see this!\n"
    end
  end

  describe "help" do
    standard_commands.each do |cmd|
      it "prints the #{cmd} command and description" do
        @ctl.stub(:exit!).and_return(true)
        @ctl.help
        @ctl.fh_output.rewind
        output = @ctl.fh_output.gets(nil)
        output.should =~ /#{Regexp.escape(cmd)}\n  #{Regexp.escape(@ctl.command_map[cmd][:desc])}/
      end
    end

    it "exits 1" do
      lambda { @ctl.help }.should raise_error(SystemExit)
    end
  end

  describe "exit!" do
    it "raises systemexit with the code specified" do
      lambda { @ctl.exit! 15 }.should raise_error(SystemExit)
      exit_code = nil
      begin
        @ctl.exit! 15
      rescue SystemExit => e
        exit_code = e.status
      end
      exit_code.should == 15
    end
  end

  describe "run" do
    it "exits 1 if the command is not found" do
      exit_code = nil
      begin
        @ctl.run(["I-do-not-exist"])
      rescue SystemExit => e
        exit_code = e.status
      end
      exit_code.should == 1
    end

    it "exits 2 if the command is found, but not with the arity you provided on the cli" do
      exit_code = nil
      begin
        @ctl.run(["reconfigure","not-found"])
      rescue SystemExit => e
        exit_code = e.status
      end
      exit_code.should == 2
    end

    it "runs the method describe by the command" do
      @ctl.stub(:exit!).and_return(true)
      @ctl.should_receive(:help).with("help")
      @ctl.run(["help"])
    end
  end

  describe "load_files" do
    before(:each) do
      @ctl.load_files(File.join(File.dirname(__FILE__), "data"))
    end

    it "loads the files in a path, and instance_evals them" do
      @ctl.extended
      @ctl.run(["extended"]).should == true
      @ctl.run(["arity"]).should == true
    end

    it "should let you add to the help output" do
      @ctl.stub(:exit!).and_return(true)
      @ctl.help
      @ctl.fh_output.rewind
      output = @ctl.fh_output.gets(nil)
      output.should =~ /#{Regexp.escape("extended")}\n  #{Regexp.escape("Extended omnibus-ctl")}/
    end

    it "should let a loaded command declare arity" do
      @ctl.run(["arity", "some-arg"]).should == true
    end

    it "should allow loaded commands with dashes in the name" do
      @ctl.run(["name-with-dashes"]).should == true
    end
  end

end
