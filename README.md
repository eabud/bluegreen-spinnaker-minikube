## bluegreen-spinnaker-minikube


### About the project    

This demo exist of a terraform stack to deploy Spinnaker on kubernetes based on Minikube in an EC2 ( AWS ). 
Please note that this implementation **should not** be used in production. 

#### Prerequisites

- AWS Account (https://eu-west-1.console.aws.amazon.com)
- Terraform CLI (https://www.terraform.io/downloads.html)
- Git CLI (https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- awsume (https://awsu.me)

#### Terraform Configurations

```hcl-terraform
variables.tf

variable "aws_region" {
  default = "eu-west-1"
  description = "AWS Region"
}

variable "keypair" {
  default = "" # i.e. Spinnaker-key-pair
  description = "Keypair name"
}

variable "profile_role_arn" {
  default = "" # i.e. arn:aws:iam::12631814431:role/YOUR.ROLE
  description = "Profile role for ARN"
}

variable "private_key" {
  default = "" # i.e. ~/.ssh/spinnaker.pem"
  description = "Profile role for ARN"
}

```

#### Installation

```hcl-terraform
> git clone https://github.com/eabud/bluegreen-spinnaker-minikube.git
> cd bluegreen-spinnaker-minikube

> awsume profile

  AWSume: User profile credentials will expire at: 2020-01-15 10:00:32
  AWSume: Role profile credentials will expire at: 2020-01-14 23:00:32

> terraform init

  Initializing the backend...
  
  Initializing provider plugins...
  - Checking for available provider plugins...
  - Downloading plugin for provider "aws" (hashicorp/aws) 2.44.0...
  
  Terraform has been successfully initialized!
  
  You may now begin working with Terraform. Try running "terraform plan" to see
  any changes that are required for your infrastructure. All Terraform commands
  should now work.
  
  If you ever set or change modules or backend configuration for Terraform,
  rerun this command to reinitialize your working directory. If you forget, other
  commands will detect it and remind you to do so if necessary.


> terraform apply

    Terraform 0.11 and earlier required all non-constant expressions to be
    provided via interpolation syntax, but this pattern is now deprecated. To
    silence this warning, remove the "${ sequence from the start and the }"
    sequence from the end of this expression, leaving just the inner expression.
    
    Template interpolation syntax is still used to construct strings from
    expressions when the template includes multiple interpolation sequences or a
    mixture of literal strings and interpolations. This deprecation applies only
    to templates that consist entirely of a single interpolation sequence.
    
    (and 4 more similar warnings elsewhere)
    
    Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.
    
      Enter a value: yes
      
      l..
      o..
      n..
      g..
      
      s..
      c..
      r..
      i..
      p..
      t..
      
      Forwarding from [::1]:8084 -> 8084
      Congratulation! Spinnaker admin console! http : http://54.194.241.40:32054
      Hello World Pipeline                          : http://54.194.241.40:32054/#/applications/helloworld
      Hello World application                       : http://54.194.241.40:34154
      Creation complete after 8m59s [id=i-07c0df99c2afe4ba6]
```

#### Usage
The output in the form of http://IP:PORT of the installation step above is the access URL to your provisioned Spinnaker.

```hcl-terraform
  Congratulation! Spinnaker admin console! : http://54.194.241.40:32054
  Hello World Pipeline                     : http://54.194.241.40:32054/#/applications/helloworld
  Hello World application                  : http://54.194.241.40:34154
```

#### Script workflow

1. Install kubectl
2. Install Docker
3. Install Minikube
4. Install Helm Chart
5. Clone Spinnaker Helm Chart
6. Deploy Helm Chart
7. Port Forwarding
8. Install Spin (Spinnaker CLI)
9. Configure helloworld service in kubernetes 
10. Create and run bluegreen deployment in Spinnaker
