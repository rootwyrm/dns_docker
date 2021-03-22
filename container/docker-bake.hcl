group "default" {
	targets = [ "base", "dnsdist", "nsd", "unbound", "bind" ]
}
variable "TAG" {
	default = "latest"
}

target "base" {
	context = "base/"
	tags = ["docker.io/rootwyrm/dns_base"]
	platforms = [ "linux/amd64", "linux/386", "linux/arm64" ] 
}

target "nsd" {
	context = "nsd/"
	tags = ["docker.io/rootwyrm/nsd"]
	platforms = [ "linux/amd64", "linux/386", "linux/arm64" ] 
}

target "unbound" {
	context = "unbound/"
	tags = ["docker.io/rootwyrm/unbound"]
	platforms = [ "linux/amd64", "linux/386", "linux/arm64" ] 
}

target "dnsdist" {
	context = "dnsdist/"
	tags = ["docker.io/rootwyrm/dnsdist"]
	platforms = [ "linux/amd64", "linux/386", "linux/arm64" ] 
}

target "bind" {
	context = "bind/"
	tags = ["docker.io/rootwyrm/bind"]
	platforms = [ "linux/amd64", "linux/386", "linux/arm64" ] 
}
