# dns_bench

**DO NOT RANDOMLY BENCHMARK SERVERS. THIS IS DESIGNED TO STRESS SERVERS TO THE BREAKING POINT. ONLY RUN THIS AGAINST SERVERS YOU HAVE AUTHORIZATION TO. THEY WILL BREAK!!**

This uses the Rapid7 open data sets for the query list. THIS IS A VERY LARGE DATASET. Some benchmarks will need over 60GB of disk space to run!

## Use
`docker run --rm --env TARGET=target.server.ip --env BENCHMARK={supported_type} rootwyrm/dns_bench`

To run against a port other than 53:
`--env PORT={arbitrary port}`

Supported Types:
* CNAME
* A
* AAAA
(others are not ready quite yet.)

## HOLY CRAP THAT'S A HUGE DATASET!!
You can use a volume so you don't have to download it a bunch of times. (Please do.)

`docker run --rm --volume /directory/containing/data:/opt/rootwyrm/data --env TARGET=target.server.ip --env BENCHMARK=type rootwyrm/dns_bench`

You can (should!) use the `rapid7_tool.sh` to preprocess files whenever possible. They follow the following scheme:

* CNAME = rapid7_cname
* A = rapid7_a
* AAAA = rapid7_aaaa
