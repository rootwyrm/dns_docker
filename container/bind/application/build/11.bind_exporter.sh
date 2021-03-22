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
export GOPATH="/usr/local/go"
export GOURL="github.com/prometheus-community/bind_exporter"

## Build
export vbpkg="${BUILDNAME}_build"
export vbpkg_content="go git make gcc g++"

## busybox doesn't support nanoseconds
export DATEFMT="+%FT%T%z"
export curl_cmd="/usr/bin/curl --tlsv1.2 -L --silent"

install_runtime()
{
	######################################################################
	## Install runtime packages first.
	######################################################################
	echo "$(date $DATEFMT) [${BUILDNAME}] Installing runtime dependencies as $vrpkg"
	/sbin/apk --no-cache add --virtual $vrpkg $vrpkg_content > /dev/null 2>&1
	CHECK_ERROR $? $vrpkg
}

install_buildpkg()
{
	######################################################################
	## Install our build packages.
	######################################################################
	echo "$(date $DATEFMT) [${BUILDNAME}] Entering build phase."
	echo "$(date $DATEFMT) [${BUILDNAME}] Installing build dependencies as $vbpkg"
	/sbin/apk --no-cache add --virtual $vbpkg $vbpkg_content > /dev/null 2>&1 
	CHECK_ERROR $? $vbpkg
}

################################################################################
# Actual build routine
################################################################################
build()
{
	if [ ! -d $GOPATH ]; then
		mkdir -p $GOPATH
	fi
	echo "$(date $DATEFMT) [${BUILDNAME}] adding bind_exporter..."
	go get -v $GOURL
	CHECK_ERROR $? bind_exporter_go_get
	cd $GOPATH/src/$GOURL
	make
	if [ $? -eq 0 ]; then
		mv $GOPATH/bin/bind_exporter /usr/local/sbin/
		mv $GOPATH/bin/promu /usr/local/sbin/
		rc-update add bind_exporter
	fi
}

clean()
{
	######################################################################
	## Clean up after ourselves.
	######################################################################
	echo "$(date $DATEFMT) [${BUILDNAME}] Cleaning up build."
	cd /root
	rm -rf $GOPATH/bin
	rm -rf $GOPATH/src
	rm -rf $GOPATH/pkg
	/sbin/apk --no-cache del $vbpkg
	CHECK_ERROR $? "${BUILDNAME}_clean_apk"
}

CREATE_USER_DNSDOCKER
install_runtime
install_buildpkg
build
clean

echo "$(date $DATEFMT) [${BUILDNAME}] Build and install of ${DISTVER} complete."
exit 0 
