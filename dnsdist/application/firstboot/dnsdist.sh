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
		export DNSDIST_LOCALIP4=$SYSTEM_LOCALIP4
	else
		printf 'FATAL: Could not determine system IP! Shutting down.\n'
		/sbin/runit-init 0
	fi
	
	export SYSTEM_LOCALIP6=$(ifconfig eth0 | grep inet6 | grep -v Link | awk '{print $3}')
	if [ $SYSTEM_LOCALIP6 == '' ]; then
		unset SYSTEM_LOCALIP6
	else
		export DNSDIST_LOCALIP6=$SYSTEM_LOCALIP6
	fi
}

function config()
{
	local CONFIG="/usr/local/etc/dnsdist/dnsdist.conf"
	## Create API key in persistent storage
	APIKEY="/usr/local/etc/dnsdist/conf.d/api.key"
	if [ ! -f $APIKEY ]; then
		## Use blocking randomness
		cat /dev/random | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 > $APIKEY
		chmod 0700 $APIKEY
		chown 0:0 $APIKEY
		DNSDIST_APIKEY=$(cat $APIKEY)
	else
		DNSDIST_APIKEY=$(cat $APIKEY)
	fi

	## Always generate a new random password unless doing factory reset 
	PASSWD="/usr/local/etc/dnsdist/passwd"
	if [ ! -f $PASSWD ]; then
		## Use blocking randomness
		cat /dev/random | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > $PASSWD
		chmod 0700 $PASSWD
		chown 0:0 $PASSWD
		DNSDIST_PASSWD=$(cat $PASSWD)
	else
		DNSDIST_PASSWD=$(cat $PASSWD)
	fi

	printf '**********************************************************************\n'
	printf 'System IPv4 Address: %s\n' "$SYSTEM_LOCALIP4"
	if [ ! -z $SYSTEM_LOCALIP6 ]; then
		printf 'System IPv6 Address: %s\n' "$SYSTEM_LOCALIP6"
	fi
	## Insert IP addresses
	sed -i -e 's/%%DNSDIST_LOCALIP4%%/'$DNSDIST_LOCALIP4'/g' $CONFIG
	printf 'dnsdist binding to %s\n' "$DNSDIST_LOCALIP4"
	## Insert IPv6 if present, delete if absent
	if [ ! -z $DNSDIST_LOCALIP6 ]; then
		sed -i -e 's/%%DNSDIST_LOCALIP6%%/'$DNSDIST_LOCALIP6'/g' $CONFIG
		printf 'dnsdist binding to %s\n' "$DNSDIST_LOCALIP6"
	else
		sed -i -e '/.*%%DNSDIST_LOCALIP6%%.*/d' $CONFIG
	fi
	## API key
	sed -i -e 's/%%DNSDIST_APIKEY%%/'$DNSDIST_APIKEY'/g' $CONFIG
	printf 'dnsdist API Key: %s\n' "$DNSDIST_APIKEY"
	## Password
	sed -i -e 's/%%DNSDIST_PASSWD%%/'$DNSDIST_PASSWD'/g' $CONFIG
	printf 'dnsdist Web Password: admin:%s\n' "$DNSDIST_PASSWD"
}

ipaddress
config
