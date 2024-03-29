ARG     RELEASE=latest
FROM    docker.io/rootwyrm/dns_base:${RELEASE}

ENV PROMETHEUS_PORT=${PROMETHEUS_PORT:-10530}

## Set up our labels
LABEL   maintainer="Phillip 'RootWyrm' Jaenke <prj+docker@rootwyrm.com>" \
        com.rootwyrm.project="dns_docker/nsd" \
        com.rootwyrm.product="ISC bind" \
        com.rootwyrm.vcs-type="github" \
        com.rootwyrm.url="%%GITHUB_REPOSITORY%%" \
        com.rootwyrm.docker.base="rootwyrm/dns_base:latest" \
        com.rootwyrm.docker.auto="%%GITHUB_ACTION%%" \
        com.rootwyrm.docker.license="CC-BY-NC-3.0" \
        com.rootwyrm.dns_docker.component="nsd" \
        com.rootwyrm.dns_docker.version="%%RW_VCSHASH%%" \
        ## OCI
        org.opencontainers.image.authors="RootWyrm" \
        org.opencontainers.image.vendor="RootWyrm" \
        org.opencontainers.image.licenses="CC-BY-NC-3.0" \
        org.opencontainers.image.version="%%RW_VCSHASH%%" \
        org.opencontainers.image.revision="%%GITHUB_SHA%%" \
        org.opencontainers.image.source="%%GITHUB_REPOSITORY%%" \
        org.opencontainers.image.created="%%RW_BUILDDATE%%" 

EXPOSE    53/tcp
EXPOSE    53/udp
EXPOSE    853/tcp

## Create common elements
ADD     [ "cron/", "/etc/periodic/" ]

VOLUME  [ "/usr/local/etc/bind" ]

# vim:sw=4:ts=4:et
