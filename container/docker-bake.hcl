group "default" {
	targets = [ "base" ]
}

target "base" {
	targets = [ "base" ]
	tags = ["docker.io/rootwyrm/dns_base"]
	context = "base/"
	platforms = [ "linux/amd64", "linux/arm64", "linux/386" ]
	progress = "plain"
}

target "nsd" {
	targets = [ "nsd" ]
	tags = ["docker.io/rootwyrm/nsd"]
	context = "nsd/"
	platforms = [ "linux/amd64", "linux/arm64", "linux/arm/v7", "linux/386" ]
	progress = "plain"
}

target "unbound" {
	targets = [ "unbound" ]
	tags = ["docker.io/rootwyrm/unbound"]
	context = "unbound/"
	platforms = [ "linux/amd64", "linux/arm64", "linux/arm/v7", "linux/386" ]
	progress = "plain"
}

target "dnsdist" {
	targets = [ "dnsdist" ]
	tags = ["docker.io/rootwyrm/dnsdist"]
	context = "dnsdist/"
	platforms = [ "linux/amd64", "linux/arm64", "linux/arm/v7", "linux/386" ]
	progress = "plain"
}


