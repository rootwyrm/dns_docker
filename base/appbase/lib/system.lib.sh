#!/bin/bash
# application/lib/deploy.lib.sh

# Copyright (C) 2015-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
# CC-BY-NC-3.0

## NOTE: Use export due to bash limitations
export chkfile="/firstboot"
export svcdir="/etc/service"

## Generic CHECK_ERROR function
function CHECK_ERROR()
{
	if [ $1 -ne 0 ]; then
		RC=$1
		if [ -z $2 ]; then
			echo "[FATAL] Error occurred in unknown location"
			exit $RC
		else
			echo "[FATAL] Error occurred in $2 : $1"
			exit $RC
		fi
	fi
}

## Ingest the environment
function ingest_environment()
{
	if [ -s /.dockerenv ]; then
		. /.dockerenv
	fi
	if [ -s /.dockerinit ]; then
		. /.dockerinit
	fi
}

## Get system IP address function
function IPADDRESS()
{
	export SYSTEM_LOCALIP4=$(hostname -i)
	if [ -z $SYSTEM_LOCALIP4 ]; then
		printf 'FATAL: Could not determine system IP! Shutting down.\n'
		exit 1
	fi
	
	export SYSTEM_LOCALIP6=$(ifconfig eth0 | grep inet6 | grep -v Link | awk '{print $3}')
	if [[ $SYSTEM_LOCALIP6 == '' ]]; then
		unset SYSTEM_LOCALIP6
	fi
}

######################################################################
## MOTD and Version Information
######################################################################
function system_version()
{
	if [ -f /opt/rootwyrm/release ]; then
		export SYSTEM_RELEASE=$(cat /opt/rootwyrm/release)
	else
		export SYSTEM_RELEASE="unknown"
	fi
}

function software_version()
{
	if [ -f /opt/rootwyrm/id.service ]; then
		verfile=/opt/rootwyrm/$(cat /opt/rootwyrm/id.service).version
	fi
	if [ -f $verfile ]; then
		export SWVERSION=$(cat $verfile)
	fi
}

# vim:ft=sh:ts=4:sw=4
