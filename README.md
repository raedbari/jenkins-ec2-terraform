#  Jenkins EC2 Instance on AWS with Terraform

This project uses Terraform to provision an EC2 instance running Jenkins within a custom AWS VPC. It includes networking components such as subnets, internet gateway, route tables, a security group for Jenkins, and an Elastic IP. Jenkins is installed using a Bash script via EC2 user data.

---

##  Tools & Technologies

- **Terraform**
- **AWS Services**:
  - VPC
  - EC2
  - Subnet
  - Internet Gateway
  - Route Table & Associations
  - Elastic IP
  - Security Group
  - AMI Data Source
- **Bash** (for Jenkins installation script)
- **SSH Key Pair**

---

##  Project Structure

### 1. VPC and Subnet
- A custom VPC with DNS hostnames enabled.
- One public subnet using the first available availability zone.

### 2. Networking
- An Internet Gateway connected to the VPC.
- A public route table that routes internet traffic (0.0.0.0/0) through the IGW.
- The public subnet is associated with the route table.

### 3. EC2 Instance (Jenkins)
- EC2 instance is launched using the latest Ubuntu 20.04 AMI.
- Jenkins is installed through a shell script passed via `user_data`.
- The instance is created in the public subnet.

### 4. Security Group
- Allows:
  - Port **8080** (Jenkins web interface) from **anywhere (0.0.0.0/0)**.
  - Port **22** (SSH) only from your own IP `${var.my_ip}/32`.
- All outbound traffic is allowed.

### 5. Elastic IP
- An Elastic IP is attached to the Jenkins EC2 instance for consistent public access.

---
##  Requirements

- Terraform installed
- AWS CLI configured
- Valid SSH key pair located at: `~/ssh/raed-key.pub`
- Make sure the key file has proper permissions:  
  ```bash
  chmod 400 ~/ssh/your-key-name
  ```
---

## ▶️ Getting Started

```bash
git clone https://github.com/raedbari/aws-jenkins-infrastructure.git
cd aws-jenkins-infrastructure

terraform init
terraform apply
```

---
###  Access Jenkins:

1. SSH into the EC2 instance:
   ```bash
   ssh -i ~/ssh/your-key-name ubuntu@<your-eip>
   ```

2. Get the initial Jenkins admin password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. Open Jenkins in your browser:
   ```
   http://<your-eip>:8080
   ```
---

##  Project Diagram

To visualize the infrastructure layout:

1. Open the file `plan.dot` in this repository.
2. Copy all its content.
3. Go to [webgraphviz.com](https://www.webgraphviz.com).
4. Paste the content and click **"Generate Graph!"**.

This will give you a visual map of how the AWS resources are structured.

---


##  Notes

- Make sure your key pair has the correct permissions (use `chmod 400`).
- Visit [https://whatismyipaddress.com](https://whatismyipaddress.com) to get your **public IP address**, then use it in the `my_ip` variable to allow SSH access to your instance.
- Always destroy the infrastructure using `terraform destroy` when you're done to avoid AWS charges.
- Jenkins requires you to unlock the admin account using the password retrieved from `/var/lib/jenkins/secrets/initialAdminPassword` after the first login.