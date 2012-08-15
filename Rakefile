# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "bio-signalp"
  gem.homepage = "http://github.com/wwood/bioruby-signalp"
  gem.license = "MIT"
  gem.summary = %Q{A wrapper for the signal peptide prediction algorith SignalP}
  gem.description = %Q{A wrapper for the signal peptide prediction algorith SignalP. Not very well supported, but seems to work for the author, at least.}
  gem.email = "donttrustben near gmail.com"
  gem.authors = ["Ben J Woodcroft"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
