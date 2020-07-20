#!/usr/bin/env bash
################################################################################
## Copyright (C) 2020-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
## All rights reserved
##
## Licensed uncer CC-BY-NC-3.0
## See LICENSE for details
################################################################################

## This is a tool for parsing Rapid7's MASSIVE DNS data sets into an 
## OARC-compatible format for benchmarking recursors. Be warned that these
## datasets can reach over 40GB per file!

function usage()
{
	printf 'rapid7_tool.sh\n'
	printf 'Copyright (C) 2020-* Phillip "RootWyrm" Jaenke\n'
	printf 'CC-BY-NC-3.0\n'
	printf '\n'
	printf 'Converts Rapid7 Open Data files into resperf/dnsperf files\n'
	printf '\n'
	printf 'USAGE:\n'
	printf 'rapid7_tool RAPID7_URL OUTPUT_FILE\n'
}

## I hate that I need this function...
function ptr_reverse()
{
    arpa=`echo $1 | awk '{print $1}' | awk -F. '{OFS="."; print $4,$3,$2,$1}'`
    address=`echo $1 | awk -F. '{OFS="."; print $4}'`
    printf '%s.in-addr.arpa\n' $address.$arpa
}

function convert()
{
	## We're converting to a specific format, so, we know what we're doing.
	if [ -z $1 ]; then
		printf 'Lost URL?\n'
		exit 1
	elif [ -z $2 ]; then
		printf ' Lost output file?\n'
		exit 1
	fi
	if [ -f $2 ]; then
		printf 'Deleting existing file!\n'
		rm $2
	else
		touch $2
		if [ $? -ne 0 ]; then
			printf 'Could not create file %s\n' "$2"
			exit 1
		fi
	fi

	FILENAME=${1##/}
	type=$(echo ${FILENAME##*_} | sed -e 's/\.json\.gz//') 
	case $type in
		cname)
			curl -L $1 | zcat | jq -r .name | awk '{print $0" CNAME"}' >> $2
			;;
		a)
			curl -L $1 | zcat | jq -r .name | awk '{print $0" A"}' >> $2
			;;
		aaaa)
			curl -L $1 | zcat | jq -r .name | awk '{print $0" AAAA"}' >> $2
			;;
		any)
			curl -L $1 | zcat | jq -r .name | awk '{print $0" ANY"}' >> $2
			;;
		mx)
			curl -L $1 | zcat | jq -r .name | awk '{print $0" MX"}' >> $2
			;;
		txt)
			curl -L $1 | zcat | jq -r .name | awk '{print $0" TXT"}' >> $2
			;;
		*rdns)
			## PTR records
			curl -L $1 | zcat | jq -r .name | awk -F. '{OFS="."; print $4,$3,$2,$1".in-addr.arpa PTR"}' >> $2
			;;
		*)
			printf 'Unknown type!\n'
			exit 255
			;;
	esac

}

if [ -z $1 ]; then
	usage
elif [ -z $2 ]; then
	usage
else
	convert $1 $2
fi
