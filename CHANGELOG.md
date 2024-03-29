<!-- usage documentation: http://expeditor.es.chef.io/configuration/changelog/ -->

<!-- latest_release 0.6.12 -->
## [v0.6.12](https://github.com/chef/omnibus-ctl/tree/v0.6.12) (2022-08-29)

#### Merged Pull Requests
- update codeowners to include omnibus team &amp; some cleanup [#87](https://github.com/chef/omnibus-ctl/pull/87) ([vkarve-chef](https://github.com/vkarve-chef))
<!-- latest_release -->

<!-- release_rollup since=0.6.10 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- update codeowners to include omnibus team &amp; some cleanup [#87](https://github.com/chef/omnibus-ctl/pull/87) ([vkarve-chef](https://github.com/vkarve-chef)) <!-- 0.6.12 -->
- Use client CLI dist constant when executing chef runs [#86](https://github.com/chef/omnibus-ctl/pull/86) ([ramereth](https://github.com/ramereth)) <!-- 0.6.11 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v0.6.10](https://github.com/chef/omnibus-ctl/tree/v0.6.10) (2022-02-15)

#### Merged Pull Requests
- Use dist constant in package_name method [#84](https://github.com/chef/omnibus-ctl/pull/84) ([ramereth](https://github.com/ramereth))
<!-- latest_stable_release -->

## [v0.6.9](https://github.com/chef/omnibus-ctl/tree/v0.6.9) (2022-02-10)

#### Merged Pull Requests
- Update chefstyle requirement from = 2.0.9 to = 2.1.0 [#77](https://github.com/chef/omnibus-ctl/pull/77) ([dependabot[bot]](https://github.com/dependabot[bot]))
- Update chefstyle requirement from = 2.1.0 to = 2.1.1 [#78](https://github.com/chef/omnibus-ctl/pull/78) ([dependabot[bot]](https://github.com/dependabot[bot]))
- Update chefstyle requirement from = 2.1.1 to = 2.1.2 [#79](https://github.com/chef/omnibus-ctl/pull/79) ([dependabot[bot]](https://github.com/dependabot[bot]))
- Update chefstyle requirement from = 2.1.2 to = 2.2.0 [#81](https://github.com/chef/omnibus-ctl/pull/81) ([dependabot[bot]](https://github.com/dependabot[bot]))
- Replace hardcode of server status json [#83](https://github.com/chef/omnibus-ctl/pull/83) ([aleksey-hariton](https://github.com/aleksey-hariton))

## [v0.6.4](https://github.com/chef/omnibus-ctl/tree/v0.6.4) (2021-10-15)

#### Merged Pull Requests
- Use the variable for release_branch [#74](https://github.com/chef/omnibus-ctl/pull/74) ([tas50](https://github.com/tas50))
- Chefstyle the lib and bin dirs [#75](https://github.com/chef/omnibus-ctl/pull/75) ([tas50](https://github.com/tas50))
- Chefstyle everything else [#76](https://github.com/chef/omnibus-ctl/pull/76) ([tas50](https://github.com/tas50))



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