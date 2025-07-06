
#  Cloud-based Automated Container Deployment using Terraform, Jenkins, Ansible & Docker

# Project Overview 

This project presents a full-stack DevOps pipeline which automates the deployment of a Dockerized web app on an AWS EC2 instance.The aim was to install end-to-end infrastructure provisioning and application deployment with industry-standard tools as a part of the *Network Systems and Administration CA 2025 (B9IS121)* module.
# Tools and Technologies Used

- **Terraform** – Infrastructure provisioning on AWS
- **Jenkins** – CI/CD automation for application deployment
- **Ansible** – Server configuration and Docker installation
- **Docker** – Containerization of the web application
- **AWS EC2** – Virtual cloud server to host the application

# Project Structure

```
Project/
│
├── terraform/
│   ├── main.tf
│   └── output.tf
│
├── ansible/
│   └── install_docker.yml
│
├── jenkins/
│   └── Jenkinsfile
│
├── App/
│   ├── index.html
│   └── Dockerfile
│
└── README.md
```

# Terraform Configuration (By Krishna Sharma)

# `main.tf`

Defines AWS infrastructure:

- Region: `eu-west-1`
- Default VPC
- Security Group allowing SSH (port 22) and HTTP (port 80)
- EC2 instance (`t2.micro`) with Amazon Linux 2 AMI
- Associates key pair `kasey-aws-krishna.pem`

```hcl
provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "free_tier_instance" {
  ami                    = "ami-01f23391a59163da9"
  instance_type          = "t2.micro"
  key_name               = "kasey-aws-krishna"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "FreeTierAmazonLinux"
  }
}
```

# `output.tf`

Outputs the public IP and DNS of the EC2 instance:

```hcl
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.free_tier_instance.public_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.free_tier_instance.public_dns
}
```

# Run Instructions

```bash
cd terraform
terraform init
terraform apply
```

# Ansible Playbook (By Ashok)

# `install_docker.yml`

Installs Docker on the EC2 instance via SSH using Ansible.

```yaml
---
- name: Install Docker on EC2
  hosts: aws_ec2
  become: yes
  tasks:
    - name: Update apt cache
      apt: update_cache=yes

    - name: Install Docker
      apt: name=docker.io state=present

    - name: Start and enable Docker
      service:
        name: docker
        state: started
        enabled: yes
```

# Run Instructions

Configure `inventory` with EC2 public IP and then:

```bash
ansible-playbook -i inventory install_docker.yml
```

# Jenkins Pipeline Script (By Krishna Sharma)

# `Jenkinsfile`

Automates deployment:

1. SSH into EC2
2. Clone or update the GitHub repo
3. Replace `__SERVER_IP__` in `index.html`
4. Build Docker image
5. Run Docker container on port 80

```groovy
pipeline {
  agent any

  stages {
    stage('Deploy on Remote Server') {
      steps {
        sh '''
          ssh -i /Users/kaseysharma/Desktop/Network/Ansible/kasey-aws-krishna.pem ubuntu@3.255.89.10 << 'EOF'
cd /home/ubuntu
if [ ! -d Network ]; then
  git clone https://github.com/Kasey0998/Network.git
else
  cd Network
  git pull
  cd ..
fi

cd Network/App
SERVER_IP=$(curl -s ifconfig.io)
sed -i "s/__SERVER_IP__/$SERVER_IP/" index.html

sudo docker build -t nginx-custom .
sudo docker stop nginx-web || true
sudo docker rm nginx-web || true
sudo docker run -d --name nginx-web -p 80:80 nginx-custom
EOF
        '''
      }
    }
  }
}
```

> Replace the `.pem` key path and IP address with your own setup.

# Docker Configuration (By Abhishek)

# `Dockerfile`

Builds a custom Nginx image with the application page.

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html
```

# Web Application (`index.html`)

Simple HTML page with a placeholder that gets replaced dynamically during deployment.

```html
<!DOCTYPE html>
<html>
<head>
  <title>Deployed App</title>
</head>
<body>
  <h1>Welcome to the App hosted on __SERVER_IP__</h1>
</body>
</html>
```

# Deployment Workflow Summary

1. **Terraform** provisions EC2 and security group
2. **Ansible** installs Docker on EC2
3. **Jenkins** SSHs into EC2 and deploys the app using Docker
4. **Docker** container runs the app and serves it on EC2’s public IP

# Accessing the Application

After deployment:

1. Find the EC2 public IP from Terraform output
2. Open browser and navigate to:
   ```
   http://<EC2_PUBLIC_IP>
   ```

# Team Member Contributions

| Member          | Contribution                                    |
|------------------|------------------------------------------------|
| **Krishna Sharma** | Terraform scripts, Jenkins pipeline & EC2 deployment |
| **Ashok**           | Ansible playbook for Docker installation        |
| **Abhishek**        | Dockerfile creation and web app setup           |

# Troubleshooting

| Issue                            | Solution                                      |
|----------------------------------|-----------------------------------------------|
| SSH permission denied            | Ensure correct key permissions (`chmod 400`)  |
| Jenkins cannot connect to EC2    | Check firewall rules and IP address           |
| Docker not installed             | Rerun Ansible playbook                        |
| App not loading                  | Check Docker logs: `docker logs nginx-web`    |

# Security Notes

- SSH key must be securely stored and protected
- Open ports: only **22** and **80** (use HTTPS for production)
- Terraform and Jenkins credentials should be secret-managed in production

# References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Ansible on AWS EC2](https://docs.ansible.com/)
- [Docker Getting Started](https://docs.docker.com/get-started/)
- [AWS EC2 Guide](https://docs.aws.amazon.com/ec2/)


