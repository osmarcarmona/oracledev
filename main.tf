resource "aws_instance" "example" {
 
  ami         = "ami-0d8f6eb4f641ef691"
  instance_type = "t2.micro"
 
  tags {
 
  name = "TESTVM"
 
  }
 
}
