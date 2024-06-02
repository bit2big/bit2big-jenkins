// scripts/init.groovy.d/basic-security.groovy
import jenkins.model.*
import hudson.security.*
import hudson.security.csrf.*
import org.jenkinsci.plugins.matrixauth.*

// Get Jenkins instance
def instance = Jenkins.getInstance()

// Enable CSRF Protection
def csrfProtection = new DefaultCrumbIssuer(true)
instance.setCrumbIssuer(csrfProtection)

// Configure security realm (using Jenkins' built-in user database)
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(System.getenv("JENKINS_ADMIN_ID"), System.getenv("JENKINS_ADMIN_PASSWORD"))
hudsonRealm.createAccount(System.getenv("JENKINS_READONLY_ID"), System.getenv("JENKINS_READONLY_PASSWORD"))
instance.setSecurityRealm(hudsonRealm)

// Configure authorization strategy (role-based strategy)
def strategy = new GlobalMatrixAuthorizationStrategy()

// Grant Administer permissions to the admin user
strategy.add(Jenkins.ADMINISTER, System.getenv("JENKINS_ADMIN_ID"))

// Grant read-only permissions to the readonly user
strategy.add(Jenkins.READ, System.getenv("JENKINS_READONLY_ID"))
strategy.add(hudson.model.Item.READ, System.getenv("JENKINS_READONLY_ID"))
strategy.add(hudson.model.Item.DISCOVER, System.getenv("JENKINS_READONLY_ID"))
strategy.add(hudson.model.View.READ, System.getenv("JENKINS_READONLY_ID"))

// Optionally add more granular permissions
// Allow readonly user to view job details but not build
strategy.add(hudson.model.Item.BUILD, System.getenv("JENKINS_READONLY_ID"))
strategy.add(hudson.model.Item.CONFIGURE, System.getenv("JENKINS_READONLY_ID"))
strategy.add(hudson.model.Item.CREATE, System.getenv("JENKINS_READONLY_ID"))
strategy.add(hudson.model.Item.DELETE, System.getenv("JENKINS_READONLY_ID"))
strategy.add(hudson.model.Item.CANCEL, System.getenv("JENKINS_READONLY_ID"))

instance.setAuthorizationStrategy(strategy)

// Disable signup to prevent unauthorized account creation
instance.setSecurityRealm(hudsonRealm)
instance.save()

// Print a message indicating the script has run successfully
println 'Security settings configured successfully.'