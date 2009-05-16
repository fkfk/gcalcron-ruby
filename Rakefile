require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'fileutils'
require 'jeweler'
include FileUtils

$LOAD_PATH.unshift "lib"
require "gcalcron"

NAME = "gcalcron-ruby"
task :default => [:test]

Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end

Jeweler::Tasks.new do |s|
  s.name = NAME
  s.summary = ""
  s.email = "from.kyushu.island@gmail.com"
  s.homepage = "http://github.com/fkfk/gcalcron-ruby"
  s.description = ""
  s.author = "from_kyushu"
  s.add_dependency("cronedit")
  s.add_dependency("gcalapi")
end
