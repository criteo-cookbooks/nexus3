import org.sonatype.nexus.security.realm.RealmManager

def realmManager = container.lookup(RealmManager.class.getName())

// TODO: Override handle logic when given 'realm' not exist
return realmManager.isRealmEnabled(args);