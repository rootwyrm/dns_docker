FROM	alpine:3.12

LABEL	maintainer="Phillip 'RootWyrm' Jaenke <prj+docker@rootwyrm.com>" \
		com.rootwyrm.project="dns_docker" \
		com.rootwyrm.url="https://github.com/rootwyrm/dns_docker" \
		com.rootwyrm.dns_docker.component="benchmark" \
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

VOLUME	[ "/run", "/tmp" ]
COPY	[ "benchmark/", "/opt/rootwyrm" ]

RUN	apk update && apk upgrade && \
	apk add bash curl openssl jq wget && \
	/opt/rootwyrm/build_oarc.sh && \
	/opt/rootwyrm/build_dnsblast.sh 

CMD [ "/opt/rootwyrm/bench_it.sh" ]
