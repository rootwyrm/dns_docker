# unbound @ 9c43c99

## queryfile-example-10million-201202
```
LOGGING MINIMAL
DNS Resolution Performance Testing Tool
Version 2.3.4

[Status] Command line: resperf -f inet -M udp -s 172.16.53.12 -C 10 -d queryfile-example-10million-201202
[Status] Sending
[Status] Reached 65536 outstanding queries
[Status] Waiting for more responses
Warning: received a response with an unexpected id: 15
Warning: received a response with an unexpected id: 174
Warning: received a response with an unexpected id: 331
Warning: received a response with an unexpected id: 62
Warning: received a response with an unexpected id: 2674
Warning: received a response with an unexpected id: 84
Warning: received a response with an unexpected id: 3710
Warning: received a response with an unexpected id: 944
Warning: received a response with an unexpected id: 1493
[Status] Testing complete

Statistics:

  Queries sent:         70022
  Queries completed:    5666
  Queries lost:         64356
  Response codes:       NOERROR 3701 (65.32%), SERVFAIL 543 (9.58%), NXDOMAIN 1422 (25.10%)
  Run time (s):         54.166592
  Maximum throughput:   1456.000000 qps
  Lost at that point:   30.07%
```

### root-servers 
```
[Status] Command line: dnsperf -f inet -m udp -s 172.16.53.12 -c 1000 -l 60 -d dns_docker/benchmarks/root-servers-query
[Status] Sending queries (to 172.16.53.12)
[Status] Started at: Sat Jun 27 13:05:00 2020
[Status] Stopping after 60.000000 seconds
[Status] Testing complete (time limit)

Statistics:

  Queries sent:         3297822
  Queries completed:    3297822 (100.00%)
  Queries lost:         0 (0.00%)

  Response codes:       NOERROR 3297822 (100.00%)
  Average packet size:  request 36, response 58
  Run time (s):         60.000259
  Queries per second:   54963.462741

  Average Latency (s):  0.001028 (min 0.000060, max 0.159946)
  Latency StdDev (s):   0.000863
```
