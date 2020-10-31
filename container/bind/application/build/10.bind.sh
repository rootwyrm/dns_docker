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

#export IFS=$'\n'
export BUILDNAME="bind"
export DISTSITE="https://downloads.isc.org/isc/bind9"
#/9.16.8/bind-9.16.8.tar.xz
export DISTVER="${SWVERSION:-9.16.8}"
# https://www.nlnetlabs.nl/downloads/nsd/nsd-4.3.1.tar.gz

## Build
export vbpkg="${BUILDNAME}_build"
export vbpkg_content="gcc g++ make libevent-dev openssl-dev protobuf-c-dev fstrm-dev libxml2-dev libmaxminddb-dev libuv-dev lmdb-dev perl libcap-dev libidn2-dev json-c-dev"
## Runtime
export vrpkg="${BUILDNAME}_run"
export vrpkg_content="curl libevent openssl protobuf-c fstrm libmaxminddb libxml2 py3-ply libuv lmdb libcap libidn2 json-c"

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
	local DISTFILE="${BUILDNAME}-${DISTVER}.tar.xz"
	$curl_cmd ${DISTSITE}/${DISTVER}/${DISTFILE} > ${DISTFILE}
	xzcat ${DISTFILE} | tar xf -
	rm ${DISTFILE}
	cd ${BUILDNAME}-${DISTVER}

	echo "$(date $DATEFMT) [${BUILDNAME}] Configuring..."
	## NOTE: Must be extremely explicit with paths for nsd
	## testing
	./configure \
		--prefix=/usr/local \
		--sysconfdir=/usr/local/etc/bind \
		--enable-dnstap \
		--enable-auto-validation \
		--enable-dnsrps \
		--enable-dnsrps-dl \
		--enable-full-report \
		--with-maxminddb=auto \
		--with-libtool \
		--with-lmdb \
		--with-libidn2=yes \
		--with-json-c \
		--with-dlz-stub \
		--with-dlz-filesystem=yes

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
