FROM	rootwyrm/dns_base:latest

## Set up our labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <prj+docker@rootwyrm.com>" \
        com.rootwyrm.project="dns_docker/dnsdist" \
        com.rootwyrm.product="PowerDNS dnsdist" \
		com.rootwyrm.vcs-type="github" \
		com.rootwyrm.changelog-url="" \
        com.rootwyrm.docker.base="rootwyrm/dns_base:latest" \
        com.rootwyrm.docker.auto="%%GITHUB_ACTION%%" \
        com.rootwyrm.docker.license="CC-BY-NC-3.0" \
        com.rootwyrm.dns_docker.component="dnsdist" \
        com.rootwyrm.dns_docker.version="%%REF%%" \
		## label-schema.org
        org.label-schema.schema-version="1.0.0-rc1" \
        org.label-schema.vendor="RootWyrm" \
        org.label-schema.name="dns_docker/base" \
        org.label-schema.url="https://github.com/rootwyrm/dns_docker" \
        org.label-schema.vcs-ref="%%VCS_REF%%" \
        org.label-schema.version="%%REF%%" \
        org.label-schema.build-date="%%RW_BUILDDATE%%" \
        ## OCI
        org.opencontainers.image.authors="RootWyrm" \
        org.opencontainers.image.vendor="RootWyrm" \
        org.opencontainers.image.licenses="CC-BY-NC-3.0" \
        org.opencontainers.image.version="%%RW_VCSHASH%%"

EXPOSE	53/tcp
EXPOSE	53/udp
EXPOSE	80/tcp
EXPOSE	443/tcp
EXPOSE	8053/tcp

ADD [ "application", "/opt/rootwyrm" ]

VOLUME [ "/run" ]
VOLUME [ "/usr/local/etc/dnsdist" ]

CMD [ "/sbin/runsvdir", "-P", "/etc/service" ]

# vim:ts=4:sw=4:et
