#!/bin/bash
## application/build/10.dnsdist.sh

# Copyright (C) 2015-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT

######################################################################
## Function Import and Setup
######################################################################

. /opt/rootwyrm/lib/deploy.lib.sh

export BUILDNAME="dnsdist"
export DISTSITE="https://downloads.powerdns.com/releases"
if [ -z ${SWVERSION} ]; then
	export SWVERSION="1.5.0-rc4"
else
	export SWVERSION=${SWVERSION}
fi

## Build
export vbpkg="dnsdist_build"
export vbpkg_content="git gcc g++ make autoconf automake openssl-dev luajit-dev fstrm-dev libsodium-dev libedit-dev boost-dev lmdb-dev protobuf-dev re2-dev musl-dev nghttp2-dev"
## Runtime
export vrpkg="dnsdist_run"
export vrpkg_content="curl gettext openssl luajit libedit libsodium boost h2o lmdb libprotobuf libprotoc protoc re2 fstrm nghttp2" 

## busybox doesn't support nanoseconds
export DATEFMT="+%FT%T%z"
export curl_cmd="/usr/bin/curl --tlsv1.2 --cert-status -L --silent"
	
######################################################################
## Install runtime packages first.
######################################################################
install_runtime()
{
	echo "$(date $DATEFMT) [${BUILDNAME}] Installing runtime dependencies as $vrpkg"
	/sbin/apk --no-cache add --virtual $vrpkg $vrpkg_content > /dev/null 2>&1
	CHECK_ERROR $? $vrpkg
}

######################################################################
## Install our build packages.
######################################################################
install_buildpkg()
{
	echo "$(date $DATEFMT) [${BUILDNAME}] Entering build phase."
	echo "$(date $DATEFMT) [${BUILDNAME}] Installing build dependencies as $vbpkg"
	/sbin/apk --no-cache add --virtual $vbpkg $vbpkg_content > /dev/null 2>&1 
	CHECK_ERROR $? $vbpkg
}

######################################################################
## Perform build
######################################################################
build()
{
	echo "$(date $DATEFMT) [${BUILDNAME}] Retrieving ${SWVERSION}"
	if [ ! -d /usr/local/src ]; then
		mkdir /usr/local/src
	fi
	cd /usr/local/src
	local DISTFILE="${BUILDNAME}-${SWVERSION}.tar.bz2"
	$curl_cmd ${DISTSITE}/${DISTFILE} > ${DISTFILE}
	tar xf ${DISTFILE}
	rm ${DISTFILE}
	cd ${BUILDNAME}-${SWVERSION}
	## XXX: Work around a bug.
	mkdir ibdir

	echo "$(date $DATEFMT) [${BUILDNAME}] Configuring..."
	## Be extremely explicit.
	./configure --prefix=/usr/local \
		--sysconfdir=/usr/local/etc/dnsdist \
		--with-re2 --with-ebpf \
		--with-boost=/usr \
		--enable-dnstap --enable-dnscrypt --enable-dns-over-tls \
		--enable-dns-over-https --with-re2
	CHECK_ERROR $? "dnsdist_configure"
	echo "$(date $DATEFMT) [${BUILDNAME}] configure complete."

	echo "$(date $DATEFMT) [${BUILDNAME}] Building..."
	make 
	CHECK_ERROR $? "dnsdist_build"
	echo "$(date $DATEFMT) [${BUILDNAME}] Build complete."

	echo "$(date $DATEFMT) [${BUILDNAME}] Doing make install..."
	make install
	CHECK_ERROR $? "dnsdist_install"
	echo "$(date $DATEFMT) [${BUILDNAME}] make install complete"
}

######################################################################
## Clean up after ourselves.
######################################################################
clean()
{
	echo "$(date $DATEFMT) [${BUILDNAME}] Cleaning up build."
	make clean
	cd /root
	rm -rf /usr/local/src/dnsdist-${SWVERSION}
	CHECK_ERROR $? "dnsdist_clean_delete_source"
	/sbin/apk --no-cache del $vbpkg
	CHECK_ERROR $? "dnsdist_clean_apk"
}

CREATE_USER_DNSDOCKER
software_version
install_runtime
install_buildpkg
build
clean

echo "$(date $DATEFMT) [${BUILDNAME}] Build and install of ${SWVERSION} complete."
exit 0 
