#!/usr/bin/env bash
################################################################################
# Copyright (C) 2020-* Phillip "RootWyrm" Jaenke
# All rights reserved
# 
# Licensed under CC-BY-NC-3.0
# See /LICENSE for details
################################################################################

## Installs nsd_exporter by optix2000@github
which git > /dev/null
if [ $? -ne 0 ]; then
	printf 'git is not installed!\n'
	exit 1
fi
#which go > /dev/null
#if [ $? -ne 0 ]; then
#	printf 'go is not installed!\n'
#	exit 1
#fi

if [ ! -d unbound_exporter ]; then
	git clone https://github.com/kumina/unbound_exporter.git
	if [ $? -ne 0 ]; then
		printf 'Failed to clone from kumina/unbound_exporter\n'
		exit 1
	fi
else
	git pull -r true unbound_exporter
fi

## XXX: won't build on rhel/centos, needs to be built in an alpine docker
install_unbound()
{
	## XXX: don't use the build_static.sh script because it uses edge.
	docker run --rm -i -v unbound_exporter:/unbound_exporter alpine:latest /bin/sh << 'EOF'
set -ex
apk update
apk add ca-certificates git go go-bindata libc-dev make binutils
cd /unbound_exporter
go build --ldflags '-extldflags "-static"'
strip unbound_exporter
EOF
	if [ $? -ne 0 ]; then
		printf 'There was an issue compiling!\n'
		exit 1
	fi
	## This is to be run after the container is built, so.
	docker cp unbound_exporter/unbound_exporter unbound:/opt/rootwyrm/bin/unbound_exporter
	if [ $? -ne 0 ]; then
		printf 'Error copying into the container!\n'
		printf 'Did you docker-compose up --no-start first?\n'
		exit 1
	fi
	docker cp init.d/unbound_exporter unbound:/etc/init.d/unbound_exporter
	docker exec -it unbound rc-update add unbound_exporter
	exit 0
}

## PRINT THE LICENSE!
printf 'ATTENTION: You must agree to the following license to install this\n'
printf 'software. Read carefully before accepting.\n'
printf '\n'
printf 'Press any key to continue to the license or ^C to decline\n'
while [ true ]; do
	read -t 3 -n 1
	if [ $? = 0 ]; then
		continue
	else
		break
	fi
done
cat unbound_exporter/LICENSE | more
printf '\n'
printf 'Press any key to accept the license or ^C to decline\n'
while [ true ]; do
	read -t 3 -n 1
	if [ $? = 0 ]; then
		install_unbound
	else
		break
	fi
done
