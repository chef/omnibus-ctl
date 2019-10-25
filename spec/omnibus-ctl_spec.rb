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
  let(:file_path) { "/etc/chef-server/chef-server-running.json" }
  let(:config_hash) do
    { 'chef_server' => { 'attr1' => true,
                         'removed_services' => ['sv1','sv2'],
                         'service1' =>  {'test' => true  },
                         'service2' =>  {'external' => true, 'test' => true  },
                         'service3' =>  {'external' => false }
                       }
    }
  end
  let(:file_contents) { config_hash.to_json}

  def ctl_output
    @ctl.fh_output.rewind
    @ctl.fh_output.gets(nil)
  end

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
    it "sets a proper descriptive name when provided" do
      expect(Omnibus::Ctl.new("chef-server", false, "Chef Server").display_name).to eq("Chef Server")
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

      it "should contain the standard commands in the top-level of the result" do
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
      expect(ctl_output).to eq("you really should see this!\n")
    end
  end

  describe "help" do
    all_commands.each do |cmd|
      it "prints the #{cmd} command and description" do
        @ctl.help
        # depending on whether or not the command has a category,
        # it will have extra spaces
        expect(ctl_output).to match(/  #{Regexp.escape(cmd)}\n    #{Regexp.escape(@ctl.get_all_commands_hash[cmd][:desc])}|#{Regexp.escape(cmd)}\n  #{Regexp.escape(@ctl.get_all_commands_hash[cmd][:desc])}/)
      end
    end

    describe "without service commands" do
      before(:each) do
        @ctl = Omnibus::Ctl.new("chef-server", false)
        @ctl.fh_output = StringIO.new
      end

      standard_commands.each do |cmd|
        it "prints the #{cmd} command and description" do
          @ctl.help
          expect(ctl_output).to match(/  #{Regexp.escape(cmd)}\n    #{Regexp.escape(@ctl.get_all_commands_hash[cmd][:desc])}|#{Regexp.escape(cmd)}\n  #{Regexp.escape(@ctl.get_all_commands_hash[cmd][:desc])}/)
        end
      end

      service_commands.each do |cmd|
        it "does not print the #{cmd} command and description" do
          @ctl.help
          expect(ctl_output).not_to match(/#{Regexp.escape(cmd)}\n/)
        end
      end
    end

    it "exits 0" do
      expect(@ctl.help).to eq(0)
    end
  end
  describe "exit!" do before(:each) do
      # These commands need to be defined in the context of Ctl
      # in order to use the exit! function we define Ctl.
      @ctl.load_file(File.join(File.dirname(__FILE__), "data", "extend.rb"))
    end

    it "when invoked will cause a command to raise systemexit upon completion for non-zero exit code" do
      expect{@ctl.run(["exit-non-zero"])}.to raise_error do |error|
        expect(error).to be_a(SystemExit)
        expect(error.status).to eq(10)
      end
    end

    it "when invoked by a  command, will cause that command to raise systemexit upon completion for zero exit code" do
      expect{@ctl.run(["exit-zero"])}.to raise_error do |error|
        expect(error).to be_a(SystemExit)
        expect(error.status).to eq(0)
      end
    end
    it "when not invoked by a command will cause that command to return its exit code without raising SystemExit" do
      expect{@ctl.run(["clean-exit"])}.not_to raise_error
    end
  end

  describe "run" do
    it "exits 1 if the command is not found" do
      begin
        @ctl.run(["I-do-not-exist"])
      rescue SystemExit => e
       exit_code = e.status
      end
      expect(exit_code).to eq(1)
    end

    it "exits 2 if the command is found, but not with the arity you provided on the cli" do
      begin
        @ctl.run(["uninstall", "not-found"])
      rescue SystemExit => e
       exit_code = e.status
      end
      expect(exit_code).to eq(2)
    end

    it "exits 0 if the command is --help" do
      expect {
        @ctl.run(["--help"])
      }.to raise_error { |error|
        expect(error.status).to eq(0)
      }
    end

    it "runs the method describe by the command" do
      expect(@ctl).to receive(:help).with("help")
      @ctl.run(["help"])
    end

    context "handles nil returns correctly" do
      before (:each) do
        @ctl.load_file(File.join(File.dirname(__FILE__), "data", "extend.rb"))
      end

      it "returns 0 if a called command returns nil" do
        expect(@ctl.run(["return-nil"])).to eq(0)
      end

      it "raises a 0-value if called command force-exists with nil" do
          expect{@ctl.run(["exit-nil"])}.to raise_error do |error|
            expect(error).to be_a(SystemExit)
            expect(error.status).to eq(0)
          end
      end
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

      context "checking for status" do
        before (:each) do
          ["erchef", "chef-solr"].each do |service|
            expect(@ctl)
              .to receive(:run_sv_command_for_service)
              .with("status", service)
              .and_return(1)
          end
        end
        it "returns the sum of all the status codes when invoked directly" do
          expect(@ctl.run_sv_command("status")).to eq(2)
        end
        it "when invoked via 'run' it SystemExits with the sum of all status codes" do
          expect{@ctl.run(["status"])}.to raise_error do |error|
            expect(error).to be_a(SystemExit)
            expect(error.status).to eq(2)
          end
        end
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

      it "returns the status code of the service command" do
        expect(@ctl)
          .to receive(:run_sv_command_for_service)
          .with("status", "erchef")
          .and_return(3)
        expect(@ctl.run_sv_command("status", "erchef")).to eq(3)
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


  context "command_pre_hook" do
    it "gets correctly invoked before a valid command is run" do
      expect(@ctl)
          .to receive(:command_pre_hook)
          .with("status", "service1")
          .and_return(true)
      expect{@ctl.run(["status", "service1"])}.to raise_error do |error|
        expect(error).to be_a(SystemExit)
        expect(error.status).to eq(0)
      end
    end

    it "when a pre-hook returns true, the original command is run" do
      allow(@ctl)
          .to receive(:command_pre_hook)
          .with("reconfigure")
          .and_return(true)
      expect(@ctl)
          .to receive(:reconfigure)
      @ctl.run(["reconfigure"])
    end

    it "when a pre-hook returns false, the original command is not run and an exit is raised" do
      allow(@ctl)
            .to receive(:command_pre_hook)
            .with("reconfigure")
            .and_return(false)

      expect(@ctl)
          .to_not receive(:reconfigure)

      expect{ @ctl.run(["reconfigure"]) }.to raise_error(SystemExit)
    end

  end
  context "command_post_hook" do
    it "gets invoked after a valid command is run successfully" do
      allow(@ctl).to receive(:reconfigure).and_return(0)
      expect(@ctl).to receive(:command_post_hook).with("reconfigure")
      @ctl.run(["reconfigure"])
    end

    it "gets invoked invoked after a valid command is run unsuccessfully" do
      allow(@ctl).to receive(:reconfigure) .and_return(1)
      expect(@ctl).to receive(:command_post_hook).with("reconfigure")
      @ctl.run(["reconfigure"])

    end

    it "does not get invoked after an invalid command is attempted" do
      expect(@ctl).to_not receive(:command_post_hook)
      expect{@ctl.run(["nice-try"])}.to raise_error(SystemExit)
    end
  end

  context "global pre hooks" do
    before(:each) do
      @ctl.load_file(File.join(File.dirname(__FILE__), "data", "global_pre_hook.rb"))
    end

    it "registers the global pre hooks" do
      expect(@ctl.send(:instance_variable_get, :@global_pre_hooks).count)
        .to eq(1)
      @ctl.add_global_pre_hook("another-global-pre-hook") { true }
      expect(@ctl.send(:instance_variable_get, :@global_pre_hooks).count)
        .to eq(2)
    end

    it "invokes pre hooks before any command is run" do
      expect(@ctl)
        .to receive(:run_global_pre_hooks)
        .and_return(true)
      expect { @ctl.run(%w{status service1}) }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end

    it "runs the desired command after the prehooks are run" do
      allow(@ctl)
        .to receive(:run_global_pre_hooks)
        .and_return(true)
      expect(@ctl)
          .to receive(:reconfigure)
      @ctl.run(%w{reconfigure})
    end
  end

  describe "cleanse" do
    before(:each) do
      # No-op everything cleanup_procs_and_nuke wants to do, it's destructive
      # (and slow/sleep-laden):
      allow(@ctl).to receive("cleanup_procs_and_nuke").and_return 0
    end

    it "should invoke the cleanse_post_hook" do
      expect(@ctl).to receive("command_post_hook")
      @ctl.run(["cleanse", "yes"])
    end

    it "should invoke the scary_cleanse_warning" do
      expect(@ctl).to receive("scary_cleanse_warning")
      @ctl.run(["cleanse", "yes"])
    end

    context "scary_cleanse_warning" do
      before :each do
        @ctl.fh_output = StringIO.new
        # Never let the sleep happen
        allow(@ctl).to receive(:sleep)
      end

      it "should always output a stop and read header, regardless of whether or not it's told to bypass delay" do
        @ctl.scary_cleanse_warning("cleanse", "yes")
        expect(ctl_output).to match(/STOP AND READ/)

        @ctl.scary_cleanse_warning("cleanse")
        expect(ctl_output).to match(/STOP AND READ/)
      end

      it "will output a last chance to stop and wait for 60s if not told 'yes'" do
        expect(@ctl).to receive(:sleep)
        @ctl.scary_cleanse_warning("cleanse")
        expect(ctl_output).to match(/seconds to/)
      end

      it "will not output a last chance stop, nor will it wait for 60s if not told  'yes'" do
        expect(@ctl).to_not receive(:sleep)
        @ctl.scary_cleanse_warning("cleanse", "yes")
        expect(ctl_output).to_not match(/seconds to/)
      end

      it "will warn that external data will be deleted when --with-external is specied" do
        allow(ARGV).to receive("include?").with("--with-external").and_return true
        @ctl.scary_cleanse_warning("cleanse")
        expect(ctl_output).to match(/will also delete externally hosted/)
      end

      it "will not warn about deleting external data when --with-external is not set" do
        @ctl.scary_cleanse_warning("cleanse")
        expect(ctl_output).not_to match(/will also delete externally hosted/)
      end

      it "will suggest using --with-external if any external services exist and --with-external is not provided" do
        allow(@ctl).to receive(:external_services).and_return({not: "empty"})
        @ctl.scary_cleanse_warning("cleanse")
        #expect(ctl_output).to match(/--with-external/)
      end

      it "will not mention --with-external if no external services exist" do
        allow(@ctl).to receive(:external_services).and_return({})
        @ctl.scary_cleanse_warning("cleanse")
        expect(ctl_output).not_to match(/--with-external/)
      end

      it "will hard-stop when the operator uses Ctrl+C to exit" do
        allow(@ctl).to receive(:sleep).and_raise(Interrupt)
        expect(Kernel).to receive(:exit).with(1)
        @ctl.scary_cleanse_warning("cleanse")
      end
    end

    context "cleanse_post_hook" do
      before(:each) do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:read).and_return(file_contents)
      end

      it "should not invoke cleanse_post_hook_service for any non-external services" do
        # Make sure we don't bomb out on services that are defined true
        @ctl.external_services.each_key do |service|
          allow(@ctl).to receive("external_cleanse_#{service}").and_return 0
        end
        non_external = @ctl.running_package_config.select { |k, v| v.class == Hash and v["external"] == false }
        non_external.each_key do |service|
          expect(@ctl).to_not receive("external_cleanse_#{service}")
        end
        @ctl.run(["cleanse", "yes"])
      end

      it "invoked with --with-external should invoke cleanse_post_hook_'service' with true for each external service" do
        @ctl.external_services.each_key do |name, config|
          expect(@ctl).to receive("external_cleanse_#{name}").with(true)
        end
        allow(ARGV).to receive("include?").with("--with-external").and_return true
        @ctl.run(["cleanse", "yes"])
      end

      it "invoked without --with-external should invoke cleanse_post_hook_'service' with false for each external service'" do
        @ctl.external_services.each_key.each do |name|
          expect(@ctl).to receive("external_cleanse_#{name}").with(false)
        end
        @ctl.run(["cleanse", "yes"])
      end
    end

  end

  describe "external_services" do
    context "when there is a running_config" do
      before(:each) do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:read).and_return(file_contents)
      end
      it "contains only configuration entries with 'external=true' set" do
        expect(@ctl.external_services.length).to eql(1)
        @ctl.external_services.each do |name, settings|
          expect(settings['external']).to eq(true)
        end
      end
    end
    context "when there is no running_config" do
      before do
        allow(@ctl).to receive(:running_config).and_return(nil)
      end
      it "replies with an empty hash" do
        expect(@ctl.external_services.length).to eq(0)
      end
    end
  end

  describe "service_external?" do
    before(:each) do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:read).and_return(file_contents)
    end

    it "replies 'true' when a service is not defined in config" do
      expect(@ctl.service_external? "invalid-service").to eql(false)

    end
    it "replies 'true' when a service is defined in config with 'external = true'" do
      expect(@ctl.service_external? "service2").to eql(true)
    end
    it "replies 'false' when a service is defined in config without specifying 'external'" do
      expect(@ctl.service_external? "service1").to eql(false)
    end
    it "replies 'false' when a service is defined in config with 'external = false'" do
      expect(@ctl.service_external? "service3").to eql(false)
    end
  end

  describe "running_config" do
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
        expect(@ctl.running_config).to eq(config_hash)
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

  context "running_package_config" do
      before(:each) do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:read).and_return(file_contents)
      end
      it "returns {} when the package name isn't present in config" do
        allow(@ctl).to receive(:package_name).and_return('bad_package')
        expect(@ctl.running_package_config).to eq({})
      end
      it "returns {} when there is no running config" do
        allow(File).to receive(:exists?).and_return(false)
        expect(@ctl.running_package_config).to eq({})
      end
      it "return the config hash when it can find the service key provided" do

      end

  end
  context "running_service_config" do
      before(:each) do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:read).and_return(file_contents)
      end

      it "returns nil when it can't find the service key provided"  do
        expect(@ctl.running_service_config('service9')) .to eq(nil)
      end
      it "returns nil when there is no running config" do
        allow(File).to receive(:exists?).and_return(false)
        expect(@ctl.running_service_config('service1')) .to eq(nil)
      end
      it "return the config hash when it can find the service key provided" do
        expect(@ctl.running_service_config('service1')) .to eq(config_hash['chef_server']['service1'])
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

  describe "run_chef" do
    context "when verbose is on" do
      before(:each) do
        @verbose = @ctl.verbose
        @ctl.verbose = true
      end

      after(:each) do
        @ctl.verbose = @verbose
      end

      it "sets log_level to :debug" do
        expect(@ctl).to receive(:remove_old_node_state)
        expect(@ctl).to receive(:run_command).with(/-l debug/)
        @ctl.run_chef("attributes.json")
      end
    end

    context "when quiet is on" do
      before(:each) do
        @quiet = @ctl.instance_variable_get(:@quiet)
        @ctl.instance_variable_set(:@quiet, true)
      end

      after(:each) do
        @ctl.instance_variable_set(:@quiet, @quiet)
      end

      it 'sets log level to fatal' do
        expect(@ctl).to receive(:remove_old_node_state)
        expect(@ctl).to receive(:run_command).with(/-l fatal -F null/)
        @ctl.run_chef("attributes.json")
      end
    end
  end
end
