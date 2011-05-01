require "rake/testtask"
require "echoe"

task :default => :test

Echoe.new('pbar', '0.1') do |p|
  p.description    = "Progress tracking command line utilities"
  p.url            = "https://github.com/antivanov/pbar"
  p.author         = "Anton Ivanov"
  p.email          = "anton.al.ivanov@gmail.com"
  p.ignore_pattern = []
  p.development_dependencies = []
end

Rake::TestTask.new(:test) do |test|
    test.test_files = Dir[ "test/*_test.rb" ]
    test.verbose = true
end
