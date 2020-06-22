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
		export UNBOUND_LOCALIP4=$SYSTEM_LOCALIP4
	else
		printf 'FATAL: Could not determine system IP! Shutting down.\n'
		/sbin/runit-init 0
	fi
	
	export SYSTEM_LOCALIP6=$(ifconfig eth0 | grep inet6 | grep -v Link | awk '{print $3}')
	if [[ $SYSTEM_LOCALIP6 == '' ]]; then
		unset SYSTEM_LOCALIP6
	else
		export UNBOUND_LOCALIP6=$SYSTEM_LOCALIP6
	fi
}

function config()
{
	local CONFIG="/usr/local/etc/unbound/unbound.conf"

	## Run ncpu servers up to a maximum 8 - %%UNBOUND_NCPU%%
	local cpucount=$(cat /proc/cpuinfo | grep ^processor | wc -l)
	if [[ $cpucount -gt 8 ]]; then
		UNBOUND_NCPU=8
	## Run a minimum of 2 threads
	elif [[ $cpucount -le 2 ]]; then
		UNBOUND_NCPU=2
	else
		UNBOUND_NCPU=$cpucount
	fi

	## Generate keys and fix permissions
	if [ ! -f /usr/local/etc/unbond/unbound_server.key ]; then
		/usr/local/sbin/unbound-control-setup
	fi
	## Symlink system certificates
	ln -s /etc/ssl/certs/ca-certificates.crt /usr/local/etc/unbound/ca-certificates.crt
	chown -R unbound:unbound /usr/local/etc/unbound

	printf '**********************************************************************\n'
	# Generate TLS session keys	
	printf 'Generating TLS Session Ticket Keys...'
	dd if=/dev/random bs=1 count=80 of=/usr/local/etc/unbound/tls_secret0.key > /dev/null 2>&1
	KEYR0=$?
	dd if=/dev/random bs=1 count=80 of=/usr/local/etc/unbound/tls_secret1.key > /dev/null 2>&1
	KEYR1=$?
	dd if=/dev/random bs=1 count=80 of=/usr/local/etc/unbound/tls_secret2.key > /dev/null 2>&1
	KEYR2=$?
	if [ $KEYR0 != 0 ] || [ $KEYR1 != 0 ] || [ $KEYR2 != 0 ]; then
		printf 'FAILED!\n'
	else
		printf 'OK\n'
	fi

	printf 'Updating root anchors...'
	/usr/local/sbin/unbound-anchor -F
	chown unbound:unbound /usr/local/etc/unbound/root.key
	if [ $? -ne 0 ]; then
		printf 'FAILED!\n'
	else
		printf 'OK\n'
	fi
	printf 'System IPv4 Address: %s\n' "$SYSTEM_LOCALIP4"
	if [ ! -z $SYSTEM_LOCALIP6 ]; then
		printf 'System IPv6 Address: %s\n' "$SYSTEM_LOCALIP6"
	fi
	## Insert IP addresses
	sed -i -e 's/%%UNBOUND_LOCALIP4%%/'$UNBOUND_LOCALIP4'/g' $CONFIG
	printf 'Unbound binding to %s\n' "$UNBOUND_LOCALIP4"
	## Insert IPv6 if present, delete if absent
	if [ ! -z $UNBOUND_LOCALIP6 ]; then
		sed -i -e 's/%%UNBOUND_LOCALIP6%%/'$UNBOUND_LOCALIP6'/g' $CONFIG
		printf 'Unbound binding to %s\n' "$UNBOUND_LOCALIP6"
	else
		sed -i -e '/.*%%UNBOUND_LOCALIP6%%.*/d' $CONFIG
	fi
	sed -i -e 's/%%UNBOUND_NCPU%%/'$UNBOUND_NCPU'/g' $CONFIG
	printf 'Starting with %s threads\n' "$UNBOUND_NCPU"
	sed -i -e 's/%%LAX_XFR%%/'$LAX_XFR'/g' $CONFIG
	printf 'Remote Control is enabled on localhost:8953\n'
	printf '\n'
	printf 'Unbound firstboot completed.\n'
	printf '**********************************************************************\n'
}

printf 'Starting unbound firstboot tasks...\n'
ipaddress
config
