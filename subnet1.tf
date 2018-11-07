# Web Server Instnace--------------------------------------------------
resource "aws_instance" "spider-man" {
	ami 		  = "${lookup(var.amis, var.region)}"
	availability_zone = "us-west-1"
	instance_type = "t2.micro"
	subnet_id 	  = "${aws_subnet.az_subnet_1.id}"
	key_name	  = "${var.aws_key_name}"
	vpc_security_group_ids = ["${aws_security_group.web_sec_grp.id}"]
	associate_public_ip_address = true
    source_dest_check = false
}

resource "aws_eip" "web" {
    instance = "${aws_instance.spider-man.id}"
    vpc = true
}
# Web Server Security Group--------------------------------------------
resource "aws_security_group" "web_sec_grp" {
    name = "vpc_web"
    description = "Allow HTTP connections and managment."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # from corporate network
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"] # from corporate network
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
        Name = "Web Server"
    }
}

# Flow Log----------------------------------------------------------

resource "aws_flow_log" "flow1" {
	log_destination 	 = "${aws_s3_bucket.dump.arn}"
	log_destination_type = "s3"
	traffic_type 		 = "ALL"
	subnet_id 			 = "${aws_subnet.az_subnet_1.id}"
}
