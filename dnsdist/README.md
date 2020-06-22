Docker container for dnsdist

**CAUTION: HEAD is on 1.5.0-rc train**

![Build - dnsdist](https://github.com/rootwyrm/dns_docker/workflows/Build%20-%20dnsdist/badge.svg)

## Volume Layout
dnsdist has a very specific volume layout in order to support complex configurations. Configurations will be loaded in the ORDER they are listed here, followed by alphabetical order within that directory.
* conf.d/ - base configuration overrides (e.g. listen, ACLs, web UI)
* lua/ - any standalone Lua programs or snippets must go in this directory
* maps/ - all response mappings (e.g. rate-limits, specific redirects, etc.)
