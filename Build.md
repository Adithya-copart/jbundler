# build jbundler #

the build uses ruby-maven

```jruby -S gem install ruby-maven'```

to build the jar for the lib directory (prepare the jar before packaging the gem)

```rmvn prepare-package```

to build the gem in **target/jbundler-0.0.1.gem**

```rmvn package```

or once the jar file is in place then

```gem build jbundler.gemspec```

will do as well.

## pom.xml for the IDE ##

the pom.xml is generated from the *jbundler.gemspec* and *Mavenfile*. it will be written out to *jbundler.gemspec.pom*. in case the IDE needs a pom.xml just set a symbolic link.

## proper maven ##

once ```rmvn``` generated the pom.xml proper maven3 can do the same job as rmvn. in the end rmvn is just ruby wrapper around maven3.
