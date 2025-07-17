# Network Assignment

This project automates the deployment of an NGINX web server on an AWS EC2 instance using Terraform, Ansible, Docker, and Jenkins.

## Structure

- **Terraform/**: Infrastructure as Code for provisioning AWS resources.
  - `main.tf`: Defines AWS provider, security group, and EC2 instance.
  - `output.tf`: Outputs public IP and DNS of the instance.
  - `.terraform.lock.hcl`, `.terraform/`: Terraform state and provider files.
  - `kasey-aws-krishna.pem`: EC2 SSH key.
- **Ansible/**: Configuration management for EC2.
  - `setup.yml`: Installs Docker and prepares the instance.
  - `ansible.cfg`, `inventory.ini`: Ansible configuration and inventory.
  - `kasey-aws-krishna.pem`: SSH key for Ansible.
- **App/**: NGINX web application.
  - `Dockerfile`: Builds a custom NGINX image.
  - `index.html`: Web page displaying the server’s public IP.
- **Jenkins/**: CI/CD pipeline.
  - `pipeline.txt`: Jenkins pipeline for remote deployment.
- **.env**: Environment variables (not tracked).
- **.gitignore**: Files and folders to ignore in Git.

## Workflow

1. **Provision EC2**: Use Terraform to create an Ubuntu EC2 instance with SSH/HTTP access.
2. **Configure Instance**: Use Ansible to install Docker and set up the environment.
3. **Deploy App**: Jenkins pipeline connects via SSH, clones the repo, injects the server IP into `index.html`, builds and runs the Docker container.
4. **Access Web App**: Visit the EC2 public IP in your browser to see the NGINX welcome page.

## Usage

### 1. Provision Infrastructure

```sh
cd Terraform
terraform init
terraform apply

```


### 2. Configure Server

```sh
cd Ansible
ansible-playbook setup.yml
```

### 3. Deploy Application

Run the Jenkins pipeline defined in [`pipeline.txt`](Jenkins/pipeline.txt).

## Notes

- Ensure your AWS credentials and SSH keys are configured.
- The public IP is injected into the web page at deployment.
- All secrets and sensitive files are ignored via `.gitignore`.