# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bio-signalp}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben J Woodcroft"]
  s.date = %q{2012-02-16}
  s.default_executable = %q{signalp.rb}
  s.description = %q{A wrapper for the signal peptide prediction algorith SignalP. Not very well supported, but seems to work for the author, at least.}
  s.email = %q{donttrustben near gmail.com}
  s.executables = ["signalp.rb"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/signalp.rb",
    "bio-signalp.gemspec",
    "lib/bio-signalp.rb",
    "lib/bio/appl/signalp.rb",
    "test/helper.rb",
    "test/test_bio-signalp.rb"
  ]
  s.homepage = %q{http://github.com/wwood/bioruby-signalp}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A wrapper for the signal peptide prediction algorith SignalP}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bio>, [">= 1.4.1"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<bio>, [">= 1.4.1"])
    else
      s.add_dependency(%q<bio>, [">= 1.4.1"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.0"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<bio>, [">= 1.4.1"])
    end
  else
    s.add_dependency(%q<bio>, [">= 1.4.1"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.0"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<bio>, [">= 1.4.1"])
  end
end

