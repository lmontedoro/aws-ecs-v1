variable "region" { 
    description = "AWS Region" 
    default = "us-east-1" 
} 

variable "profile" { 
    description = "AWS Profile" 
    default = "myprofile" 
} 

variable "prefix" { 
    description = "Prefix for our AWS resources" 
    default = "ecs-test" 
} 

variable "tags" { 
    description = "Default tags for our resources" 
    default = { 
        "Component" = "ECS Example" 
        "Author" = "Leandro" 
    } 
} 

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