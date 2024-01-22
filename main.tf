resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.myRT.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.myRT.id
}

resource "aws_security_group" "mySG" {
  name = "web-sg"
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_s3_bucket" "myS3" {
  bucket = "my-tf-s3-sampleapp.com"
}

resource "aws_s3_bucket_public_access_block" "mys3ownership" {
  bucket = aws_s3_bucket.myS3.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "myacl" {
  bucket = aws_s3_bucket.myS3.id
  acl    = "public-read"
}

resource "aws_instance" "webserver1" {
  ami = "ami-07c589821f2b353aa"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.mySG.id ]
  subnet_id = aws_subnet.sub1.id
  key_name = "aws_firstInstance"
  user_data = base64encode(file("userdata1.sh"))
}

resource "aws_instance" "webserver2" {
  ami = "ami-07c589821f2b353aa"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.mySG.id ]
  subnet_id = aws_subnet.sub2.id
  key_name = "aws_firstInstance"
  user_data = base64encode(file("userdata2.sh"))
}

resource "aws_lb" "myalb" {
  name               = "my-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mySG.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "web-tag"
  }
}

resource "aws_lb_target_group" "tg" {
  name = "myTG"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "tgAttachment1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "tgAttachment2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.webserver2.id
  port = 80
}

resource "aws_lb_listener" "lbListener" {
  load_balancer_arn = aws_lb.myalb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type = "forward"
  }
}