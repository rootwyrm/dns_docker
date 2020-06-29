So it turns out, doing this on the workstation is not tenable due to issues with VMware Workstation and Windows and sockets. This is skewing the results **badly**. While running the benchmark, basically opening any new sockets is a no-go, and the latency observed reflects a problem in the Windows stack, not actual unbound latency.

Ugh. Just.. ugh.
