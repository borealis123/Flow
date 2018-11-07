# Vpc---------------------------------------------------------------

resource "aws_vpc" "main" {
	cidr_block 		 = "${var.vpc_cidr}"
	enable_dns_hostnames = true
	instance_tenancy = "dedicated"
	
	tags {
		name = "primary"
	}
}

# Nat Gateway-------------------------------------------------------

resource "aws_instance" "nat_gateway" {
    ami = "${lookup(var.nat_amis, var.region)}" 
    availability_zone = "us-west-1"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    subnet_id = "${aws_subnet.az_subnet_1.id}"
    vpc_security_group_ids = ["${aws_security_group.nat_sec_grp.id}"]
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "VPC NAT"
    }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat_gateway.id}"
    vpc = true
}

# Nat Sec Grp---------------------------------------------------------------

resource "aws_security_group" "nat_sec_grp" {
	name = "nat_sec_group"
	description = "Traffic from private subnet to internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.subnet2_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.subnet2_cidr}"]
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
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "Nat Security Gateway"
    }
}

# Internet Gateway--------------------------------------------------

resource "aws_internet_gateway" "gw" {
	vpc_id = "${aws_vpc.main.id}"
	
	tags {
		name = "main"
	}
}

# Public Subnet-----------------------------------------------------

resource "aws_subnet" "az_subnet_1" {
	vpc_id 	   = "${aws_vpc.main.id}"
	cidr_block = "${var.subnet1_cidr}"
	
	tags {
		name = "sub1"
	}
}

resource "aws_route_table" "subnet1_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "var.subnet1_cidr"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Subnet1_route"
  }
}

resource "aws_route_table_association" "subnet1" {
    subnet_id = "${aws_subnet.az_subnet_1.id}"
    route_table_id = "${aws_route_table.subnet1_route_table.id}"
}


# Private subnet----------------------------------------------------

resource "aws_subnet" "az_subnet_2" {
	vpc_id     = "${aws_vpc.main.id}"
	cidr_block = "${var.subnet2_cidr}"
	
	tags {
		name = "sub2"
	}
}

resource "aws_route_table" "subnet2_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "var.subnet2_cidr"
    instance_id = "${aws_instance.nat_gateway.id}"
  }

  tags {
    Name = "Subnet1_route"
  }
}

resource "aws_route_table_association" "subnet2" {
    subnet_id = "${aws_subnet.az_subnet_2.id}"
    route_table_id = "${aws_route_table.subnet2_route_table.id}"
}
