FROM    alpine:3.12

LABEL   maintainer="Phillip 'RootWyrm' Jaenke <prj+docker@rootwyrm.com>"
LABEL   com.rootwyrm.project="dns_docker" \
        com.rootwyrm.vcs-type="github" \
        com.rootwyrm.changelog-url="" \
        com.rootwyrm.docker.base="alpine:3.12" \
        com.rootwyrm.docker.auto="true" \
        com.rootwyrm.docker.license="CC-BY-NC-3.0" \
        ## label-schema.org
        org.label-schema.schema-version="1.0.0-rc1" \
        org.label-schema.vendor="RootWyrm" \
        org.label-schema.name="dns_docker/base" \
        org.label-schema.url="https://github.com/rootwyrm/dns_docker" \
        org.label-schema.vcs-ref="%%VCS_REF%%" \
        org.label-schema.version="%%RW_VCSHASH%%" \
        org.label-schema.build-date="%%RW_BUILDDATE%%" \
        ## OCI
        org.opencontainers.image.created="%%RW_BUILDDATE%%" \
        org.opencontainers.image.authors="RootWyrm" \
        org.opencontainers.image.vendor="RootWyrm" \
        org.opencontainers.image.licenses="CC-BY-NC-3.0" \
        org.opencontainers.image.source="https://github.com/rootwyrm/dns_docker" \
        org.opencontainers.image.version="%%VCS_REF%%"
       
COPY [ "application/", "/opt/rootwyrm" ]
COPY [ "service/", "/etc/service" ]

VOLUME  [ "/run" ]

RUN mkdir -p /opt/rootwyrm && \
    mkdir -p /usr/local/src && \
    apk update && apk upgrade && \
    apk add --no-cache runit file dcron apk-cron openssl ; \
    rm -rf /etc/init.d && \
    sed -i -e '/^tty*/d' /etc/inittab && \
    sed -i -e '/^# Set up*/d' /etc/inittab && \
    sed -i -e '/^::ctrlalt*/d' /etc/inittab && \
    sed -i -e '/.*salute$/d' /etc/inittab 

ONBUILD RUN touch /firstboot && \
    for sv in `ls /etc/sv`; do \
        ln -s /etc/sv/$sv /etc/service/ ;\
    done && \
    echo "$(date '+%FT%T.%N%:z') [BUILD] phase beginning..." ; \
    for bld in `ls /opt/rootwyrm/build/ | sort`; do \
        if [ -x $bld ]; then \
            /opt/rootwyrm/build/$bld ; \
        fi \
    done \
    echo "$(date '+%FT%T.%N%:z') [BUILD] phase complete..." 

CMD [ "/sbin/runsvdir", "-P", "/etc/service" ]

# vim:ts=4:sw=4:et
