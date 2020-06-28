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

## Trap early
test_deploy()
{
	if [ ! -f $chkfile ]; then
		exit 0
	else
		# Ingest configuration
		if [ -f $chkfile ]; then
			. $chkfile
		elif [ -f "$chkfile".conf ]; then
			. "$chkfile".conf
		fi
	fi
}

deploy_complete()
{
	if [ -f $chkfile ]; then
		rm $chkfile
	fi
	if [ -f /deploy.new ]; then
		rm /deploy.new
	fi

	# Be certain to not rerun firstboot.
	rm /etc/service/firstboot
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

generate_motd()
{
	baserel="R0V0U0.0000"
	releasefile="/opt/rootwyrm/id.release"
	if [ -s $releasefile ]; then
		releaseid="UNTAGGED_DEVELOPMENT"
	else
		releaseid=$(cat $releasefile)
	fi

	cp /opt/rootwyrm/defaults/motd /etc/motd
	sed -i -e 's,BASERELID,'$baserel',' /etc/motd
	sed -i -e 's,RELEASEID,'$releaseid',' /etc/motd
	sed -i -e 's,APPNAME,'$app_name',' /etc/motd
	sed -i -e 's,APPURL,'$app_url',' /etc/motd

	if [ -f /opt/rootwyrm/app.message ]; then
		sed -i -e '/APPMESSAGE$/d' /etc/motd
		cat /opt/rootwyrm/app.message >> /etc/motd
	else
		sed -i -e '/APPMESSAGE$/d' /etc/motd
	fi
}

## NYI
##update_motd()

######################################################################
## Generic Application Functions
######################################################################
deploy_application_git()
{
	case $1 in
		[Rr][Ee][Ii][Nn][Ss][Tt]*)
		## Doesn't come up often, but might.
			if [[ -z $app_destdir ]] && [[ -d $app_destdir ]]; then
				rm -rf $app_destdir
				mkdir $app_destdir
			fi
			if [ -z $branch ]; then
				git clone $app_git_url -b master --depth=1 $app_destdir
			else
				git clone $app_git_url -b $branch --depth=1 $app_destdir
			fi
			CHECK_ERROR $? git_clone
			chown -R $tcuid:$tcgid $app_destdir
			return $?
			;;
		[Uu][Pp][Dd][Aa][Tt][Ee]*)
			if [ ! -d $app_destdir ]; then
				## Presume user error.
				deploy_application_git REINST
			else
				export return=$PWD; cd $app_destdir
				su $tcuser -c 'git pull'
				if [ $? -ne 0 ]; then
					echo "[WARNING] Error in git_pull_update!"
					exit 1
				fi
				cd $return
				unset return
			fi
			return $?
			;;
		*)
			echo "[FATAL] deploy_application_git() called with invalid argument."
			return 1
			;;
	esac
}

## NYI: update_application_git

# vim:ft=sh:ts=4:sw=4
