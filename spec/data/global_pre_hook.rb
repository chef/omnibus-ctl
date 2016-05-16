add_global_pre_hook("always-run-me-pre-hook") do
  log "I have extended omnibus-ctl with a global pre hook that runs before all commands"
  true
end
