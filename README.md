# omnibus-ctl

[![unit](https://github.com/chef/omnibus-ctl/actions/workflows/unit.yml/badge.svg)](https://github.com/chef/omnibus-ctl/actions/workflows/unit.yml)

omnibus-ctl provides service control and configuration for omnibus packages.

For an introduction, please see this blog post [Omnibus-ctl: What is it and what can it do for you?](https://www.chef.io/blog/2015/05/26/omnibus-ctl-what-is-it-and-what-can-it-do-for-you/).

## Run the Tests!

There are tests in this repo that should be run before merging to master in the `spec` directory.

To run them, first install rspec via bundler:

```
bundle install
```

Then run the tests:

```
bundle exec rake
```

## Command API

There are two main functions you will use in your `*-ctl` project to add commands.

### add_command_under_category(string, string, string, int, ruby_block)

This method will add a new command to your ctl under a category, useful for grouping similar commands together logically in help output.

Input arguments:

1. Name of the command.
2. Category of the command. It should be string consisting of only characters and "-". If the category does not exist, it will be added. Default categories are "general" and "service-management" (if the latter is enabled).
3. Description. This will be outputted below the command name when the help command is run.
4. Arity. TODO: Due to current bug, this must be 2, I believe. We should fix this.
5. Ruby block. Ruby code to be executed when your command is run (arguments to that command will be passed into the block).

### add_command(string, string, int, ruby_block)

This method will add a new command to your ctl without a category. It will be displayed above all categories when the help command is called.

Input arguments are the same as `add_command_under_category` except 2 doesn't exist.

### Sample Output

```
# sample-ctl help
/opt/opscode/embedded/bin/sample-ctl: command (subcommand)
command-without-category
  Here is an insightful description for the above command, added via add_command.
another-command-without-category
  Yet another description.
Some Category Of Commands:
  command-with-category
    Exciting description of command added via add_command_under_category.
  better-command-with-category
    You get the idea.
Another Category:
  command-with-better-category
    I'm not just going to copy-pasta above example descriptions.
  better-command-with-better-category
    I'm running out of ideas.
```

If you only use `add_command_under_category` to add your custom commands, everything will be outputted under a category.

## Pre-hook API

### add_global_pre_hook(string, ruby_block)

This method will add a global pre-hook block that will be executed before any
*-ctl command is run. If the pre-hook raises an exception it will cause an early
exit before the command is run.

Input Arguments:

1. Name of the hook
1. Ruby block of the code to be executed.

### Sample

```ruby
add_global_pre_hook "ensure that the user is always root" do
  raise "You must run this command as root" unless Process.uid == 0
end
```

## Releasing

*NOTE: Versions prior to 0.3.6 do not use a "v" prefix for their tags. Current
versions do.*

* Update the version in lib/omnibus-ctl/version.rb.
* Update the [Change log](CHANGELOG.md).
* Commit those changes.
* Make sure you are an owner of the
  [omnibus-ctl gem on RubyGems.org](https://rubygems.org/gems/omnibus-ctl). If
  you aren't, contact one of the owners to be added.
* `rake release`. This will tag the version, push it to GitHub and RubyGems.

## License

See the LICENSE file for details.

Copyright: Copyright (c) Chef Software, Inc.
License: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
