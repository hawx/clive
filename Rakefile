require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Run tests on 1.8.7 and 1.9.2'
task :test_all do
  run_tests_for '1.8.7-p334'
  run_tests_for '1.9.2-p290'
end

def run_tests_for(version)
  system <<-BASH
    bash -c 'source ~/.rvm/scripts/rvm;
             rvm #{version};
             echo;
             echo "------------------------------------------------";
             echo "`ruby -v`";
             echo "------------------------------------------------";
             echo;
             RBXOPT="-Xrbc.db" rake 2>&1;'
  BASH
end

task :default => :test
