# Terraform to run a Container in AWS Fargate

This repository have the code supporting this blog article:

https://lmontedoro.github.io/aws/2021/04/01/Deploying-Containers-in-AWS-Fargate-using-Terraform-Pt1.html

How to run a Docker container using the ECS with the Fargate launch type (Serverless)

In order to run the code, you first need to replace the values in "vars.tf".

```
variable "vpcid" { 
    description = "VPC ID" 
    default = "vpc-XXX" 
} 

variable "ecr_image" { 
    description = "Image URI in ECR" 
    default = "XXX.dkr.ecr.us-east-1.amazonaws.com/ecs-test-mywebsite:latest" 
} 

variable "subnet" { 
    description = "Subnet Id" 
    default = "subnet-XXX" 
} 
```

For more information please refer to the blog post.