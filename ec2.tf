data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]

}

resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.jenkins-sg.name]
  key_name        = "ansibletest"
  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install epel -y",
      "sudo yum update -y",
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "sudo yum remove java-1.7.0-openjdk -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install jenkins -y",
      "sudo service jenkins start",
      "sudo chkconfig --add jenkins",
    ]
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("/home/vishnu/ansibletest.pem")
  }
  tags = {
    "Name" = "Jenkins"
  }
}