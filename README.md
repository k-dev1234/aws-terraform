# AWS Terraform sample Project

A sample project for learning the following concepts
- Infrastructure as Code (IaC)
- Terraform

---
---
![alt text](https://github.com/k-dev1234/aws-terraform/blob/1841ac8be38553999b403bf58feee337f121d231/Terraform%20IaC.PNG?raw=true)
## Breakdown
- ##### AWS VPC
    - Create VPC
    - Create 2 subnets
        - subnet 1
        - subnet 2
    - Create Internet Gateway
    - Create Route Tables
        - Create Route Table 1 and associate to subnet1
        - Create Route Table 2 and associate to subnet2
    - Add Security Groups
        - Add Ingress(Inbound) Rule for HTTP port 80
        - Add Ingress(Inbound) Rule for SSH port 22
        - Add Engress(Outbound) Rule ALL TRAFFIC 0.0.0.0/0
- ##### AWS S3
    - Add S3 Public Access Block
- ##### AWS EC2
    - Create EC2 instance 1 
    - Create EC2 instance 2
    - Create Application Load Balancer
        - Attach Security Group
        - Attach Subnet 1 & Subnet 2
    - Create Target Group
        - Port 80 HTTP
        - Configure Health Check
        - Add EC2 instance 1 to Target Group
        - Add EC2 instance 2 to Target Group
    - Create Load Balancer Listener
        - Port 80
        - Configure **"default_action"**
            - Use Load Balancer Target Group
            - Type is **"forward"**
---
## END