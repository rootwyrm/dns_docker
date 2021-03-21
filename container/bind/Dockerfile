ARG     RELEASE=latest
FROM    docker.io/rootwyrm/dns_base:${RELEASE}

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
        ## label-schema.org
        org.label-schema.schema-version="1.0.0-rc1" \
        org.label-schema.vendor="RootWyrm" \
        org.label-schema.name="dns_docker/base" \
        org.label-schema.url="%%GITHUB_REPOSITORY%%" \
        org.label-schema.vcs-ref="%%VCS_REF%%" \
        org.label-schema.version="%%REF%%" \
        org.label-schema.build-date="%%RW_BUILDDATE%%" \
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
EXPOSE    10530/tcp
EXPOSE    10530/udp

## Create common elements
ADD     [ "cron/", "/etc/periodic/" ]

VOLUME  [ "/usr/local/etc/bind" ]

# vim:sw=4:ts=4:et
