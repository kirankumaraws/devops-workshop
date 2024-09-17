provider "aws" {
    region="us-east-1"
}

resource "aws_instance" "demo-server"{

    ami="ami-0182f373e66f89c85"
    instance_type="t2.micro"
    key_name="ddp"
    vpc_security_group_ids =   [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.ddp-public-subnet-01.id
}

resource "aws_security_group" "demo-sg"{
    name ="demo-sg"
    description ="SSH Access"

ingress{
   description="ssh access"
   from_port=22
   to_port=22
   protocol="tcp"
   cidr_blocks = ["0.0.0.0/0"]
}
egress{
    from_port=0
    to_port=0   
    protocol="-1"
    cidr_blocks=["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

}

tags = {
Name = "SSH Port"
}

}    

resource "aws_vpc" "ddp-vpc"{
    cidr_block="10.1.0.0\16"
    tags{
        Name = "ddp-vpc"
    }
}

resource "aws_subnet" "ddp-public-subnet-01"{
    vpc_id= aws_vpc.ddp-vpc.id
    cidr_block="10.1.1.0\24"
    map_public_ip_on_launch ="true"
    availibility_zone = "us-east-1a"
    tags = {
        Name = "ddp-public-subnet-01"
    }
}

resource "aws_subnet" "ddp-public-subnet-02"{
    vpc_id= aws_vpc.ddp-vpc.id
    cidr_block="10.1.2.0\24"
    map_public_ip_on_launch ="true"
    availibility_zone = "us-east-1b"
    tags = {
        Name = "ddp-public-subnet-02"
    }

}

resource "aws_internet_gateway" "ddp-igw"{
    vpc_id=aws_vpc.ddp-vpc.id
    tags = {
            Name ="ddp-igw"
    }
}

resource "aws_route_table" "ddp-public-rt"{
    vpc_id = aws_vpc.ddp-vpc.id
     route {
        cidr_block = "0.0.0.0\0"
        gateway_id = aws_internet_gateway.ddp-igw.id
     }
}

resource "aws_route_table_association" "ddp-rta-public-subnet-01"{
    subnet_id= aws_subnet.ddp-public-subnet-01.id
    route_table_id= aws_route_table.ddp-public-rt.id
}

resource "aws_route_table_association" "ddp-rta-public-subnet-02"{
    subnet_id= aws_subnet.ddp-public-subnet-02.id
    route_table_id= aws_route_table.ddp-public-rt.id
}