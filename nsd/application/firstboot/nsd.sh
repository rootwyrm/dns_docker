#!/usr/bin/env bash
################################################################################
# Copyright (C) 2020-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
# All rights reserved
#
# CC-BY-NC-3.0
# See /LICENSE for details
################################################################################


function ipaddress()
{
	export SYSTEM_LOCALIP4=$(hostname -i)
	if [ ! -z $SYSTEM_LOCALIP4 ]; then
		export NSD_LOCALIP4=$SYSTEM_LOCALIP4
	else
		printf 'FATAL: Could not determine system IP! Shutting down.\n'
		/sbin/runit-init 0
	fi
	
	export SYSTEM_LOCALIP6=$(ifconfig eth0 | grep inet6 | grep -v Link | awk '{print $3}')
	if [[ $SYSTEM_LOCALIP6 == '' ]]; then
		unset SYSTEM_LOCALIP6
	else
		export NSD_LOCALIP6=$SYSTEM_LOCALIP6
	fi
}

function config()
{
	local CONFIG="/usr/local/etc/nsd/nsd.conf"

	## Run ncpu/2 servers up to a maximum 4 - %%NSD_NCPU%%
	local cpucount=$(cat /proc/cpuinfo | grep ^processor | wc -l)
	if [[ $cpucount -gt 4 ]]; then
		NSD_NCPU=4
	elif [[ $cpucount -le 2 ]]; then
		NSD_NCPU=2
	else
		NSD_NCPU=$(($cpucount/2))
	fi

	## Don't trust the local resolver for these. Ever.
	## This doesn't abuse PCH, because these are one-time lookups.
	LAX_XFR=$(host -t A lax.xfr.dns.icann.org 9.9.9.9 | grep address | awk '{print $4}')
	if [ -z $LAX_XFR ] || [ $LAX_XFR = "" ]; then
		printf 'Could not resolve lax.xfr.dns.icann.org via PCH, aborting!\n'
		touch /nsd.disable
		exit 1
	fi
	IAD_XFR=$(host -t A iad.xfr.dns.icann.org 9.9.9.9 | grep address | awk '{print $4}')
	if [ -z $IAD_XFR ] || [ $IAD_XFR = "" ]; then
		printf 'Could not resolve iad.xfr.dns.icann.org via PCH, aborting!\n'
		touch /nsd.disable
		exit 1
	fi
	
	## Fix permissions
	/usr/local/sbin/nsd-control-setup
	chown -R nsd:nsd /var/db/nsd
	chown -R nsd:nsd /usr/local/etc/nsd

	printf '**********************************************************************\n'
	printf 'System IPv4 Address: %s\n' "$SYSTEM_LOCALIP4"
	if [ ! -z $SYSTEM_LOCALIP6 ]; then
		printf 'System IPv6 Address: %s\n' "$SYSTEM_LOCALIP6"
	fi
	## Insert IP addresses
	sed -i -e 's/%%NSD_LOCALIP4%%/'$NSD_LOCALIP4'/g' $CONFIG
	printf 'nsd binding to %s\n' "$NSD_LOCALIP4"
	## Insert IPv6 if present, delete if absent
	if [ ! -z $NSD_LOCALIP6 ]; then
		sed -i -e 's/%%NSD_LOCALIP6%%/'$NSD_LOCALIP6'/g' $CONFIG
		printf 'nsd binding to %s\n' "$NSD_LOCALIP6"
	else
		sed -i -e '/.*%%NSD_LOCALIP6%%.*/d' $CONFIG
	fi
	sed -i -e 's/%%NSD_NCPU%%/'$NSD_NCPU'/g' $CONFIG
	printf 'Starting with %s servers\n' "$NSD_NCPU"
	sed -i -e 's/%%LAX_XFR%%/'$LAX_XFR'/g' $CONFIG
	printf 'Using %s lax.xfr.dns.icann.org for root zones\n' "$LAX_XFR"
	sed -i -e 's/%%IAD_XFR%%/'$IAD_XFR'/g' $CONFIG
	printf 'Using %s iad.xfr.dns.icann.org for root zones\n' "$IAD_XFR"
	printf '\n'
	printf 'nsd firstboot completed.\n'
	printf '**********************************************************************\n'
}

ipaddress
config
