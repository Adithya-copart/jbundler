#-*- mode: ruby -*-

Gem::Specification.new do |s|
  s.name = 'jbundler'
  s.version = '0.8.0.pre'

  s.summary = 'managing jar dependencies'
  s.description = <<-END
managing jar dependencies with or without bundler. adding bundler like handling of version ranges for jar dependencies.
END

  s.authors = ['Christian Meier']
  s.email = ['m.kristian@web.de']
  s.homepage = 'https://github.com/mkristian/jbundler'

  s.bindir = "bin"
  s.executables = ['jbundle']

  s.license = 'MIT'

  s.files += Dir['lib/**/*.rb']
  s.files += Dir['MIT-LICENSE']
  s.files += Dir['*.md']
  s.files += Dir['Gemfile*']
  s.test_files += Dir['spec/*_spec.rb']

  s.add_runtime_dependency 'maven-tools', '~> 1.0.6'
  s.add_runtime_dependency "ruby-maven", ">= 3.1.1.0.6", "< 3.1.2"
  s.add_runtime_dependency "jar-dependencies", "~> 0.1.10"
  s.add_runtime_dependency "bundler", "~> 1.7"
  s.add_development_dependency "rake", "~> 10.0"
end
