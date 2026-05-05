resource "aws_instance" "this" {
  ami           = "ami-0b83e5863cd4520e4"
  instance_type = "t3.micro"
  subnet_id     = "subnet-0c14806b04c3bfae1"

  vpc_security_group_ids = "sg-082b43b860166451d"

  key_name = "CuroDevKey"
  )
}
