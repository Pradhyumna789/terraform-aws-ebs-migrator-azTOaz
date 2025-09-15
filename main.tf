# creates a vpc
resource "aws_vpc" "my-vpc" {
 cidr_block = var.vpc-subnet


 tags = {
   Name = "my-vpc"
 }
}

# creates a subnet for server1
resource "aws_subnet" "server1-subnet" {
 vpc_id            = aws_vpc.my-vpc.id
 cidr_block        = var.public-subnet1-id
 availability_zone = "us-east-1a"

 tags = {
   Name = "server1-subnet"
 }
}

# creates a subnet for server2
resource "aws_subnet" "server2-subnet" {
 vpc_id            = aws_vpc.my-vpc.id
 cidr_block        = var.public-subnet2-id
 availability_zone = "us-east-1b"

 tags = {
   Name = "server2-subnet"
 }
}

# deploying an internet gateway on the vpc
resource "aws_internet_gateway" "my-igw" {
 vpc_id = aws_vpc.my-vpc.id

 tags = {
   Name = "my-vpc-igw"
 }
}

# creating a route table and adding a route to the internet through the internet gateway
resource "aws_route_table" "server1-route-table" {
 vpc_id = aws_vpc.my-vpc.id

 route {
    cidr_block = var.internet-cidr
    gateway_id = aws_internet_gateway.my-igw.id    
 }

 tags = {
   Name = "public-rt"
 }
}

# associating the route table with the public-subnet1
resource "aws_route_table_association" "public-subnet1-internet-access" {
 subnet_id = aws_subnet.server1-subnet.id
 route_table_id = aws_route_table.server1-route-table.id
}

# associating the route table with the public-subnet2
resource "aws_route_table_association" "public-subnet2-internet-access" {
 subnet_id = aws_subnet.server2-subnet.id
 route_table_id = aws_route_table.server1-route-table.id
}

# creating a security group that allows all inbound access from the internet into the server1 ec2 instance
resource "aws_security_group" "server1-internet-access-sc" {
 name = "server1-inbound"
 description = "allow all inbound traffic into EC2 instance server-1"
 vpc_id = aws_vpc.my-vpc.id

 tags = {
   Name = "server1-security-group"
 }

 ingress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


# create an ec2 instance called server1 in us-east-1a
resource "aws_instance" "server1" {
 ami                    = var.amazon-linux-id
 instance_type          = "t2.micro"
 subnet_id              = aws_subnet.server1-subnet.id
 vpc_security_group_ids = [aws_security_group.server1-internet-access-sc.id]
 associate_public_ip_address = true

 tags = {
   Name = "server1"
 }
}

# create an ec2 instance called server2 in us-east-1a 
resource "aws_instance" "server2" {
 ami                    = var.amazon-linux-id
 instance_type          = "t2.micro"
 subnet_id              = aws_subnet.server2-subnet.id
 vpc_security_group_ids = [aws_security_group.server1-internet-access-sc.id]
 associate_public_ip_address = true

 tags = {
   Name = "server2"
 }
}

# deploying an ebs volume in the us-east-1a zone
resource "aws_ebs_volume" "myebs" {
 availability_zone = "us-east-1a"
 size              = 10
 type              = "gp2"


 tags = {
   Name = "myebs"
 }
}


# attaching the myebs ebs volume to server1 ec2 instance
resource "aws_volume_attachment" "volume-attached-to-server1" {
 instance_id = aws_instance.server1.id
 volume_id   = aws_ebs_volume.myebs.id
 device_name = "/dev/sdf"
}

# check these steps before uncommenting the below code
# unmount the device volume from the directory in server1, detach the volume from server1 ec2 instance, and then do terraform apply 

# creating an ebs snapshot of myebs volume
# resource "aws_ebs_snapshot" "myebs-snapshot" {
#     volume_id = aws_ebs_volume.myebs.id

#     tags = {
#         Name = "myebsvolume-snapshot"
#     }
# }

# create a new ebs volume out of the above snapshot
# resource "aws_ebs_volume" "myebs-server2" {
#     availability_zone = "us-east-1b"
#     size = 10
#     snapshot_id = aws_ebs_snapshot.myebs-snapshot.id

#     tags = {
#         Name = "myebs-snapshot-id"
#     }
# }

# attaching the new ebs volume myebs-snapshot to server2
# resource "aws_volume_attachment" "volume-attached-to-server2" {
#     instance_id = aws_instance.server2.id
#     volume_id = aws_ebs_volume.myebs-server2.id
#     device_name = "/dev/sdf"
# }
