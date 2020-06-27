#!/usr/bin/env bash
################################################################################
# Copyright (C) 2020-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
# All rights reserved
#
# CC-BY-NC-3.0
# See LICENSE in the root for details
################################################################################

## Uses https://github.com/estesp/manifest-tool

export HOST=$(uname)
export ARCH=$(uname -m)
export MANIFEST="manifest.yml"
if [ -z ${GITHUB_WORKSPACE} ]; then
	export GITHUB_WORKSPACE=${PWD}
fi

install_manifest_tool()
{
	local VERSION="1.0.2"
	case $ARCH in
		## Deal with Linux kiddies refusing to agree again...
		x86_64)
			export ARCH="amd64"
			;;
		*)
			;;
	esac
	printf 'Downloading manifest-tool\n'
	curl -o ${GITHUB_WORKSPACE}/ci/manifest-tool --silent -L https://github.com/estesp/manifest-tool/releases/download/v${VERSION}/manifest-tool-${HOST,,}-${ARCH,,} 
	chmod +x ${GITHUB_WORKSPACE}/ci/manifest-tool
}

## Stateless, so be smart about it.
if [ ! -f ${GITHUB_WORKSPACE}/ci/manifest-tool ]; then
	install_manifest_tool
fi
