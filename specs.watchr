ENV["WATCHR"] = "1"
system 'clear'

def growl(message)
  growlnotify = `which growlnotify`.chomp
  title = "Watchr Test Results"
  image = message.include?('0 failures') ? "~/Dropbox/Scripts/watchr_example/rails_ok.png" : "~/Dropbox/Scripts/watchr_example/rails_fail.png"
  options = "-w -n Watchr --image '#{File.expand_path(image)}' -m '#{message}' '#{title}'"
  system %(#{growlnotify} #{options} &)
end

def run(cmd)
  puts(cmd)
  `#{cmd}`
end

def run_spec_file(file)
  system('clear')
  result = run(%Q(rspec #{file}))
  growl result.split("\n").last rescue nil
  puts result
end

def run_all_specs
  system('clear')
  result = run "rspec spec"
  growl result.split("\n").last rescue nil
  puts result
end

def related_spec_files(path)
  puts path
  Dir['spec/*.rb'].select { |file| file =~ /#{File.basename(path).split(".").first}_spec.rb/ }
end

def run_suite
  run_all_specs
end

watch('spec/spec_helper\.rb') { run_all_specs }
watch('spec/.*_spec\.rb') { |m| run_spec_file(m[0]) }
watch('lib/.*\.rb') { |m| related_spec_files(m[0]).map {|tf| run_spec_file(tf) } }

# Ctrl-\
Signal.trap 'QUIT' do
  puts " --- Running all tests ---\n\n"
  run_all_tests
end

@interrupted = false

# Ctrl-C
Signal.trap 'INT' do
  if @interrupted then
    @wants_to_quit = true
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    run_suite
  end
end