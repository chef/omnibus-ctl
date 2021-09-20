<!-- usage documentation: http://expeditor.es.chef.io/configuration/changelog/ -->

<!-- latest_release 0.6.4 -->
## [v0.6.4](https://github.com/chef/omnibus-ctl/tree/v0.6.4) (2021-09-20)

#### Merged Pull Requests
- Chefstyle everything else [#76](https://github.com/chef/omnibus-ctl/pull/76) ([tas50](https://github.com/tas50))
<!-- latest_release -->

<!-- release_rollup since=0.6.0 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- Chefstyle everything else [#76](https://github.com/chef/omnibus-ctl/pull/76) ([tas50](https://github.com/tas50)) <!-- 0.6.4 -->
- Chefstyle the lib and bin dirs [#75](https://github.com/chef/omnibus-ctl/pull/75) ([tas50](https://github.com/tas50)) <!-- 0.6.3 -->
- Use the variable for release_branch [#74](https://github.com/chef/omnibus-ctl/pull/74) ([tas50](https://github.com/tas50)) <!-- 0.6.2 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
<!-- latest_stable_release -->

## 0.6.0

 - Enable symlinks to be found
 - Explicitly calls help and exits 0 when omnibus-ctl is run with --help as the first argument
 - Strips out `--` to use existing help command code path
 - Add license to gemspec
 - Add global pre-hook support
 - Fix typo preventing `omnibus-ctl int <program>` from working
 - Remove SVDIR from environment if it was set
 - Explicitly set SVDIR to the service_dir
 - Quote glob patterns in find command
 - Set log_level with -l

## 0.5.0

- Add a step to view and accept a project's license to reconfigure command.
- This step can be skipped by passing --accept-license command line option to reconfigure.