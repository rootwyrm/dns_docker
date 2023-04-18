#!/bin/bash
################################################################################
# Copyright (C) 2015-* Phillip "RootWyrm" Jaenke
# All rights reserved
# 
# Licensed under CC-BY-NC-3.0
# See /LICENSE for details
################################################################################
## application/build/10.bind.sh

######################################################################
## Function Import and Setup
######################################################################
. /opt/rootwyrm/lib/deploy.lib.sh
ingest_environment
software_version

export BUILDNAME="bind_exporter"

export BIND_EXPORTER_VER="${BIND_EXPORTER_VER:-0.6.1}"

## busybox doesn't support nanoseconds
export DATEFMT="+%FT%T%z"
export curl_cmd="/usr/bin/curl --tlsv1.2 -L --silent"

install_package()
{
	local BINDIR=/opt/local/bind_exporter
	local ARCH=$(uname -m)
	case $ARCH in 
		aarch64)
			ARCH=arm64
			;;
		x86_64)
			ARCH=amd64
			;;
	esac

	local URL=https://github.com/prometheus-community/bind_exporter/releases/download/v${BIND_EXPORTER_VER}/bind_exporter-${BIND_EXPORTER_VER}.linux-${ARCH}.tar.gz
	curl -L -o /tmp/bind_exporter.tgz $URL
	if [ ! -d $BINDIR ]; then
		mkdir -p $BINDIR
	fi
	tar -C ${BINDIR} --strip-components=1 -zxf /tmp/bind_exporter.tgz "bind_exporter-${BIND_EXPORTER_VER}.linux-${ARCH}/LICENSE"
	tar -C ${BINDIR} --strip-components=1 -zxf /tmp/bind_exporter.tgz "bind_exporter-${BIND_EXPORTER_VER}.linux-${ARCH}/NOTICE"
	tar -C ${BINDIR} --strip-components=1 -zxf /tmp/bind_exporter.tgz "bind_exporter-${BIND_EXPORTER_VER}.linux-${ARCH}/bind_exporter"
}

install_package

echo "$(date $DATEFMT) [${BUILDNAME}] Build and install of bind_exporter ${BIND_EXPORTER_VER} complete."
exit 0 
