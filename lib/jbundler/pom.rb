require 'fileutils'
require 'tempfile'
require 'jbundler/maven_util'

module JBundler

  class Pom

    include MavenUtil

    private
    
    def temp_dir
      @temp_dir ||=
        begin
          d=Dir.mktmpdir
          at_exit {FileUtils.rm_rf(d.dup)}
          d
        end
    end
      
    def writeElement(xmlWriter,element_name, text)
      xmlWriter.writeStartElement(element_name.to_java)
      xmlWriter.writeCharacters(text.to_java)
      xmlWriter.writeEndElement        
    end
    
    def java_imports
      %w(
           javax.xml.stream.XMLStreamWriter
           javax.xml.stream.XMLOutputFactory
           javax.xml.stream.XMLStreamException
          ).each {|i| java_import i }
    end

    GROUP_ID = 'ruby.bundler'
    
    public
    
    def coordinate
      @coord ||= "#{GROUP_ID}:#{@name}:#{@packaging}:#{@version}"
    end
    
    def file
      @file
    end

    def initialize(name, version, deps, packaging = nil)
      unless defined? XMLOutputFactory
        java_imports
      end

      @name = name
      @packaging = packaging || 'jar'
      @version = version

      @file = File.join(temp_dir, 'pom.xml')

      out = java.io.BufferedOutputStream.new(java.io.FileOutputStream.new(@file.to_java))
      outputFactory = XMLOutputFactory.newFactory()
      xmlStreamWriter = outputFactory.createXMLStreamWriter(out)
      xmlStreamWriter.writeStartDocument
      xmlStreamWriter.writeStartElement("project")
      
      writeElement(xmlStreamWriter,"modelVersion","4.0.0")
      writeElement(xmlStreamWriter,"groupId", GROUP_ID)
      writeElement(xmlStreamWriter,"artifactId", name.to_java)
      writeElement(xmlStreamWriter,"version", version.to_s.to_java)
      writeElement(xmlStreamWriter,"packaging", packaging) if packaging
      
      xmlStreamWriter.writeStartElement("dependencies".to_java)
      
      deps.each do |line|
        if line =~ /^\s*jar\s+/ || line =~ /^\s*pom\s+/
          group_id, artifact_id, version, second_version = line.sub(/\s*pom\s+/, '').sub(/\s*jar\s+/, '').sub(/#.*/,'').gsub(/\s+/,'').gsub(/'/, '').gsub(/:/, ',').split(/,/)

          xmlStreamWriter.writeStartElement("dependency".to_java)
          writeElement(xmlStreamWriter,"groupId",group_id)
          writeElement(xmlStreamWriter,"artifactId",artifact_id)
          # default to complete version range
          mversion = second_version ? to_version(version, second_version) : to_version(version)
          writeElement(xmlStreamWriter,"version", mversion.to_s)
          
          writeElement(xmlStreamWriter,"type", "pom") if line =~ /^\s*pom\s+/
          xmlStreamWriter.writeEndElement #dependency
        end
      end
      xmlStreamWriter.writeEndElement #dependencies
      
      xmlStreamWriter.writeEndElement #project
      
      xmlStreamWriter.writeEndDocument
      xmlStreamWriter.close
      out.close
    end
    
  end
end
