
        #Selecting default VPC. In the next block we will attach this VPC to the security groups.
data "aws_vpc" "selected" {
        filter {
                name    = "tag:Name"
                values  = ["default"]
        }
}

 #Create new aws security group for database instance. Only MySQL and SSH ports is open for outside.
resource "aws_security_group" "app_sg" {
        name            = "app_ssh"
        description     = "App server"
        vpc_id          = "${data.aws_vpc.selected.id}" #Default VPC id here

        ingress { # Web server
                from_port       = 80
                to_port         = 80
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
        }

        ingress { # Web server
                from_port       = 443
                to_port         = 443
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
        }

        ingress { #SSH Port
                from_port       = 22
                to_port         = 22
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]
        }

        egress  { #Outbound all allow
                from_port       = 0
                to_port         = 0
                protocol        = -1
                cidr_blocks     = ["0.0.0.0/0"]
        }

        tags {
                Name            = "APP_SSH"
        }
}

resource "aws_instance" "app_server" {
 
  ami           = "ami-035b3c7efe6d061d5"
  instance_type = "${var.server_instance_type}"
  key_name      = "oracle"
  vpc_security_group_ids = ["${aws_security_group.app_sg.id}"]
  
  tags {
   name = "App"
  }
 
  provisioner "remote-exec" {
                inline = ["sudo hostname"]

                connection {
                        type        = "ssh"
                        user        = "ec2-user"
                        private_key = "${file(var.ssh_private_key)}"
                }
  }
   #Modify index.php_template with database instance IP address for MySQL  connection. 
        provisioner "local-exec" {
                command ="cp /home/cmosmar/Documents/oracle-pipeline/oracledev/ansible/roles/app/files/index.html_template /home/cmosmar/Documents/oracle-pipeline/oracledev/ansible/roles/app/files/index.html && sed -i 's/EC2_HOSTNAME/\"${aws_instance.app_server.id}\"/g' /home/cmosmar/Documents/oracle-pipeline/oracledev/ansible/roles/app/files/index.html"
        }

        provisioner "local-exec" {
                command ="ansible-playbook -i /etc/ansible/ec2.py /home/cmosmar/Documents/oracle-pipeline/oracledev/ansible/web-server.yml --private-key=oracle.pem --user ec2-user"
        }
}
