#!/bin/bash
################################################################################
## Copyright (C) 2020-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
## All rights reserved
##
## Licensed uncer CC-BY-NC-3.0
## See LICENSE for details
################################################################################

## Ingest dockerenv to get the target
. /.dockerenv

if [ -z $TARGET ]; then
	echo "No TARGET defined."
	exit 1
fi

#curl -L -o recurse.csv https://raw.githubusercontent.com/rootwyrm/dns_docker/master/ci/tests/query/recurse.csv

#for x in `cat recurse.csv | grep -v ^#`; do
#	record=$(echo $x | cut -d , -f 1)
#	type=$(echo $x | cut -d , -f 2)
#	printf '%s\t%s\n' "$record" "$type" >> oarc_set1
#done
## We have to bloat the set tremendously.
#for x in {1..1024}; do
#	cat oarc_set1 >> oarc_set
#done
## Run resperf now.
#printf 'Running resperf UDP %s\n' "$TARGET"
#resperf -f inet -M udp -L 10 -C 10 -P /tmp/$(hostname)_resperf.udp.gnuplot -d oarc_set -s $TARGET
#printf 'Running resperf UDP DNSSEC %s\n' "$TARGET"
#resperf -f inet -M udp -L 10 -C 10 -P /tmp/$(hostname)_resperf.udp_dnssec.gnuplot -D -d oarc_set -s $TARGET
#printf 'Running resperf TCP %s\n' "$TARGET"
#resperf -f inet -M tcp -L 10 -C 10 -P /tmp/$(hostname)_resperf.tcp.gnuplot -d oarc_set -s $TARGET
#printf 'Running resperf TCP DNSSEC %s\n' "$TARGET"
#resperf -f inet -M tcp -L 10 -C 10 -P /tmp/$(hostname)_resperf.tcp_dnssec.gnuplot -D -d oarc_set -s $TARGET

## XXX: Use the rapid7 sets...
function resperf_udp()
{
	if [ -z $1 ]; then
		printf 'No dataset file specified!\n' 
		exit 1
	fi
	## Run 10 clients per CPU
	cpucount=$(cat /proc/cpuinfo | grep ^processor | wc -l)
	client=$(( $cpucount * 10 ))
	printf 'Running UDP - TARGET: %s DATASET: %s\n' "$TARGET" "$1"
	resperf -f inet -M udp -C $client -P /tmp/$(hostname)_resperf.udp.gnuplot -c 300 -m 20000 -d $1 -s $TARGET -p $PORT
	printf 'Running UDP DNSSEC - TARGET: %s DATASET: %s\n' "$TARGET" "$1"
	resperf -f inet -M udp -C $client -P /tmp/$(hostname)_resperf.udp.gnuplot -D -c 300 -m 20000 -d $1 -s $TARGET -p $PORT
}

function dnsperf_udp()
{
	## Really piss the box off...
	if [ -z $1 ]; then
		printf 'dnsperf: no dataset file specified!\n'
		exit 1
	fi
	## Run 10 clients per CPU
	cpucount=$(cat /proc/cpuinfo | grep ^processor | wc -l)
	client=$(( $cpucount * 10 ))
	printf 'dnsperf: running UDP - TARGET: %s DATASET: %s\n' "$TARGET" "$1"
	dnsperf -f inet -m udp -s $TARGET -p 53 -d $1 -c $client -T $cpucount -n 1 -l 300 -q 2000 -Q 20000
}

function rapid7_forward_datafile()
{
	if [ -z $1 ]; then
		printf 'Need URL to feed!\n'
		exit 1
	elif [ -z $2 ]; then
		printf 'Need output file!\n'
		exit 1
	fi
	
	if [ -f $2 ]; then
		## Use existing dataset
		printf 'Using the existing dataset %s\n' "$2"
		return 0
	fi
	## Use the curl method, which still sucks.
	curl -L $1 | zcat | jq -r .name | awk '{print $0" '$BENCHMARK'"}' >> $2
}

function dnsblast()
{
	## Do a quick dnsblast to prime the server for load.
	printf 'dnsblast: Sending 25,000 queries at 100qps\n'
	dnsblast $TARGET 25000 100
	printf 'dnsblast: Sending 25,000 fuzzed queries at 100qps\n'
	dnsblast fuzz $TARGET 25000 100
}

if [ ! -d /opt/rootwyrm/data ]; then
	mkdir /opt/rootwyrm/data
fi

printf '********************************************************************************\n'
printf 'DO NOT RUN THIS TOOL AGAINST SERVERS WHICH ARE NOT UNDER YOUR DIRECT CONTROL\n'
printf 'OR FOR WHICH YOU DO NOT HAVE EXPLICIT AUTHORIZATION!!\n'
printf '********************************************************************************\n'
if [ -z $PORT ]; then
	PORT=53
else
	PORT=$PORT
fi
printf 'You are about to run against %s:%s which is %s\n' "$TARGET" "$PORT" "$(dig -x $TARGET @9.9.9.9 +short)"
printf '\n' 
printf 'Press enter in the next 30 seconds to confirm you are authorized to do this.\n'
printf 'Press ^C otherwise.\n'
while [ true ]; do
	read -t 30 -n 1
	if [ $? = 0 ]; then
		case $BENCHMARK in
			[Cc][Nn][Aa][Mm][Ee])
				OPENDATA="https://opendata.rapid7.com/sonar.fdns_v2/2020-06-28-1593366733-fdns_cname.json.gz" 
				DATA_FILE="/opt/rootwyrm/data/rapid7_cname"
				## XXX: doesn't exit when done??
				#dnsblast
				rapid7_forward_datafile $OPENDATA $DATA_FILE
				resperf_udp $DATA_FILE
				;;
			[Aa])
				OPENDATA="https://opendata.rapid7.com/sonar.fdns_v2/2020-06-27-1593295847-fdns_a.json.gz"
				DATA_FILE="/opt/rootwyrm/data/rapid7_a"
				## XXX: doesn't exit when done??
				#dnsblast
				## Oh boy, warn 'em...
				printf 'WARNING: Working with a 23GB+(!!) dataset!\n'
				rapid7_forward_datafile $OPENDATA $DATA_FILE
				resperf_udp $OPEN
				;;
			[Aa][Aa][Aa][Aa])
				OPENDATA="https://opendata.rapid7.com/sonar.fdns_v2/2020-06-26-1593210450-fdns_aaaa.json.gz"
				DATA_FILE="/opt/oarc/rapid7_aaaa"
				## XXX: doesn't exit when done??
				#dnsblast
				## 4.1GB as of June, jeez.
				rapid7_forward_datafile $OPENDATA $DATA_FILE
				resperf_udp $DATA_FILE
				;;
			*)
				printf 'Unsupported or unknown benchmark type, or not set.\n'
				exit 1
				;;
		esac
	else
		break
	fi
done

