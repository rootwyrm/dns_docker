group "default" {
	targets = [ "base" ]
}

target "base" {
	targets = [ "base" ]
	tags = ["docker.io/rootwyrm/dns_base"]
	context = "base/"
	platforms = [ "linux/amd64", "linux/arm64", "linux/386" ]
	progress = "plain"
	output = [ "type=registry,dest=localhost:5000" ]
	#output = [ "type=local,dest=image" ]
}

target "nsd" {
	targets = [ "nsd" ]
	tags = ["docker.io/rootwyrm/nsd"]
	context = "nsd/"
	platforms = [ "linux/amd64", "linux/arm64", "linux/386" ]
}
