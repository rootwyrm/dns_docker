#!/bin/bash
################################################################################
## Copyright (C) 2020-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
## All rights reserved
##
## Licensed uncer CC-BY-NC-3.0
## See LICENSE for details
################################################################################

function apk_build()
{
	## This thing eats dependencies like candy.
	apk add --no-cache --virtual dnsblast_build musl-dev libc-dev binutils-dev bind-dev make gcc g++ git
}

function build_it()
{
	mkdir -p /usr/local/src
	cd /usr/local/src
	git clone https://github.com/jedisct1/dnsblast.git
	cd dnsblast
	make
	cp dnsblast /usr/local/bin
	cd /root
	rm -rf /usr/local/src/dnsblast
}

apk_build
build_it
apk del dnsblast_build
