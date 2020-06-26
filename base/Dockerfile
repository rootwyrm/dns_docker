FROM    alpine:3.12

LABEL   maintainer="Phillip 'RootWyrm' Jaenke <prj+docker@rootwyrm.com>" \
        com.rootwyrm.project="dns_docker" \
        com.rootwyrm.vcs-type="github" \
        com.rootwyrm.url="%%GITHUB_REPOSITORY%%" \
        com.rootwyrm.docker.base="alpine:3.12" \
        com.rootwyrm.docker.auto="%%GITHUB_ACTION%%" \
        com.rootwyrm.docker.license="CC-BY-NC-3.0" \
        com.rootwyrm.dns_docker.component="base" \
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
       
#COPY [ "service/", "/etc/service" ]
#COPY [ "runit/", "/etc/runit" ]
COPY [ "appbase/", "/opt/rootwyrm" ]
COPY [ "rc.conf", "/etc/rc.conf" ]

VOLUME  [ "/run" ]

RUN mkdir -p /opt/rootwyrm && \
    mkdir -p /usr/local/src && \
    mkdir -p /run/openrc && \
    mkdir -p /run/lock && \
    chown root:uucp /run/lock && \
    apk update && apk upgrade && \
    apk add --no-cache openrc file dcron apk-cron openssl bash; \
    sed -i -e '/^tty*/d' /etc/inittab && \
    sed -i -e '/^# Set up*/d' /etc/inittab && \
    sed -i -e '/^::ctrlalt*/d' /etc/inittab && \
    sed -i -e '/.*salute$/d' /etc/inittab && \
    /sbin/rc-update add dcron && \
    rm -f /etc/init.d/hw* ; \
    rm -f /etc/init.d/modules ; \
    rm -f /etc/init.d/modules-load ; \
    rm -f /etc/init.d/modloop ; \
    sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh && \
    sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh

ONBUILD ADD [ "application/", "/opt/rootwyrm" ]
ONBUILD ADD [ "sv/", "/etc/sv" ]
ONBUILD RUN touch /firstboot && \
    echo "$(date '+%FT%T.%N%:z') [BUILD] phase beginning..." ; \
    for bld in `ls /opt/rootwyrm/build/ | sort`; do \
        /opt/rootwyrm/build/$bld ; \
    done && \
    echo "$(date '+%FT%T.%N%:z') [BUILD] phase complete..." 

ENTRYPOINT [ "/sbin/init" ]

# vim:ts=4:sw=4:et
