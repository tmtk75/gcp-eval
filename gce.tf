variable instance_name { default = "test-gce" }
variable region        { default = "asia-east1" }
variable cidr_home {}

provider "google" {
    credentials = "${file("./credentials.json")}"
    project     = "gcp-eval"
    region      = "${var.region}-c"
}

resource "google_compute_network" "default" {
    name = "${var.instance_name}"
}

resource "google_compute_subnetwork" "default-asia-east1" {
    name          = "default-${var.region}"
    ip_cidr_range = "10.1.0.0/24"
    network       = "${google_compute_network.default.self_link}"
    region        = "${var.region}"
}

resource "google_compute_firewall" "default" {
    name    = "${var.instance_name}"
    network = "${google_compute_network.default.name}"

    allow {
        protocol = "tcp"
        ports    = ["80", "443", "3000"]
    }

    source_tags   = ["http-server"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh" {
    name    = "${var.instance_name}-ssh"
    network = "${google_compute_network.default.name}"

    allow {
        protocol = "tcp"
        ports    = ["22"]
    }

    source_ranges = ["${var.cidr_home}"]
}

resource "google_compute_instance" "default" {
    name         = "${var.instance_name}"
    machine_type = "f1-micro"
    zone         = "${var.region}-c"
    tags         = ["http-server"]

    disk {
        image = "centos-7-v20160329"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.default-asia-east1.name}"
	access_config {
	    nat_ip = "${google_compute_address.default.address}"
	}
    }
} 

resource "google_compute_address" "default" {
    name   = "${var.instance_name}-address"
    region = "${var.region}"
}

output ip { value = "${google_compute_address.default.address}" }
