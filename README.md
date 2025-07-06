
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
│   ├── inventory.ini
│   └── setup.yml
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
- EC2 instance (`t2.micro`) with Ubuntu 24.04 LTS
- Associates key pair `kasey-aws-krishna.pem`

```hcl
provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "allow_ssh_http"
  }
}

data "aws_vpc" "default" {
  default = true
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

# `setup.yml`

Installs Docker on the EC2 instance via SSH using Ansible.

```yaml
---
- name: Prepare EC2 Ubuntu instance and install Docker
  hosts: ec2_instances
  become: yes
  vars:
    new_hostname: my-network-assignment

  tasks:
    - name: Update all packages cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Upgrade all packages to the latest version
      apt:
        upgrade: dist

    - name: Set the hostname
      hostname:
        name: "{{ new_hostname }}"

    - name: Install required packages for Docker
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - gnupg
          - lsb-release
        state: present

    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker APT repository
      apt_repository:
        repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        state: present
        filename: docker

    - name: Update APT again after adding Docker repo
      apt:
        update_cache: yes

    - name: Install Docker CE
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: latest

    - name: Start and enable Docker service
      systemd:
        name: docker
        state: started
        enabled: yes
```
# inventory.ini
```ini
[ec2_instances]
3.255.89.10 ansible_user=ubuntu ansible_ssh_private_key_file=/Users/kaseysharma/Desktop/Network/Ansible/kasey-aws-krishna.pem
```

# Run Instructions

Configure `inventory` with EC2 public IP and then:

```bash
ansible-playbook -i inventory install_docker.yml
```
> Replace the `.pem` key path and IP address with your own setup for other users.

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
# Clone or update the repo on the server
cd /home/ubuntu
if [ ! -d Network ]; then
  git clone https://github.com/Kasey0998/Network.git
else
  cd Network
  git pull
  cd ..
fi

# Go to the app folder
cd Network/App

# Fetch the public IP and inject into index.html
SERVER_IP=$(curl -s ifconfig.io)
sed -i "s/__SERVER_IP__/$SERVER_IP/" index.html

# Build and run Docker container
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

> Replace the `.pem` key path and IP address with your own setup for other users.

# Docker Configuration (By Abhishek)

# `Dockerfile`

Builds a custom Nginx image with the application page.

```dockerfile
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
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


- Walker, M., 2021. Building Robust CI/CD Pipelines Using Jenkins and Groovy. [online] Baeldung. Available at: https://www.baeldung.com/ops/jenkins-scripted-vs-declarative-pipelines
- Sumeet Ninawe, 2025. Terraform Tutorial – Getting Started With Terraform. Spacelift Blog. [online] Available at: https://spacelift.io/blog/terraform-tutorial#how-to-get-started-using-terraform
- Khan, S., 2024. Jenkins Pipeline: Getting Started Tutorial For Beginners [With Examples]. LambdaTest Blog. [online] Available at: https://www.lambdatest.com/blog/jenkins-pipeline-tutorial/
- GeeksforGeeks, 2024. Groovy's Domain-Specific Language (DSL) for Jenkins Pipelines. [online] Available at: https://www.geeksforgeeks.org/devops/groovys-domain-specific-language-dsl-for-jenkins-pipelines/.
- wHernández, A., 2024. How to install Docker using Ansible. [online] Available at: https://alexhernandez.info/articles/infrastructure/how-to-install-docker-using-ansible/.
- Docker Docs, 2024. Writing a Dockerfile. [online] Available at: https://docs.docker.com/get-started/docker-concepts/building-images/writing-a-dockerfile/.
TutorialsPoint, 2024. Dockerfile. [online] Available at: https://www.tutorialspoint.com/docker/docker_file.htm.