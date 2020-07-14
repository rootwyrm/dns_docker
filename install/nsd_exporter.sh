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
which go > /dev/null
if [ $? -ne 0 ]; then
	printf 'go is not installed!\n'
	exit 1
fi

if [ ! -d nsd_exporter ]; then
	git clone https://github.com/optix2000/nsd_exporter.git
	if [ $? -ne 0 ]; then
		printf 'Failed to clone from optix2000/nsd_exporter\n'
		exit 1
	fi
else
	git pull -r true nsd_exporter
fi

## XXX: won't build on rhel/centos, needs to be built in an alpine docker
install_nsd()
{
	cd nsd_exporter
	make
	if [ $? -ne 0 ]; then
		printf 'There was an issue compiling!\n'
		exit 1
	fi
	## This is to be run after the container is built, so.
	docker cp nsd_exporter nsd:/opt/rootwyrm/bin/
	if [ $? -ne 0 ]; then
		printf 'Error copying into the container!\n'
		printf 'Did you docker-compose up --no-start first?\n'
		exit 1
	fi
	docker exec -it nsd rc-update add nsd_exporter
	exit 0
}

## PRINT THE LICENSE!
printf 'ATTENTION: You must agree to the following license to install this\n'
printf 'software. Read carefully before accepting.\n'
printf '\n'
cat nsd_exporter/LICENSE
printf '\n'
printf 'Press any key to accept the license or ^C to decline\n'
while [ true ]; do
	read -t 3 -n 1
	if [ $? = 0 ]; then
		install_nsd
	fi
done
