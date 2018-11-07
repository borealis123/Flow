# s3 bucket for dumping flow log to----------------------------------
resource "aws_s3_bucket" "dump" {
	bucket = "test-bucket"
	acl    = "private"
	
	tags {
		Name = "primary bucket"
	}
}

# Security group for bucket------------------------------------------

resource "aws_security_group" "flow_bucket" {
    name = "vpc_bucket"
    description = "Allow management and outgoing traffic for updates"


    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "flow bucket"
    }
}
