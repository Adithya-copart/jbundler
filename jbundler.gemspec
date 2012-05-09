Gem::Specification.new do |s|
  s.name = 'jbundler'
  s.version = '0.1.0'

  s.summary = 'bundler support for maven or/and maven support for bundler'
  s.description = <<-END
using embedded maven to add jar support to bundler and add bundler like handling of version ranges to maven
END

  s.authors = ['Kristian Meier']
  s.email = ['m.kristian@web.de']

  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['MIT-LICENSE'] + Dir['*.md']
  s.files += Dir['Gemfile*']
  s.test_files += Dir['spec/**/*_spec.rb']

  s.add_runtime_dependency "ruby-maven", "= 3.0.3.0.29.0.pre"
  # TODO maybe put this as dep to ruby-maven to bind the versions better
 # s.add_runtime_dependency "maven-tools", "= 0.29.0"
end
