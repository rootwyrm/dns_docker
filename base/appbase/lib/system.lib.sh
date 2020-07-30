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
	system_version
	software_version
	FIND_DEVICE
	IP_INFORMATION
}

## Get system network device information
function FIND_DEVICE()
{
	local route_device=$(ip route list | grep ^default | awk '{print $5}')
	if [ -z $route_device ] || [[ $route_device == '' ]]; then
		printf 'FATAL: Could not determine default network device!\n'
		exit 100
	else
		export DEFAULT_DEVICE=$route_device
	fi
}

## Get system IP information
function IP_INFORMATION()
{
	## First deal with the device
	if [ -z $DEFAULT_DEVICE ]; then
		## Try running it
		DEFAULT_DEVICE
	fi

	export DEFAULT_IP4=$(ip addr show dev $DEFAULT_DEVICE | grep 'inet ' | awk '{print $2}' | cut -d / -f 1)
	export DEFAULT_IP6=$(ip addr show dev $DEFAULT_DEVICE scope global | awk '$1 ~ /^inet6/ { sub("/.*", "", $2); print $2 }')

	if [ -z $DEFAULT_IP4 ]; then
		printf 'FATAL: Could not determine system IP! Shutting down.\n'
		exit 1
	fi
	
	if [[ $DEFAULT_IP6 == '' ]]; then
		unset DEFAULT_IP6
	fi

	## Determine our default subnet
	DEFAULT_IP4NET=$(ip route show dev $DEFAULT_DEVICE scope link | awk '{print $1}')
	DEFAULT_IP6NET=$(ip -6 route show dev $DEFAULT_DEVICE scope global | grep -v '^fe' | grep -v '^default')

	## Determine our default gateway
	DEFAULT_IP4GW=$(ip route show dev $DEFAULT_DEVICE scope global | awk '{print $3}')
	DEFAULT_IP6GW=$(ip -6 route show dev $DEFAULT_DEVICE scope global | grep '^default' | awk '{print $3}')
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
		export SWNAME=$(cat /opt/rootwyrm/id.service)
		export SWVERSION=$(cat $verfile)
	fi
}

# vim:ft=sh:ts=4:sw=4
