#!/usr/bin/env bash
################################################################################
## Copyright (C) 2020-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
## All rights reserved
##
## Licensed under CC-BY-NC-3.0
## See /LICENSE for details
################################################################################

if [ -f /opt/rootwyrm/id.service ]; then
	export module=$(cat /opt/rootwyrm/id.service)
else
	export module="UNKNOWN"
fi
if [ -f /opt/rootwyrm/id.release ]; then
	export release=$(cat /opt/rootwyrm/id.release)
else
	export release="HEAD"
fi
if [ -f /opt/rootwyrm/${module}.version ]; then
	export module_version=$(cat /opt/rootwyrm/${module}.version)
else
	export module_version="UNKNOWN"
fi

print_message()
{
	printf '################################################################################\n'
	printf ' dns_docker %s \n' "${release}"
	printf ' %s version %s \n' "${module}" "${module_version}"
	printf ' https://www.github.com/rootwyrm/dns_docker/\n'
	printf '\n'
	printf ' Copyright (C) 2020-* Phillip "RootWyrm" Jaenke\n' 
	printf ' Licensed under CC-BY-NC-3.0\n'
	printf '################################################################################\n'
}

print_message
