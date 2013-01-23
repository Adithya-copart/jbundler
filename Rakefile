#-*- mode: ruby -*-

require 'ruby-maven'
require 'fileutils'

task :default => [ :minispec]

task :build do
  rmvn = Maven::Ruby::Maven.new
  rmvn.options['-Dmaven.test.skip'] = true
  if rmvn.exec('package')
    puts 'you find the gem inside "target"'
  else
    raise 'failed'
  end
end

task :compile do
  rmvn = Maven::Ruby::Maven.new
  rmvn.options['-Dmaven.test.skip'] = true
  # compiles java sources and build the jar
  unless rmvn.exec('prepare-package')
    raise 'failed'
  end
end

task :features => [:compile] do
  rmvn = Maven::Ruby::Maven.new
  rversion = RUBY_VERSION  =~ /^1.8./ ? '--1.8': '--1.9'
  rmvn.options['-Djruby.versions'] = '1.7.2'#JRUBY_VERSION
  rmvn.options['-Djruby.switches'] = rversion
  rmvn.options['-Djruby.18and19'] = false
  # jruby related debug log
  #rmvn.options['-Djruby.verbose'] = true
  # lots of maven debug log
  #rmvn.options['-X'] = nil
  unless rmvn.exec('cucumber')
    raise 'failed'
  end
end

task :minispec => [:compile] do
  require 'minitest/autorun'

  $LOAD_PATH << "spec"

  Dir['spec/*_spec.rb'].each { |f| require File.basename(f.sub(/.rb$/, '')) }
end

task :clean do
  FileUtils.rm_rf('target')
  FileUtils.rm_f(File.join('lib','jbundler.jar'))
end

# vim: syntax=Ruby
