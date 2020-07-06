#!/bin/bash
################################################################################
# Copyright (C) 2020-* Phillip "RootWyrm" Jaenke
# All rights reserved
# 
# Licensed under CC-BY-NC-3.0
# See /LICENSE for details.
################################################################################
#
# Query testing script.

## ARGS: rc descriptor
function check_lookup()
{
	if [[ $1 -ne 0 ]]; then
		echo "ERROR $1 $2"
	else
		echo "SUCCESS: $2"
	fi
}

## ARGS: target_container
function container_bootstrap()
{
	if [ -z $1 ]; then
		printf 'Hit container_bootstrap() without argument!\n'
		##annotate
		exit 1
	fi
	## We need to bootstrap the container with the test tools.
	docker exec -it $1 apk add bind-tools > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		prinf 'Error installing tools when bootstrapping container!\n'
		##annotate
		exit 1
	fi
	echo "@127.0.0.1" > digrc
	echo "+nofail" >> digrc
	echo "+nomapped" >> digrc
	echo "+nosearch" >> digrc
	echo "+noedns" >> digrc
	echo "+nobadcookie" >> digrc
	echo "+nocookie" >> digrc
	echo "+dnssec" >> digrc
	docker cp digrc $1:/root/.digrc
}

## ARGS: target_container
function bootstrap_test()
{
	if [ -z $1 ]; then
		printf 'Hit bootstrap_test() without argument!\n'
		##annotate "Hit bootstrap_test() without argument!"
		exit 1
	fi
	## If we can't resolve this much, then we're already screwed.
	docker exec -it $1 dig -t A a.root-servers.net > /dev/null 2>&1
	#@127.0.0.1 > /dev/null
	check_lookup $? "BOOTSTRAP-a.root-servers.net"
}

## ARGS: target_container query_list
function run_query_set()
{
	if [ -z $1 ] || [ -z $2 ]; then
		printf 'Hit run_query_set() with insufficient arguments!\n'
		## annotate error
		exit 1
	fi

	container=$1
	queryset=$2
	execcmd="docker exec -it ${container}"
	## Commence the pain.
	readarray query < <(cat $2 | grep -v ^#)
	for q in ${query[@]}; do
		record=$(echo $q | cut -d , -f 1)
		class=$(echo $q | cut -d , -f 2)
		case $class in
			A*)
				digcmd="dig -t $class"
				;;
			PTR*)
				digcmd="dig -x -t $class"
				;;
		esac
		$execcmd $digcmd $record > /dev/null 2>&1
		check_lookup $? ${record}
		$execcmd $delvcmd $record > /dev/null 2>&1
		check_lookup $? DNSSEC-${record}
	done
}

## XXX: placeholder till we have a good set of dnssec enabled domains
## NOTE: only look at the top (example.com) and not subs (www.example.com)
##   to avoid false negatives even when DNSSEC is fully working.
run_query_dnssec()
{
	## Permit DLV
	local cmdopts="+dlv"
	## DNSSEC checks
	delvcmd="delv -t $class"
	## Dump into a tempfile because we have to look at multiple lines.
	$delvcmd $record $cmdopts | grep 'unsigned' > /tmp/$$.dnssec
	## ; unsigned answer
	annotate "$record UNSIGNED"
	## ; negative response, unsigned answer
	annotate "$record UNSIGNED NXRECORD"
	## ; fully validated
	annotate "$record VALIDATED"
	## ; negative response, fully validated
	annotate "$record VALIDATED NXRECORD"
	## XXX: Last resort check
	## ;; resolution failed: ncache nxrrset
	#annotate "$record NXRRSET"

	check_dnssec
	if [[ $dnssec != '' ]]; then
		delvcmd="delv -t $class"
	fi
}

container_bootstrap $1
bootstrap_test $1
run_query_set $1 $2
