#!/bin/bash
################################################################################
# Copyright (C) 2015-* Phillip "RootWyrm" Jaenke
# All rights reserved
# 
# Licensed under CC-BY-NC-3.0
# See /LICENSE for details
################################################################################
## application/build/10.nsd.sh

######################################################################
## Function Import and Setup
######################################################################
. /opt/rootwyrm/lib/deploy.lib.sh
ingest_environment
software_version

#export IFS=$'\n'
export BUILDNAME="nsd"
export DISTSITE="https://www.nlnetlabs.nl/downloads/nsd/"
export DISTVER="${SWVERSION:-4.3.1}"
# https://www.nlnetlabs.nl/downloads/nsd/nsd-4.3.1.tar.gz

## Build
export vbpkg="${BUILDNAME}_build"
export vbpkg_content="gcc g++ make libevent-dev openssl-dev protobuf-c-dev fstrm-dev"
## Runtime
export vrpkg="${BUILDNAME}_run"
export vrpkg_content="curl libevent openssl protobuf-c fstrm bind-tools"

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
	echo "$(date $DATEFMT) [${BUILDNAME}] Retrieving ${BUILDNAME} ${DISTVER}"
	if [ ! -d /usr/local/src ]; then
		mkdir /usr/local/src
	fi
	cd /usr/local/src
	local DISTFILE="${BUILDNAME}-${DISTVER}.tar.gz"
	$curl_cmd ${DISTSITE}/${DISTFILE} > ${DISTFILE}
	tar xf ${DISTFILE}
	rm ${DISTFILE}
	cd ${BUILDNAME}-${DISTVER}

	echo "$(date $DATEFMT) [${BUILDNAME}] Configuring..."
	## NOTE: Must be extremely explicit with paths for nsd
	## testing
	./configure \
		--with-configdir=/usr/local/etc/nsd \
		--with-pidfile=/run/nsd.pid \
		--with-xfrdir=/var/db/nsd \
		--enable-pie --enable-relro-now --enable-root-server \
		--enable-ratelimit-default-is-off --enable-dnstap \
		--enable-tcp-fastopen
	CHECK_ERROR $? "${BUILDNAME}_configure"
	echo "$(date $DATEFMT) [${BUILDNAME}] configure complete."

	echo "$(date $DATEFMT) [${BUILDNAME}] Building..."
	make 
	CHECK_ERROR $? "${BUILDNAME}_build"
	echo "$(date $DATEFMT) [${BUILDNAME}] Build complete."

	echo "$(date $DATEFMT) [${BUILDNAME}] Doing install..."
	make install
	CHECK_ERROR $? "${BUILDNAME}_install"
	echo "$(date $DATEFMT) [${BUILDNAME}] install complete"
}

clean()
{
	######################################################################
	## Clean up after ourselves.
	######################################################################
	echo "$(date $DATEFMT) [${BUILDNAME}] Cleaning up build."
	make clean
	cd /root
	rm -rf /usr/local/src/${BUILDNAME}-${DISTVER}
	CHECK_ERROR $? "${BUILDNAME}_clean_delete_source"
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
