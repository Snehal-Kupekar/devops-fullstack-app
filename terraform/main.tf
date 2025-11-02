provider "aws" {
  region = var.aws_region
  profile = "terraform"
}


resource "aws_security_group" "sg" {
  name        = "kind-sg"
  description = "Allow SSH and app access"

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
   ingress {
      from_port   = 30080
      to_port     = 30080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_instance" "kind_ec2" {
  ami                    = "ami-0ecb62995f68bb549" # Ubuntu 
  instance_type          = "t3.medium"
  key_name               = "terraformKeypair"
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io curl
    systemctl enable docker
    systemctl start docker

    # install kind
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
    chmod +x ./kind
    mv ./kind /usr/local/bin/kind

    # install kubectl
    curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/

    # create kind cluster
    cat <<EOC > kind-config.yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      extraPortMappings:
      - containerPort: 30080
        hostPort: 30080
    EOC

    kind create cluster --config kind-config.yaml
    echo "Kind cluster created"
  EOF

  tags = {
    Name = "Kind-EC2"
    CreatedBy="snehal"
  }
}

output "ec2_public_ip" {
  value = aws_instance.kind_ec2.public_ip
}
