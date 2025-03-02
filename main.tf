provider "aws" {
  region = "eu-west-1"  # Setează regiunea AWS (modifică dacă este necesar)
}

# Security Group 
resource "aws_security_group" "allow_ssh123" {
  name        = "allow_ssh123"
  description = "Allow SSH access"
  vpc_id      = "vpc-08c9fe77889dfa031"  # Aici trebuie să adaugi VPC ID-ul tău
# permisiuni pentru porturi
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite accesul SSH din orice sursă
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite accesul SSH din orice sursă
  }

 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite accesul SSH din orice sursă
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permite toate conexiunile de ieșire
  }
}

# instanta EC2
resource "aws_instance" "test_instance" {
  ami           = "ami-03fd334507439f4d1"  # ID-ul AMI-ului pentru EC2 (verifică pentru regiunea ta)
  instance_type = "t2.micro"  # Tipul instanței

  # atasam security group-ul
  security_groups = [aws_security_group.allow_ssh123.name]

  # SSH key
  key_name = "Horatiu_project"  # Înlocuiește cu numele cheii tale SSH din AWS

  tags = {
    Name = "instance_from_pipeline"
  }
}
# elastic ip
resource "aws_eip_association" "eip_attach" {
  instance_id   = aws_instance.test_instance.id
  allocation_id = "eipalloc-0d9eb2fae9bac9d27"
}
