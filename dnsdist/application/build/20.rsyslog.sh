#!/usr/bin/env bash
################################################################################
# Copyright (C) 2020-* Phillip R. Jaenke <prj+docker@rootwyrm.com>
# All rights reserved
#
# CC-BY-NC-3.0
# See /LICENSE for details
################################################################################

## Install rsyslog for dnsdist logging.

. /opt/rootwyrm/lib/system.lib.sh

package_install()
{
    printf 'Installing rsyslog...\n'
	apk add rsyslog
	CHECK_ERROR $? "adding rsyslog"
	rc-update add rsyslog sysinit
	CHECK_ERROR $? "enabling rsyslog"
}

## This is a bit of a horror show to keep it sane...
config_install()
{
    printf 'Installing rsyslog config...\n'
	cat << EOF > /etc/rsyslog.conf
################################################################################
## rsyslog.conf for dns_docker/dnsdist
## DO NOT MODIFY
################################################################################
\$WorkDirectory /var/lib/rsyslog
\$FileOwner root
\$FileGroup adm
\$FileCreateMode 0640
\$DirCreateMode 0750
\$Umask 0022

include(file="/etc/rsyslog.d/*.conf" mode="optional")
include(file="/opt/rootwyrm/etc/rsyslog.d/*.conf" mode="optional")

## Modules
module(load="immark")
module(load="imuxsock")

## Send most messages into the void.
*.info;authpriv.none;cron.none;kern.none;mail.none  -/dev/null
authpriv.*                                          -/dev/null
mail.*                                              -/dev/null
## cron
cron.*          /var/log/cron.log
## dnsdist
local0.*        /var/log/dnsdist.log

EOF
}

package_install
config_install
