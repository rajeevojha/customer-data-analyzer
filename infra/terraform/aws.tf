# Security Group
resource "aws_security_group" "app_sg" {
  name        = "training-app-sg"
  description = "Allow 22, 3000 and 5432"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }
                                    
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role
resource "aws_iam_role" "ec2_role" {
  name = "training-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# IAM Policy
resource "aws_iam_policy" "ec2_policy" {
  name = "training-ec2-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject"]
        Resource = [
          "arn:aws:s3:::customer-data-training-ro",
          "arn:aws:s3:::customer-data-training-ro/*"
        ]
      },
      {
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:us-west-1:054037126688:log-group:training-aws:*"
      },
      # CloudWatch perms
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "training-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
#resource "aws_ssm_parameter" "redis_host" {
#  name  = "/redis/host"
#  type  = "SecureString"
#  value = var.redis_host
#}
#resource "aws_ssm_parameter" "redis_password" {
#  name  = "/redis/password"
#  type  = "SecureString"
#  value = var.redis_password
#}
# AWS EC2
resource "aws_instance" "app" {
  ami           = "ami-07d2649d67dbe8900" # Ubuntu 22.04 us-west-1
  instance_type = "t3.micro"
  key_name      = "cloud9"       # e.g., my-key (from AWS EC2 > Key Pairs)
  tags          = { Name = "training-aws" }
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  user_data     = <<-EOF
                 #!/bin/bash
                  rm -f /home/ubuntu/app
                  mkdir -p /home/ubuntu/app
                  git clone https://github.com/rajeevojha/customer-data-analyzer.git /home/ubuntu/app 2>/tmp/git-error
                  cd /home/ubuntu/app/scripts || echo "cd failed" >>/tmp/git-error 
                  cp /home/ubuntu/app/node/aws/app.js /home/ubuntu/app.js
                  cd /home/ubuntu/app/scripts
                  chmod +x install.sh gcp-section.sh run.sh
                  bash ./install.sh 2>/tmp/install-error
                  bash ./aws-section.sh 2>/tmp/aws-error
                  chown ubuntu:ubuntu -R /home/ubuntu/app
                  chmod -R 777 /home/ubuntu/app
                  bash ./run.sh 2>/tmp/run-error
                  EOF
  provisioner "file" {
    source      = "../../.env"
    destination = "/home/ubuntu/app/.env"
    connection {
      type        = "ssh"
      user        = "ubuntu"
     private_key = file("/mnt/c/Users/rajeev/devl/cloud/aws/cloud9.pem")
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
             "ls -ld /home/ubuntu /home/ubuntu/app /home/ubuntu/app/.env > /tmp/ls-out 2>/tmp/ls-error",
      "whoami > /tmp/whoami-out",
      "echo $SSH_CONNECTION >> /tmp/ssh-out"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/mnt/c/Users/rajeev/devl/cloud/aws/cloud9.pem")
      host        = self.public_ip
    }
  }
 }

output "aws_ec2_ip" {
  value = replace(aws_instance.app.public_ip,".","-")
}
