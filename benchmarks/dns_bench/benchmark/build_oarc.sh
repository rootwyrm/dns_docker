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
	apk add --no-cache --virtual oarc_build musl-dev libc-dev binutils-dev openssl-dev bind-dev zlib-dev protobuf-dev protobuf-c-dev xz-dev libxml2-dev util-linux-dev e2fsprogs-dev krb5-dev json-c-dev fstrm-dev libpcap-dev nasm bzip2-dev gcc g++ autoconf automake libtool binutils make libidn2-dev zlib-dev pcre2-dev gettext-dev git gnu-libiconv-dev
	## Do NOT delete these packages.
	apk add --no-cache --virtual oarc_run bind-tools python3 libpcap bzip2 libidn2 zlib gettext pcre2 gnu-libiconv
}

function build_it()
{
	mkdir -p /usr/local/src
	cd /usr/local/src
	curl -L -o dnsperf-2.3.4.tar.gz https://github.com/DNS-OARC/dnsperf/archive/v2.3.4.tar.gz
	tar xf dnsperf-2.3.4.tar.gz
	cd dnsperf-2.3.4
	./autogen.sh
	./configure
	make
	make install
	cd /root
	rm -rf /usr/local/src/dnsperf*

	## Now build dnsmeter
	## XXX: doesn't build
	#cd /usr/local/src
	#curl -L -o dnsmeter-1.0.1.tar.gz https://www.dns-oarc.net/files/dnsmeter/dnsmeter-1.0.1.tar.gz
	#tar xf dnsmeter-1.0.1.tar.gz
	#cd dnsmeter-1.0.1
	#./configure
	#make
	#make install
	#cd /root
	#rm -rf /usr/local/src/dnsmeter*
}

apk_build
build_it
apk del oarc_build
