package jbundler;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.maven.repository.internal.MavenRepositorySystemSession;
import org.apache.maven.repository.internal.MavenServiceLocator;
import org.sonatype.aether.RepositorySystem;
import org.sonatype.aether.RepositorySystemSession;
import org.sonatype.aether.artifact.Artifact;
import org.sonatype.aether.collection.CollectRequest;
import org.sonatype.aether.collection.DependencyCollectionException;
import org.sonatype.aether.connector.wagon.WagonProvider;
import org.sonatype.aether.connector.wagon.WagonRepositoryConnectorFactory;
import org.sonatype.aether.graph.Dependency;
import org.sonatype.aether.graph.DependencyNode;
import org.sonatype.aether.impl.internal.DefaultServiceLocator;
import org.sonatype.aether.repository.LocalRepository;
import org.sonatype.aether.repository.RemoteRepository;
import org.sonatype.aether.resolution.DependencyRequest;
import org.sonatype.aether.resolution.DependencyResolutionException;
import org.sonatype.aether.spi.connector.RepositoryConnectorFactory;
import org.sonatype.aether.util.graph.PreorderNodeListGenerator;

public class DependencyResolver {
    
    private DependencyNode node;
    private RepositorySystem repoSystem;
    private RepositorySystemSession session;
    private List<Artifact> artifacts = new LinkedList<Artifact>();
    private List<RemoteRepository> repos = new LinkedList<RemoteRepository>();
    
    public DependencyResolver(){
        repoSystem = newRepositorySystem();
        session = newSession( repoSystem );

        RemoteRepository central = new RemoteRepository( "central", "default", "http://repo1.maven.org/maven2/" );
        repos.add(central);
    }
    
    private RepositorySystem newRepositorySystem() {
        DefaultServiceLocator locator = new MavenServiceLocator();   
        //locator.addService( RepositoryConnectorFactory.class, FileRepositoryConnectorFactory.class );
        locator.addService( RepositoryConnectorFactory.class, WagonRepositoryConnectorFactory.class );
        locator.setServices( WagonProvider.class, new ManualWagonProvider() );

        return locator.getService( RepositorySystem.class );
    }
    
    private RepositorySystemSession newSession( RepositorySystem system ) {
        MavenRepositorySystemSession session = new MavenRepositorySystemSession();

        // TODO use settings.xml to find the right one
        LocalRepository localRepo = new LocalRepository( System.getProperty("user.home") + "/.m2/repository" );
        session.setLocalRepositoryManager( system.newLocalRepositoryManager( localRepo ) );

        return session;
    }
    
    public void addArtifact(Artifact artifact){
        artifacts.add(artifact);
    }
    
    public void addRepository(RemoteRepository repo){
        repos.add(repo);
    }
    
    public void resolve() throws DependencyCollectionException, DependencyResolutionException {
        if (artifacts.size() == 0){
            throw new IllegalArgumentException("no artifacts given");
        }
       
        CollectRequest collectRequest = new CollectRequest();

        for( Artifact a: artifacts ){
            collectRequest.addDependency( new Dependency( a, "compile" ) );
        }
        
        for( RemoteRepository r: repos ){
            collectRequest.addRepository( r );            
        }
        
        node = repoSystem.collectDependencies( session, collectRequest ).getRoot();

        DependencyRequest dependencyRequest = new DependencyRequest( node, null );

        repoSystem.resolveDependencies( session, dependencyRequest  );
    }

    public List<RemoteRepository> getRepositories(){
        return repos;
    }
    
    public String getClasspath() {
        PreorderNodeListGenerator nlg = new PreorderNodeListGenerator();
        node.accept( nlg );
        
        StringBuilder buffer = new StringBuilder( 1024 );

        for ( Iterator<DependencyNode> it = nlg.getNodes().iterator(); it.hasNext(); )
        {
            DependencyNode node = it.next();
            if ( node.getDependency() != null )
            {
                Artifact artifact = node.getDependency().getArtifact();
                // skip pom artifacts
                if ( artifact.getFile() != null && !"pom".equals(artifact.getExtension()))
                {
                    buffer.append( artifact.getFile().getAbsolutePath() );
                    if ( it.hasNext() )
                    {
                        buffer.append( File.pathSeparatorChar );
                    }
                }
            }
        }

        return buffer.toString();
    }
    
    public Map<String, List<String>> getDependencyMap() {
        Map<String, List<String>> result = new HashMap<String, List<String>>();
        
        PreorderNodeListGenerator nlg = new PreorderNodeListGenerator();
        node.accept( nlg );
        
        for ( DependencyNode node: nlg.getNodes() )
        {
            if ( node.getDependency() != null )
            {
                Artifact artifact = node.getDependency().getArtifact();
                if ( artifact.getFile() != null)
                {
                    String coord = artifact.getGroupId() + ":" + artifact.getArtifactId() + " (" + artifact.getVersion() + ")";
                    List<String> deps = new ArrayList<String>(node.getChildren().size());
                    for(DependencyNode n : node.getChildren()){
                        Artifact a = n.getDependency().getArtifact();
                        deps.add(a.getGroupId() + ":" + a.getArtifactId());
                    }
                    result.put(coord, deps);
                }
            }
        }

        return result;
    }
}