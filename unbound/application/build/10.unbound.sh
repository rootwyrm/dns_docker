#!/bin/bash
## application/build/10.unbound.sh

# Copyright (C) 2015-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT

######################################################################
## Function Import and Setup
######################################################################

. /opt/rootwyrm/lib/deploy.lib.sh

#export IFS=$'\n'
export BUILDNAME="unbound"
export DISTSITE="https://www.nlnetlabs.nl/downloads/unbound/"
export DISTVER="1.10.1"

## Build
export vbpkg="${BUILDNAME}_build"
export vbpkg_content="gcc g++ make openssl-dev expat-dev protobuf-c-dev fstrm-dev libsodium-dev libmnl-dev libevent-dev linux-headers"
## Runtime
export vrpkg="${BUILDNAME}_run"
export vrpkg_content="curl openssl expat protobuf-c fstrm libsodium libmnl libevent"

export curl_cmd="/usr/bin/curl --tlsv1.2 -L --silent"

install_runtime()
{
	######################################################################
	## Install runtime packages first.
	######################################################################
	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Installing runtime dependencies as $vrpkg"
	/sbin/apk --no-cache add --virtual $vrpkg $vrpkg_content > /dev/null 2>&1
	CHECK_ERROR $? $vrpkg
}

install_buildpkg()
{
	######################################################################
	## Install our build packages.
	######################################################################
	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Entering build phase."
	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Installing build dependencies as $vbpkg"
	/sbin/apk --no-cache add --virtual $vbpkg $vbpkg_content > /dev/null 2>&1 
	CHECK_ERROR $? $vbpkg
}

user()
{
	## Need to create our user
	adduser -g "unbound user" -D -H -h /etc/unbound -s /sbin/nologin -u 106 unbound
	CHECK_ERROR $? ${BUILDNAME}_user
}

build()
{
	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Retrieving ${BUILDNAME} ${DISTVER}"
	if [ ! -d /usr/local/src ]; then
		mkdir /usr/local/src
	fi
	cd /usr/local/src
	local DISTFILE="${BUILDNAME}-${DISTVER}.tar.gz"
	$curl_cmd ${DISTSITE}/${DISTFILE} > ${DISTFILE}
	tar xf ${DISTFILE}
	rm ${DISTFILE}
	cd ${BUILDNAME}-${DISTVER}

	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Configuring..."
	## XXX: Need to test for tcp_fast_open
	./configure --prefix=/usr/local \
		--with-libevent=/usr \
		--enable-pie --enable-relro-now --enable-subnet \
		--enable-tfo-client --enable-tfo-server \
		--enable-dnstap --enable-dnscrypt --enable-cachedb \
		--enable-ipsecmod --enable-ipset	
	CHECK_ERROR $? "${BUILDNAME}_configure"
	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] configure complete."

	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Building..."
	make 
	CHECK_ERROR $? "${BUILDNAME}_build"
	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Build complete."

	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Doing install..."
	make install
	CHECK_ERROR $? "${BUILDNAME}_install"
	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] install complete"
}

clean()
{
	######################################################################
	## Clean up after ourselves, because seriously, this is batshit huge.
	######################################################################
	echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Cleaning up build."
	make clean
	cd /root
	rm -rf /usr/local/src/${BUILDNAME}-${DISTVER}
	CHECK_ERROR $? "${BUILDNAME}_clean_delete_source"
	/sbin/apk --no-cache del $vbpkg
	CHECK_ERROR $? "${BUILDNAME}_clean_apk"
}

install_runtime
install_buildpkg
user
build
clean

echo "$(date '+%b %d %H:%M:%S') [${BUILDNAME}] Build and install of ${DISTVER} complete."
exit 0 
