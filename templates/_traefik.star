def traefik_labels(serviceName, values):
    rules = ["traefik.enable=true"]

    if hasattr(values, "port"):
        servicePort = str(values.port)
    else:
        servicePort = "80"
    end

    if hasattr(values, "hosts"):
        hosts = values.hosts

        for hostIndex in range(len(hosts)):
            host = hosts[hostIndex]

            if type(host.name) != "string":
                fail("host name must be a string")
            end

            routerName = serviceName + "-" + str(hostIndex)

            rule = "traefik.http.routers." + routerName + ".rule="
            rule += "Host(`" + host.name + "`)"

            if hasattr(host, "pathPrefix"):
                pathPrefixRules = ""

                if type(host.pathPrefix) == "list":
                    for pathPrefixIndex in range(len(host.pathPrefix)):
                        if pathPrefixIndex != 0:
                            pathPrefixRules += " || "
                        end

                        pathPrefixRules += "PathPrefix(`" + host.pathPrefix[pathPrefixIndex] + "`)"
                    end
                else:
                    fail("pathPrefix must be a list")
                end

                rule += " && (" + pathPrefixRules + ")"
            end

            rules.append(rule)

            if hasattr(host, "stripPrefix"):
                stripPrefixRule = "traefik.http.middlewares." + routerName + "-stripprefix.stripprefix.prefixes="

                if type(host.stripPrefix) == "list":
                    for stripPrefixIndex in range(len(host.stripPrefix)):
                        if stripPrefixIndex != 0:
                            stripPrefixRule += ","
                        end

                        stripPrefixRule += host.stripPrefix[stripPrefixIndex]
                    end

                    rules.append(stripPrefixRule)
                else:
                    fail("stripPrefix must be a list")
                end
            end

            rules.append("traefik.http.routers." + routerName + ".service=" + serviceName)
        end
    end

    rules.append("traefik.http.services." + serviceName + ".loadbalancer.server.port=" + servicePort)

    return rules
end
