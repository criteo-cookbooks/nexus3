import groovy.json.JsonSlurper

def params = new JsonSlurper().parseText(args)
if (params.http["auth"]) {
    if (params.http["auth"]["domain"]) {
        core.httpProxyWithNTLMAuth(
                (String)params.http["host"],
                (int)params.http["port"],
                (String)params.http["auth"]["username"],
                (String)params.http["auth"]["password"],
                (String)params.http["auth"]["host"],
                (String)params.http["auth"]["domain"])
    } else {
        core.httpProxyWithBasicAuth(
                (String)params.http["host"],
                (int)params.http["port"],
                (String)params.http["auth"]["username"],
                (String)params.http["auth"]["password"])
    }
} else {
    core.httpProxy((String)params.http["host"], (int)params.http["port"])
}

core.nonProxyHosts(params.non_proxy_hosts as String[])

if (params.https) {
    if (params.https["auth"]) {
        if (params.https["auth"]["domain"]) {
            core.httpsProxyWithNTLMAuth(
                    (String)params.https["host"],
                    (int)params.https["port"],
                    (String)params.https["auth"]["username"],
                    (String)params.https["auth"]["password"],
                    (String)params.https["auth"]["host"],
                    (String)params.https["auth"]["domain"])
        } else {
            core.httpsProxyWithBasicAuth(
                    (String)params.https["host"],
                    (int)params.https["port"],
                    (String)params.https["auth"]["username"],
                    (String)params.https["auth"]["password"])
        }
    } else {
        core.httpsProxy((String)params.https["host"], (int)params.https["port"])
    }
} else {
    core.removeHTTPSProxy() // Ensure it is cleaned, in case it was configured before.
}