# Can ignore this file as out of scope. Main focus is on the networking
# in main.tf

data "aws_ami" "aml2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# allows traffic for SSM to work essentially to connect to EC2
resource "aws_security_group" "vpce_sg" {
  name        = "vpce_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpce_sg"
  }
}

# VPC endpoints for session manager into EC2
resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-southeast-1.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.first.id]
  private_dns_enabled = true

  dns_options {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name = "ec2messages-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint_security_group_association" "ec2_messages" {
  vpc_endpoint_id   = aws_vpc_endpoint.ec2_messages.id
  security_group_id = aws_security_group.vpce_sg.id
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-southeast-1.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.first.id]
  private_dns_enabled = true

  dns_options {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name = "ssmmessages-vpc-endpoint"
  }

}

resource "aws_vpc_endpoint_security_group_association" "ssm_messages" {
  vpc_endpoint_id   = aws_vpc_endpoint.ssm_messages.id
  security_group_id = aws_security_group.vpce_sg.id
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-southeast-1.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.first.id]
  private_dns_enabled = true

  dns_options {
    dns_record_ip_type = "ipv4"
  }

  tags = {
    Name = "ssm-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint_security_group_association" "ssm" {
  vpc_endpoint_id   = aws_vpc_endpoint.ssm.id
  security_group_id = aws_security_group.vpce_sg.id
}

# AWS Instance profile to allow SSM to connect to EC2
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy" "ec2_instance_profile_policy" {
  name   = "${aws_iam_role.ec2_role.id}-policy"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy.ssm_managed_instance_core.policy
}