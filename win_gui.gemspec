Gem::Specification.new do |gem|
  gem.name        = "win_gui"
  gem.version     = File.open('VERSION').read.strip
  gem.summary     = %q{Work with Windows GUI in an object-oriented way}
  gem.description = %q{Work with Windows GUI in an object-oriented way. Abstractions/wrappers around GUI-related Win32 API functions}
  gem.authors     = ["arvicco"]
  gem.email       = "arvitallian@gmail.com"
  gem.homepage    = %q{http://github.com/arvicco/win_gui}
  gem.platform    = Gem::Platform::RUBY
  gem.date        = Time.now.strftime "%Y-%m-%d"

  # Files setup
  versioned         = `git ls-files -z`.split("\0")
  gem.files         = Dir['{bin,lib,man,spec,features,tasks}/**/*', 'Rakefile', 'README*', 'LICENSE*',
                      'VERSION*', 'CHANGELOG*', 'HISTORY*', 'ROADMAP*', '.gitignore'] & versioned
  gem.executables   = (Dir['bin/**/*'] & versioned).map{|file|File.basename(file)}
  gem.test_files    = Dir['spec/**/*'] & versioned
  gem.require_paths = ["lib"]

  # RDoc setup
  gem.has_rdoc = true
  gem.rdoc_options.concat %W{--charset UTF-8 --main README.rdoc --title win_gui}
  gem.extra_rdoc_files = ["LICENSE", "HISTORY", "README.rdoc"]
    
  # Dependencies
  gem.add_development_dependency("rspec", [">= 1.2.9"])
  gem.add_development_dependency("cucumber", [">= 0"])
  gem.add_dependency("win", [">= 0.3.26"])
end

