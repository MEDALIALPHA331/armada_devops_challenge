# DevOps Challenge: Solution with Autoscaling Group

## Prerequisites

    - Node 18 or Higher
    - pnpm
    - git

## Run Locally

    - git clone https://github.com/MEDALIALPHA331/armada_devops_challenge api
    - cd api
    - pnpm install
    - pnpm start

## Run Terraform Scripts

1. first make sure you have:
   - AWS account (Free tier is enough) with a User credentials (admin)
   - you have a private key for a key pair: name of the key in script "ssh_secret_key"
   - Terraform installed
2. Other tools that would help:
   - AWS CLI
   - Github CLI
3. now you:
   - export your AWS Credentials
   - `cd terraform`
   - `terraform init` to create the backend
   - `terraform plan` to see the provisioned resources
   - `terraform apply` to apply the provisioned resources
4. to destroy the resources:
   - `terraform destroy`
