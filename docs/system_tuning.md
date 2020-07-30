**Documentation says these are disallowed and not supported but behavior under Alpine shows they get set on the host if set in the docker-compose!**

Increase maximum connections; 10240 is good to about 1000 clients of mixed type (udp/tcp/doh)
* net.core.somaxconn=10240

Do not use ramping, or latency will tend to be unacceptable.
* net.ipv4.tcp_slow_start_after_idle=0
* net.ipv4.tcp_fastopen=3

dnsdist can get quite busy, so permit up to 16MB buffers
* net.ipv4.tcp_rmem=1024 87380 16777216
* net.ipv4.tcp_wmem=1024 87380 16777216

... or use these for 10GbE ONLY
* net.ipv4.tcp_rmem=1024 87380 33554432 
* net.ipv4.tcp_wmem=1024 65536 33554432

If TCP MTU probing is disabled, upstream TLS may fail.
* net.ipv4.tcp_mtu_probing=1

Reduce timeouts, and reuse connections aggressively.
* net.ipv4.tcp_fin_timeout=15
* net.ipv4.tcp_tw_reuse=1

Testing shows much better performance with htcp generally.
* net.ipv4.tcp_congestion_control=htcp
