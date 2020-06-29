# dns_docker
Complete multi-platform, high performance, scalable DNS suite for use in Docker with extensive user customization.

Built for amd64, i686, arm64, and arm/v7 architectures.

![CC-BY-NC-3.0](https://i.creativecommons.org/l/by-nc/3.0/88x31.png)

---
# CI Status
| Component   | Status               |
|-------------|----------------------|
| Build Train | ![CI - World](https://github.com/rootwyrm/dns_docker/workflows/CI%20-%20World/badge.svg) ![GitHub issues](https://img.shields.io/github/issues/rootwyrm/dns_docker) ![GitHub pull requests](https://img.shields.io/github/issues-pr/rootwyrm/dns_docker) ![GitHub milestones](https://img.shields.io/github/milestones/open/rootwyrm/dns_docker) |
| dnsdist     | ![CICD - dnsdist](https://github.com/rootwyrm/dns_docker/workflows/CICD%20-%20dnsdist/badge.svg) ![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/rootwyrm/dnsdist) |
| unbound     | ![CICD - unbound](https://github.com/rootwyrm/dns_docker/workflows/CICD%20-%20unbound/badge.svg) ![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/rootwyrm/unbound) |
| nsd         | ![CICD - nsd](https://github.com/rootwyrm/dns_docker/workflows/CICD%20-%20nsd/badge.svg) ![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/rootwyrm/nsd) |
|  |  |

# Installation

**Installation using the `master` branch is not generally recommended.**

**Installation instructions are not ready at this time.**

## On Linux / x86_64 and i686
**Installation instructions are not ready at this time.**

No special steps.

## On Linux / arm64
**Installation instructions are not ready at this time.**

Must use `docker-compose` to ensure the correct architecture is pulled; otherwise docker will try to use the amd64 images on arm64.

# Use and Licensing

dns_docker is provided under a CC-BY-NC-3.0 license to prevent abusive behavior by commercial entities. 

What this means in plain English is that you are free to use dns_docker in your home or business, and you may modify it to suit your needs. Generally dns_docker is best for situations where you are in need of a high-performance and secure solution that is also capable of DNS filtering.

You **may not** use it in a commercial product or as any part of a service which you charge for (e.g. filtering DNS services, as a DNS resolver for cloud providers, etcetera.) You are granted a limited exception to use dns_docker where you charge for a service which relies upon DNS but where dns_docker is not directly available to customers and is not incorporated within the service itself.

*If you are looking for a commercial solution, dns_docker is not the appropriate product anyways! You are looking for DNSecure, which is an entirely different beast and is specifically designed to handle hundreds of thousands of queries per second per instance. Contact me for more information on DNSecure.*

dns_docker is proudly built entirely on open source products:
* [PowerDNS dnsdist](https://dnsdist.org) - [GPLv2](https://github.com/PowerDNS/pdns/blob/master/COPYING)
* [NLnet Labs NSD](https://www.nlnetlabs.nl/projects/nsd/about/) - [BSD 3-Clause](https://github.com/NLnetLabs/nsd/blob/master/LICENSE)
* [NLnet Labs unbound](https://nlnetlabs.nl/projects/unbound/about/) - [BSD 3-Clause](https://github.com/NLnetLabs/unbound/blob/master/LICENSE)
