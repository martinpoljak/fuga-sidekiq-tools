# encoding: utf-8

Gem::Specification.new do |s|
    
  # base meta
  s.name = 'fuga-sidekiq-tools'
  s.version = "0.1.0"
  s.date = '2016-10-12'
  s.license = "MIT"
  s.summary = "Adds middlewares and API for job status change notifications and error handling per error type."

  # author
  s.author = "Martin Poljak"
  s.email = 'martin@poljak.cz'
  s.homepage = "https://github.com/martinkozak/fuga-sidekiq-tools"
  
  # files & paths
  s.bindir = 'bin'
  s.require_paths = ["lib"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
  ]
  s.files = Dir[
    "lib/**/*",
    "bin/*",
    "LICENSE.txt",
    "README.md",
  ]
 
  # dependencies
  s.add_runtime_dependency(%q<sidekiq>, [">= 4.0.0"])
  s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
  s.add_development_dependency(%q<riot>, [">= 0.12.1"])

end