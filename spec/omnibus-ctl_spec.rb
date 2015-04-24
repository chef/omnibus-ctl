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
          help
  }
  service_commands = %w{
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
  }

  all_commands = standard_commands + service_commands

  before(:each) do
    @ctl = Omnibus::Ctl.new("chef-server")
    @ctl.fh_output = StringIO.new
  end

  describe "initialize" do
    it "returns an Omnibus::Ctl instance" do
      expect(Omnibus::Ctl.new("chef-server")).to be_a_kind_of(Omnibus::Ctl)
    end

    it "sets the name accessor to the first argument" do
      expect(Omnibus::Ctl.new("chef-server").name).to eq("chef-server")
    end

    it "sets the fh_output to STDOUT" do
      expect(Omnibus::Ctl.new("chef-server").fh_output).to be === STDOUT
    end

    it "by default controls services" do
      expect(Omnibus::Ctl.new("chef-server").service_commands?).to eq(true)
    end
  end

  describe "get_all_commands_hash" do
    it "should return all the commands in a top-level hash" do

      all_commands.each do |cmd|
        expect(@ctl.get_all_commands_hash.has_key?(cmd)).to eq(true)
      end
    end

    describe "without service commands" do

      before(:each) do
        @ctl = Omnibus::Ctl.new("chef-server", false)
        @ctl.fh_output = StringIO.new
      end

      it "should contain the service commands in the top-level of the result" do
        standard_commands.each do |cmd|
          expect(@ctl.get_all_commands_hash.has_key?(cmd)).to eq(true)
        end
      end

      it "should not contain the service commands in the top-level of the result" do
        service_commands.each do |cmd|
          expect(@ctl.get_all_commands_hash.has_key?(cmd)).to eq(false)
        end
      end
    end
  end

  describe "category_command_map" do
    standard_commands.each do |cmd|
      it "has #{cmd} by default under general category" do
        expect(@ctl.category_command_map["general"].has_key?(cmd)).to eq(true)
      end
    end

    service_commands.each do |cmd|
      it "has #{cmd} by default under service-management category" do
        expect(@ctl.category_command_map["service-management"].has_key?(cmd)).to eq(true)
      end
    end

    it "has no commands that are not tested by default" do
      @ctl.command_map.each_key do |cmd|
        expect(all_commands.include?(cmd)).to eq(true)
      end
    end

    describe "without service commands" do
      before(:each) do
        @ctl = Omnibus::Ctl.new("chef-server", false)
        @ctl.fh_output = StringIO.new
      end

      standard_commands.each do |cmd|
        it "has #{cmd} by default in general category" do
          expect(@ctl.category_command_map["general"].has_key?(cmd)).to eq(true)
        end
      end

      service_commands.each do |cmd|
        it "does not have service command #{cmd} by default" do
          expect(@ctl.command_map.has_key?(cmd)).to eq(false)
        end
      end

      it "should not have service-management category by default" do
          expect(@ctl.command_map.has_key?("service-management")).to eq(false)
      end

      it "has no commands that are not tested by default" do
        @ctl.category_command_map["general"].each_key do |cmd|
          expect(standard_commands.include?(cmd)).to eq(true)
        end
      end
    end
  end

  describe "log" do
    it "puts to the fh_output" do
      @ctl.log("you really should see this!")
      @ctl.fh_output.rewind
      expect(@ctl.fh_output.gets(nil)).to eq("you really should see this!\n")
    end
  end

  describe "help" do
    all_commands.each do |cmd|
      it "prints the #{cmd} command and description" do
        allow(@ctl).to receive(:exit!).and_return(true)
        @ctl.help
        @ctl.fh_output.rewind
        output = @ctl.fh_output.gets(nil)
        # depending on whether or not the command has a category,
        # it will have extra spaces
        expect(output).to match(/  #{Regexp.escape(cmd)}\n    #{Regexp.escape(@ctl.get_all_commands_hash[cmd][:desc])}|#{Regexp.escape(cmd)}\n  #{Regexp.escape(@ctl.get_all_commands_hash[cmd][:desc])}/) 
      end
    end

    describe "without service commands" do
      before(:each) do
        @ctl = Omnibus::Ctl.new("chef-server", false)
        @ctl.fh_output = StringIO.new
      end

      standard_commands.each do |cmd|
        it "prints the #{cmd} command and description" do
          allow(@ctl).to receive(:exit!).and_return(true)
          @ctl.help
          @ctl.fh_output.rewind
          output = @ctl.fh_output.gets(nil)
          expect(output).to match(/  #{Regexp.escape(cmd)}\n    #{Regexp.escape(@ctl.get_all_commands_hash[cmd][:desc])}|#{Regexp.escape(cmd)}\n  #{Regexp.escape(@ctl.get_all_commands_hash[cmd][:desc])}/) 
        end
      end

      service_commands.each do |cmd|
        it "does not print the #{cmd} command and description" do
          allow(@ctl).to receive(:exit!).and_return(true)
          @ctl.help
          @ctl.fh_output.rewind
          output = @ctl.fh_output.gets(nil)
          expect(output).not_to match(/#{Regexp.escape(cmd)}\n/)
        end
      end
    end

    it "exits 1" do
      expect { @ctl.help }.to raise_error(SystemExit)
    end
  end

  describe "exit!" do
    it "raises systemexit with the code specified" do
      expect { @ctl.exit! 15 }.to raise_error(SystemExit)
      exit_code = nil
      begin
        @ctl.exit! 15
      rescue SystemExit => e
        exit_code = e.status
      end
      expect(exit_code).to eq(15)
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
      expect(exit_code).to eq(1)
    end

    it "exits 2 if the command is found, but not with the arity you provided on the cli" do
      exit_code = nil
      begin
        @ctl.run(["reconfigure","not-found"])
      rescue SystemExit => e
        exit_code = e.status
      end
      expect(exit_code).to eq(2)
    end

    it "runs the method describe by the command" do
      allow(@ctl).to receive(:exit!).and_return(true)
      expect(@ctl).to receive(:help).with("help")
      @ctl.run(["help"])
    end
  end

  describe "load_files" do
    before(:each) do
      @ctl.load_files(File.join(File.dirname(__FILE__), "data"))
    end

    it "loads the files in a path, and instance_evals them" do
      @ctl.extended
      expect(@ctl.run(["extended"])).to eq(true)
      expect(@ctl.run(["arity"])).to eq(true)
    end

    it "should let you add to the help output" do
      allow(@ctl).to receive(:exit!).and_return(true)
      @ctl.help
      @ctl.fh_output.rewind
      output = @ctl.fh_output.gets(nil)
      expect(output).to match(/#{Regexp.escape("extended")}\n  #{Regexp.escape("Extended omnibus-ctl")}/)
    end

    it "should let a loaded command declare arity" do
      expect(@ctl.run(["arity", "some-arg"])).to eq(true)
    end

    it "should allow loaded commands with dashes in the name" do
      expect(@ctl.run(["name-with-dashes"])).to eq(true)
    end
  end

  describe "run_sv_command" do
    before(:each) do
      allow(@ctl).to receive(:get_all_services).and_return(["erchef", "chef-solr"])
      allow(@ctl).to receive(:global_service_command_permitted).and_return(true)
      allow(@ctl).to receive(:exit!).and_return(true)
    end

    context "without a service" do
      it "should run the command against all services" do
        ["erchef", "chef-solr"].each do |service|
          expect(@ctl)
            .to receive(:run_sv_command_for_service)
            .with("stop", service)
            .and_return(0)
        end
        @ctl.run_sv_command("stop")
      end

      it "exits with the sum of all the status codes" do
        ["erchef", "chef-solr"].each do |service|
          expect(@ctl)
            .to receive(:run_sv_command_for_service)
            .with("status", service)
            .and_return(1)
        end
        expect(@ctl).to receive(:exit!).with(2)
        @ctl.run_sv_command("status")
      end

      it "should check the command is permitted globally" do
        ["erchef", "chef-solr"].each do |service|
          expect(@ctl)
            .to receive(:global_service_command_permitted)
            .with("status", service)
            .and_return(true)
          expect(@ctl)
            .to receive(:run_sv_command_for_service)
            .with("status", service)
            .and_return(0)
        end
        @ctl.run_sv_command("status")
      end

      context "when the command is not permitted globally" do
        before(:each) do
          allow(@ctl).to receive(:global_service_command_permitted).and_return(false)
        end

        it "should not execute the service command" do
          expect(@ctl).not_to receive(:run_sv_command_for_service)
          @ctl.run_sv_command("status")
        end
      end
    end

    context "with a service" do
      it "should run the command against just one service" do
        expect(@ctl)
          .to receive(:run_sv_command_for_service)
          .with("stop", "erchef")
          .and_return(0)
        expect(@ctl)
          .not_to receive(:run_sv_command_for_servcie)
          .with("stop", "chef_solr")
        @ctl.run_sv_command("stop", "erchef")
      end

      it "exits with the status code of the service command" do
        expect(@ctl)
          .to receive(:run_sv_command_for_service)
          .with("status", "erchef")
          .and_return(3)
        expect(@ctl).to receive(:exit!).with(3)
        @ctl.run_sv_command("status", "erchef")
      end

      it "should not check if the service is permitted globally" do
        expect(@ctl).not_to receive(:global_service_command_permitted)
        expect(@ctl)
          .to receive(:run_sv_command_for_service)
          .with("status", "erchef")
          .and_return(0)
        @ctl.run_sv_command("status", "erchef")
      end
    end
  end

  describe "run_sv_command_for_service" do
    before(:each) do
      @status = double(Process::Status)
      allow(@status).to receive(:exitstatus).and_return(0)
    end

    context "when service is enabled" do
      before(:each) do
        allow(@ctl).to receive(:service_enabled?).and_return(true)
      end

      it "runs the service command from init" do
        expect(@ctl)
          .to receive(:run_command)
          .with("/opt/chef-server/init/erchef start")
          .and_return(@status)
        @ctl.run_sv_command_for_service("start", "erchef")
      end

      it "returns the status code of the service command" do
        allow(@ctl).to receive(:run_command).and_return(@status)
        expect(@ctl.run_sv_command_for_service("start", "erchef")).to eq(0)
      end

      context "when the command fails" do
        it "should return a non-zero status code" do
          allow(@status).to receive(:exitstatus).and_return(3)
          allow(@ctl).to receive(:run_command).and_return(@status)
          expect(@ctl.run_sv_command_for_service("start", "erchef")).to eq(3)
        end
      end
    end

    context "when the service is disabled" do
      before(:each) do
        allow(@ctl).to receive(:service_enabled?).and_return(false)
      end

      context "and the sv_cmd is 'status'" do
        it "should not run the 'status' command" do
          expect(@ctl).not_to receive(:run_command)
          @ctl.run_sv_command_for_service("status", "erchef")
        end

        it "should return 0" do
          expect(@ctl.run_sv_command_for_service("status", "erchef")).to eq(0)
        end

        it "should not log that the service is disabled" do
          expect(@ctl).not_to receive(:log)
          @ctl.run_sv_command_for_service("status", "erchef")
        end

        context "and verbose logging is on" do
          before(:each) do
            allow(@ctl).to receive(:verbose).and_return(true)
          end

          it "should log that the service is disabled" do
            expect(@ctl)
              .to receive(:log)
              .with("erchef disabled")
            @ctl.run_sv_command_for_service("status", "erchef")
          end
        end
      end

      ["start", "stop", "restart"].each do |sv_cmd|
        context "and the sv_cmd is '#{sv_cmd}'" do
          it "should not run the '#{sv_cmd}' command" do
            expect(@ctl).not_to receive(:run_command)
            @ctl.run_sv_command_for_service(sv_cmd, "erchef")
          end

          it "should return 0" do
            expect(@ctl.run_sv_command_for_service(sv_cmd, "erchef")).to eq(0)
          end

          it "should not log that the service is disabled" do
            expect(@ctl).not_to receive(:log)
            @ctl.run_sv_command_for_service(sv_cmd, "erchef")
          end

          context "and verbose logging is on" do
            before(:each) do
              allow(@ctl).to receive(:verbose).and_return(true)
            end

            it "should not log that the service is disabled" do
              expect(@ctl).not_to receive(:log)
              @ctl.run_sv_command_for_service(sv_cmd, "erchef")
            end
          end
        end
      end
    end
  end

  describe "global_service_command_permitted" do
    let(:removed_services) { ["chef-gone", "chef-bye", "couchdb"] }
    let(:hidden_services)  { ["archer", "lana", "opscode-chef-mover"] }

    before(:each) do
      allow(@ctl).to receive(:removed_services).and_return(removed_services)
      allow(@ctl).to receive(:hidden_services).and_return(hidden_services)
    end

    context "for hidden services" do
      it "should allow all commands besides status" do
        valid_commands = service_commands - ["status"]
        hidden_services.product(["status"]).each do |svc, cmd|
          expect(@ctl.global_service_command_permitted(cmd, svc)).to eq(false)
        end
        hidden_services.product(valid_commands).each do |svc, cmd|
          expect(@ctl.global_service_command_permitted(cmd, svc)).to eq(true)
        end
      end
    end

    context "for removed services" do
      it "should only allow the stop command" do
        invalid_commands = service_commands - ["stop"]
        removed_services.product(invalid_commands).each do |svc, cmd|
          expect(@ctl.global_service_command_permitted(cmd, svc)).to eq(false)
        end
        removed_services.product(["stop"]).each do |svc, cmd|
          expect(@ctl.global_service_command_permitted(cmd, svc)).to eq(true)
        end
      end
    end

    context "for the keepalived service" do
      it "should only allow the status command" do
        invalid_commands = service_commands - ["status"]
        invalid_commands.each do |cmd|
          expect(@ctl.global_service_command_permitted(cmd, "keepalived")).to eq(false)
        end
        expect(@ctl.global_service_command_permitted("status", "keepalived")).to eq(true)
      end
    end

    context "for other services" do
      it "should allow all of the service commands" do
        services = ["chef", "postgresql", "bookshelf"]
        services.product(service_commands).each do |svc, cmd|
          expect(@ctl.global_service_command_permitted(cmd, svc)).to eq(true)
        end
      end
    end
  end

  describe "removed_services" do
    it "should load the services from the running config" do
      expect(@ctl).to receive(:running_config) do
        {
          "chef_server" => {
            "removed_services" => ["couchdb", "mysql"]
          }
        }
      end
      expect(@ctl.removed_services()).to eq(["couchdb", "mysql"])
    end

    context "when removed services are not configured" do
      before(:each) do
        allow(@ctl).to receive(:running_config)  do
          {"chef_server" => {}}
        end
      end

      it "should return an empty array" do
        expect(@ctl.removed_services).to eq([])
      end
    end

    context "when #running_config returns nil" do
      before(:each) do
        allow(@ctl).to receive(:running_config).and_return(nil)
      end

      it "should return an empty array" do
        expect(@ctl.removed_services).to eq([])
      end
    end
  end

  describe "running_config" do
    let(:file_path) { "/etc/chef-server/chef-server-running.json" }
    let(:file_contents) do
      <<EOF
{"chef_server": {"attr1":true,"removed_services":["sv1","sv2"]}}
EOF
end

    it "checks if the file exists" do
      expect(File).to receive(:exists?).with(file_path).and_return(false)
      @ctl.running_config
    end

    context "when the file exists" do
      before(:each) do
        allow(File).to receive(:exists?).and_return(true)
      end

      it "should return the parsed contents of the file" do
        expect(File)
          .to receive(:read)
          .with(file_path)
          .and_return(file_contents)
        expected = { "chef_server" =>
          { "attr1" => true,
            "removed_services" => ["sv1", "sv2"]
          }
        }
        expect(@ctl.running_config).to eq(expected)
      end
    end

    context "when the file doesn't exist" do
      before(:each) do
        allow(File).to receive(:exists?).and_return(false)
      end

      it "should return nil" do
        expect(@ctl.running_config).to eq(nil)
      end
    end
  end

  describe "package_name" do
    context "when @name == 'opscode'" do
      before(:each) do
        @ctl.name = "opscode"
      end

      it "returns 'private-chef'" do
        expect(@ctl.package_name).to eq("private-chef")
      end
    end

    context "for other names" do
      it "should return the configured name" do
        %w{chef-server opscode-manage opscode-analytics}.each do |package|
          @ctl.name = package
          expect(@ctl.package_name).to eq(package)
        end
      end
    end
  end
end
