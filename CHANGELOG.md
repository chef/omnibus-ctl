# Change Log

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
