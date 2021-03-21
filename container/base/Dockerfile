FROM    alpine:3.13

LABEL   maintainer="Phillip 'RootWyrm' Jaenke <prj+docker@rootwyrm.com>" \
        com.rootwyrm.project="dns_docker" \
        com.rootwyrm.vcs-type="github" \
        com.rootwyrm.url="%%GITHUB_REPOSITORY%%" \
        com.rootwyrm.docker.base="alpine:3.12" \
        com.rootwyrm.docker.auto="%%GITHUB_ACTION%%" \
        com.rootwyrm.docker.license="CC-BY-NC-4.0" \
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
        org.opencontainers.image.licenses="CC-BY-NC-4.0" \
        org.opencontainers.image.version="%%RW_VCSHASH%%" \
        org.opencontainers.image.revision="%%GITHUB_SHA%%" \
        org.opencontainers.image.source="%%GITHUB_REPOSITORY%%" \
        org.opencontainers.image.created="%%RW_BUILDDATE%%" 

VOLUME  [ "/run" ]

COPY [ "appbase/", "/opt/rootwyrm" ]
COPY [ "etc/", "/etc" ]
ADD  [ "init.d/", "/etc/init.d" ]

RUN mkdir -p /opt/rootwyrm && \
    mkdir -p /usr/local/src && \
    mkdir -p /run/openrc && \
    mkdir -p /run/lock && \
    chown root:uucp /run/lock && \
    apk update && apk upgrade && \
    apk add --no-cache openrc file dcron apk-cron openssl bash curl iwatch logrotate; \
    sed -i -e '/^tty*/d' /etc/inittab && \
    sed -i -e '/^# Set up*/d' /etc/inittab && \
    sed -i -e '/^::ctrlalt*/d' /etc/inittab && \
    sed -i -e '/.*salute$/d' /etc/inittab && \
    /sbin/rc-update add dcron && \
    ln -s /run /var/run && \
    rm -f /etc/init.d/hw* ; \
    rm -f /etc/init.d/modules ; \
    rm -f /etc/init.d/modules-load ; \
    rm -f /etc/init.d/modloop ; \
    sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh && \
    sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh ; \
    echo "dns_docker is Copyright (C) 2020-* Phillip Jaenke and its contributors" > /LICENSE ; \
    echo "https://github.com/rootwyrm/dns_docker/" >> /LICENSE ; \
    echo "" >> /LICENSE ; \
    echo "This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA." >> /LICENSE 

ONBUILD ADD [ "application/", "/opt/rootwyrm" ]
ONBUILD ADD [ "init.d/", "/etc/init.d" ]
ONBUILD ADD [ "conf/", "/opt/rootwyrm/conf" ]
ONBUILD RUN touch /firstboot && \
    echo "$(date '+%FT%T%z') [BUILD] phase beginning..." ; \
    for bld in `ls /opt/rootwyrm/build/ | sort`; do \
        /opt/rootwyrm/build/$bld ; \
    done && \
    echo "$(date '+%FT%T%z') [BUILD] phase complete..." ; \
    /sbin/rc-update add $(cat /opt/rootwyrm/id.service) default ; \
    /sbin/rc-update add iwatch default

ENTRYPOINT [ "/sbin/init" ]

# vim:ts=4:sw=4:et
