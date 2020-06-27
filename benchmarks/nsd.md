## nsd @ 9c43c99
CentOS 8 VM on VMware workstation, i7-3820, 4c/4GB

```
DNS Resolution Performance Testing Tool
Version 2.3.4

[Status] Command line: resperf -f inet -M udp -s 172.16.53.11 -C 10 -d queryfile-example-10million-201202
[Status] Sending
[Status] Fell behind by 1125 queries, ending test at 59541 qps
[Status] Waiting for more responses
[Status] Testing complete

Statistics:

  Queries sent:         1062413
  Queries completed:    1061242
  Queries lost:         1171
  Response codes:       NOERROR 203875 (19.21%), NXDOMAIN 1147 (0.11%), REFUSED 856220 (80.68%)
  Run time (s):         80.721804
  Maximum throughput:   58750.000000 qps
  Lost at that point:   0.00%
```

```
[Status] Command line: dnsperf -f inet -m udp -s 172.16.53.11 -c 1000 -l 60 -d dns_docker/benchmarks/root-servers-query
[Status] Sending queries (to 172.16.53.11)
[Status] Started at: Sat Jun 27 13:02:40 2020
[Status] Stopping after 60.000000 seconds
[Status] Testing complete (time limit)

Statistics:

  Queries sent:         3955009
  Queries completed:    3955009 (100.00%)
  Queries lost:         0 (0.00%)

  Response codes:       NOERROR 3955009 (100.00%)
  Average packet size:  request 36, response 506
  Run time (s):         60.000424
  Queries per second:   65916.350858

  Average Latency (s):  0.000850 (min 0.000048, max 0.021585)
  Latency StdDev (s):   0.000622
```

