#!/bin/bash
# application/lib/deploy.lib.sh

# Copyright (C) 2015-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
# CC-BY-NC-3.0

## NOTE: Use export due to bash limitations
export chkfile="/firstboot"
export svcdir="/etc/service"

CHECK_ERROR()
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

ingest_environment()
{
	if [ -s /.dockerenv ]; then
		. /.dockerenv
	fi
	if [ -s /.dockerinit ]; then
		. /.dockerinit
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

######################################################################
## runit functions
######################################################################
runit_linksv()
{
	if [ -z $1 ] && [ -z $app_svname ]; then
		echo "[FATAL] runit_linksv() called with no arguments."
	elif [ -d /etc/sv/$app_svname ]; then
		ln -s /etc/sv/$app_svname /etc/service
		if [ $? -ne 0 ]; then
			echo "[FATAL] Failed to install $app_svname in runit."
			exit 1
		fi
	elif [ -d /etc/sv/$1 ]; then
		ln -s /etc/sv/$1 /etc/service
		if [ $? -ne 0 ]; then
			echo "[FATAL] Failed to install $1 in runit."
			exit 1
		fi
	fi
}
