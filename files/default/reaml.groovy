import groovy.json.JsonSlurper
import org.sonatype.nexus.security.realm.RealmManager

def params = new JsonSlurper().parseText(args)

def realmManager = container.lookup(RealmManager.class.getName())

if (params.action == 'enable') {
  realmManager.enableRealm(params.name)
} else {
  realmManager.disableRealm(params.name)
}
