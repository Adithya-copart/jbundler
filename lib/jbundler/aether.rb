require 'yaml'
require 'jbundler/config'

module JBundler

  class AetherRuby

    def self.setup_classloader
      require 'java'

      maven_home = File.dirname(File.dirname(Gem.bin_path('ruby-maven', 
                                                           'rmvn')))
      # TODO reduce to the libs which are really needed
      Dir.glob(File.join(maven_home, 'lib', "*jar")).each {|path| require path }
      begin
        require 'jbundler.jar'
      rescue LoadError
        # allow the classes already be added to the classloader
        begin
          java_import 'jbundler.Aether'
        rescue NameError
          # assume this happens only when working on the git clone
          raise "jbundler.jar is missing - maybe you need to build it first ? use\n$ rmvn prepare-package -Dmaven.test.skip\n"
        end
      end
      java_import 'jbundler.Aether'
    end

    def initialize( config = Config.new )
      unless defined? Aether
        self.class.setup_classloader
      end
      @aether = Aether.new( config.verbose )
      @aether.add_proxy( config.proxy ) if config.proxy
      @aether.add_mirror( config.mirror ) if config.mirror
      @aether.offline = config.offline
      @aether.user_settings = config.settings if config.settings
      @aether.local_repository = config.local_repository if config.local_repository
    rescue NativeException => e
      e.cause.print_stack_trace
      raise e
    end

    def add_artifact(coordinate, extension = nil)
      if extension
        coord = coordinate.split(/:/)
        coord.insert(2, extension)
        @aether.add_artifact(coord.join(":"))
      else
        @aether.add_artifact(coordinate)
      end
    end

    def add_repository(name, url)
      @aether.add_repository(name, url)
    end

    def resolve
      @aether.resolve unless artifacts.empty?
    rescue NativeException => e
      e.cause.print_stack_trace
      raise e
    end

    def classpath 
      if artifacts.empty?
        ''
      else
        @aether.classpath
      end
    end
   
    def classpath_array
      classpath.split(/#{File::PATH_SEPARATOR}/)
    end
   
    def repositories
      @aether.repositories
    end

    def artifacts
      @aether.artifacts
    end

    def resolved_coordinates
      if artifacts.empty?
        []
      else
        @aether.resolved_coordinates
      end
    end

    def install(coordinate, file)
      @aether.install(coordinate, file)
    rescue NativeException => e
      e.cause.print_stack_trace
      raise e
    end
    
  end
end
