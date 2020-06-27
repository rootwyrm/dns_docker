# dnsdist @ 9c43c99

## 10million-201202
```
DNS Resolution Performance Testing Tool
Version 2.3.4

[Status] Command line: resperf -f inet -M udp -s 172.16.53.10 -C 10 -d queryfile-example-10million-201202
[Status] Sending
[Status] Reached 65536 outstanding queries
[Status] Waiting for more responses
[Status] Testing complete

Statistics:

  Queries sent:         94682
  Queries completed:    29234
  Queries lost:         65448
  Response codes:       NOERROR 25679 (87.84%), SERVFAIL 77 (0.26%), NXDOMAIN 3478 (11.90%)
  Run time (s):         55.659194
  Maximum throughput:   6158.000000 qps
  Lost at that point:   1.47%


```

## Stride Testing
```
DNS Performance Testing Tool
Version 2.3.4

[Status] Command line: dnsperf -f inet -m udp -s 172.16.53.10 -c 1000 -l 60 -d dns_docker/benchmarks/queryfile-example-10million-201202
[Status] Sending queries (to 172.16.53.10)
[Status] Started at: Sat Jun 27 13:32:03 2020
[Status] Stopping after 60.000000 seconds

Statistics:

  Queries sent:         51226
  Queries completed:    50844 (99.25%)
  Queries lost:         382 (0.75%)

  Response codes:       NOERROR 38979 (76.66%), SERVFAIL 372 (0.73%), NXDOMAIN 11493 (22.60%)
  Average packet size:  request 38, response 132
  Run time (s):         62.150723
  Queries per second:   818.075761

  Average Latency (s):  0.081614 (min 0.000107, max 4.971899)
  Latency StdDev (s):   0.278168

DNS Performance Testing Tool
Version 2.3.4

[Status] Command line: dnsperf -f inet -m udp -s 172.16.53.10 -c 1000 -l 60 -d dns_docker/benchmarks/root-servers-query
[Status] Sending queries (to 172.16.53.10)
[Status] Started at: Sat Jun 27 13:34:49 2020
[Status] Stopping after 60.000000 seconds
[Status] Testing complete (time limit)

Statistics:

  Queries sent:         1709870
  Queries completed:    1709870 (100.00%)
  Queries lost:         0 (0.00%)

  Response codes:       NOERROR 1709870 (100.00%)
  Average packet size:  request 36, response 506
  Run time (s):         60.000628
  Queries per second:   28497.535059

  Average Latency (s):  0.002697 (min 0.000140, max 0.022811)
  Latency StdDev (s):   0.001156
						
```
