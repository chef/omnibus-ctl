add_command("extended", "Extended omnibus-ctl") do |*args|
  log "I have extended omnibus-ctl with a new command"
  true
end

add_command("return-nil", "Something") { |*args| nil }
add_command("exit-nil", "Something") { |*args| exit! nil }
add_command("exit-non-zero", "Something") { |*args| exit! 10 }
add_command("exit-zero", "Something") { |*args| exit! 0 }
add_command('clean-exit', 'Something') { |*args| 0 }
