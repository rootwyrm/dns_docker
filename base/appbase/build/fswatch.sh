#!/bin/bash
## appbase/build/fswatch.sh

# Copyright (C) 2015-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT

######################################################################
## Function Import and Setup
######################################################################

. /opt/rootwyrm/lib/deploy.lib.sh

export BUILDNAME="fswatch"
export FSWATCH_URL="https://github.com/emcrisostomo/fswatch/releases/download/1.15.0/fswatch-1.15.0.tar.gz"

## Build
export vbpkg="fswatch_build"
export vbpkg_content="gcc g++ make autoconf automake"

## busybox doesn't support nanoseconds
export DATEFMT="+%FT%T%z"
export curl_cmd="/usr/bin/curl --tlsv1.2 -L --silent"
	
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
	echo "$(date $DATEFMT) [${BUILDNAME}] Retrieving ${DISTVER}"
	if [ ! -d /usr/local/src ]; then
		mkdir /usr/local/src
	fi
	cd /usr/local/src
	$curl_cmd ${FSWATCH_URL} -o fswatch-1.15.0.tar.gz
	tar xfz fswatch-1.15.0.tar.gz
	rm fswatch-1.15.0.tar.gz
	cd fswatch-1.15.0

	echo "$(date $DATEFMT) [${BUILDNAME}] Configuring..."
	## Be extremely explicit.
	./configure 
	CHECK_ERROR $? "fswatch_configure"
	echo "$(date $DATEFMT) [${BUILDNAME}] configure complete."

	echo "$(date $DATEFMT) [${BUILDNAME}] Building..."
	make 
	CHECK_ERROR $? "fswatch_build"
	echo "$(date $DATEFMT) [${BUILDNAME}] Build complete."

	echo "$(date $DATEFMT) [${BUILDNAME}] Doing make install..."
	make install
	CHECK_ERROR $? "fswatch_install"
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
	rm -rf /usr/local/src/fswatch*
	CHECK_ERROR $? "fswatch_clean_delete_source"
	/sbin/apk --no-cache del $vbpkg
	CHECK_ERROR $? "fswatch_clean_apk"
}

CREATE_USER_DNSDOCKER
install_buildpkg
build
clean

echo "$(date $DATEFMT) [${BUILDNAME}] Build and install complete."
exit 0 
