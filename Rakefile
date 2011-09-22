require 'rake/testtask'
require './lib/clive/output'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Run tests on for all versions of ruby'
task :test_all do  
  `rbenv versions --bare`.split("\n").each do |vers|
    run_for vers, ['bundle install', 'bundle exec rake']
  end
end

def run_for(vers, commands)
  system "RBENV_VERSION='#{vers}' sh -c '#{commands.map {|i| "rbenv exec #{i}"}.join(' && ')}'"
end

task :default => :test
