import groovy.json.JsonOutput
import org.sonatype.nexus.httpclient.config.ProxyServerConfiguration
import org.sonatype.nexus.httpclient.config.UsernameAuthenticationConfiguration
import org.sonatype.nexus.httpclient.config.NtlmAuthenticationConfiguration

Map configMap(ProxyServerConfiguration psc) {
    def config = [host: psc.getHost(), port: psc.getPort()]
    def auth = psc.getAuthentication()
    if (auth == null) {
        return config
    }

    switch (auth.getType()) {
        case UsernameAuthenticationConfiguration.TYPE:
            def ua = (UsernameAuthenticationConfiguration)auth
            config["auth"] = [username: ua.getUsername(), password: ua.getPassword()]
            break
        case NtlmAuthenticationConfiguration.TYPE:
            def na = (NtlmAuthenticationConfiguration)auth
            config["auth"] = [
                    username: na.getUsername(),
                    password: na.getPassword(),
                    host: na.getHost(),
                    domain: na.getDomain(),
            ]
            break
    }
    return config
}

def existingConfig = [:]

// From the UI you must first configure the HTTP proxy, then the HTTPS
// proxy. So if the all proxy is null or the http proxy, consider nothing
// is configured.
proxy = core.httpClientManager.getConfiguration().getProxy()
if (proxy == null || proxy.getHttp() == null) {
    return JsonOutput.toJson(existingConfig) // Always return an empty map
}

existingConfig['non_proxy_hosts'] = proxy.getNonProxyHosts()
existingConfig['http'] = configMap(proxy.getHttp())
if (proxy.getHttps() != null) {
    existingConfig['https'] = configMap(proxy.getHttps())
}

return JsonOutput.toJson(existingConfig)
