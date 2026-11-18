# Terraform Assignment 2 — Apache EC2 Deployment with Cloud-init

[← DevOps Learning](../../README.md) · [Assignment 1 — WordPress](../project-1/) · [Screenshot archive](screenshots/)

## Project overview

For my second Terraform assignment, I deployed an Ubuntu EC2 instance on AWS and used cloud-init to install Apache2 and serve a custom HTML page during the instance's first boot.

I separated the configuration into an **EC2 module** and a **security-group module**, with the root module connecting them. The deployment used the AWS London Region (`eu-west-2`), a `t3.micro` instance and an S3 backend for Terraform state.

The website loaded through the instance's public IPv4 address, and a terminal request returned `HTTP/1.1 200 OK`. After capturing the results, I destroyed the four Terraform-managed resources.

## Project structure

```text
project-2/
├── main.tf
├── variable.tf
├── terraform.tfvars
├── output.tf
├── provider.tf
├── apache.remote_storage.tf
├── modules/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variable.tf
│   │   ├── output.tf
│   │   ├── cloud_init.yml
│   │   └── index.html
│   └── security_groups/
│       ├── main.tf
│       ├── variable.tf
│       └── output.tf
└── screenshots/
```

The root files hold the provider, backend, configuration values, module calls and public-IP output. The EC2 module contains the instance and the files needed to configure Apache. The security-group module contains the group and its ingress/egress rules.

## Implementation

### 1. Provider, backend and configuration

I configured the AWS provider for `eu-west-2` in [`provider.tf`](provider.tf). The S3 backend in [`apache.remote_storage.tf`](apache.remote_storage.tf) uses the bucket `terra.1-bucket` and the key `project.2/apache`, keeping this assignment's state separate from my other Terraform project.

The root [`variable.tf`](variable.tf) and [`terraform.tfvars`](terraform.tfvars) hold the values used for the instance type, AMI, security-group name, CIDR range and public IPv4 setting. I kept those values in the root and passed the ones each child module needed through [`main.tf`](main.tf).

Evidence: [provider](screenshots/source-provider.webp) · [S3 backend](screenshots/source-remote-backend.webp) · [assignment values](screenshots/source-tfvars.webp).

### 2. Security group and module connection

In [`modules/security_groups/main.tf`](modules/security_groups/main.tf), I created the security group, an inbound HTTP rule on TCP port `80`, and an outbound rule allowing traffic. For the lab, HTTP was open to `0.0.0.0/0` so the website could be accessed publicly.

I exposed the security-group ID in the child module:

```hcl
output "security_group_id" {
  value = aws_security_group.apache_sg.id
}
```

The root [`main.tf`](main.tf) connects that output to the EC2 module using my actual module configuration:

```hcl
module "ec2" {
  source            = "./modules/ec2"
  ami               = var.ami
  instance_type     = var.instance_type
  security_group_id = module.security_group_apache.security_group_id
  public_ipv4       = var.public_ipv4
}

module "security_group_apache" {
  source    = "./modules/security_groups"
  name      = var.name
  cidr_ipv4 = var.cidr_ipv4
}
```

Inside the EC2 resource, I attached the group with `vpc_security_group_ids = [var.security_group_id]`. This connection was one of the main parts of the assignment I had to troubleshoot while refactoring into modules.

Evidence: [security-group configuration](screenshots/source-sg-main.webp) · [module output](screenshots/source-sg-output.webp) · [root module](screenshots/source-root-main.webp).

### 3. EC2 and cloud-init

The EC2 resource in [`modules/ec2/main.tf`](modules/ec2/main.tf) uses the AMI and instance type passed from the root. I connected my YAML and HTML files using:

```hcl
user_data = templatefile("${path.module}/cloud_init.yml", {
  html_content = filebase64("${path.module}/index.html")
})
```

My [`cloud_init.yml`](modules/ec2/cloud_init.yml) installs Apache2, writes the HTML content to `/var/www/html/index.html`, and starts and enables the Apache service. I created [`index.html`](modules/ec2/index.html) as a simple Terraform Project 2 page so I could confirm that my own content was deployed rather than Apache's default page.

I also exposed the instance's public IP from the EC2 module and passed it through the root [`output.tf`](output.tf), so it appeared in the terminal after deployment.

Evidence: [EC2 resource](screenshots/source-ec2-main.webp) · [cloud-init file](screenshots/source-cloud-init.webp) · [HTML file](screenshots/source-index-html.webp) · [outputs](screenshots/source-root-output.webp).

## Deployment and verification

I used the usual Terraform workflow from the project root:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

After correcting the module and variable issues below, validation succeeded. The plan showed **4 to add, 0 to change, 0 to destroy**: the EC2 instance, security group, HTTP ingress rule and outbound rule.

The apply finished with **4 added, 0 changed, 0 destroyed** and returned the instance's public IP address.

Evidence: [successful validation](screenshots/validate-and-plan.webp) · [plan](screenshots/plan-four-create.webp) · [completed apply](screenshots/apply-four-created.webp).

I then checked the result beyond the Terraform terminal:

| Check | Result | Evidence |
|---|---|---|
| AWS EC2 | Instance showed **Running** with a public IPv4 address | [EC2 console](screenshots/aws-ec2-running.webp) |
| Security group | Inbound TCP `80` and outbound traffic rules were present | [Security settings](screenshots/aws-security-group-rules.webp) |
| Browser | My custom Terraform Project 2 page loaded | [Live website](screenshots/apache-site-landing.webp) |
| HTTP test | Apache returned `HTTP/1.1 200 OK` | [Terminal response](screenshots/apache-http-200.webp) |

This was a public HTTP lab deployment using AWS's default VPC setup. I did not configure HTTPS or a separate custom VPC for this assignment.

## Problems I ran into

### Referencing a security group from another module

My first EC2 configuration tried to reference `aws_security_group.apache_sg.id` directly, even though the security group was declared in a different module. Terraform returned **Reference to undeclared resource**.

I fixed the connection by exposing `security_group_id` from the security-group module and passing `module.security_group_apache.security_group_id` into the EC2 module. Validation then passed.

[Original error](screenshots/troubleshoot-unresolved-module.webp) · [Successful validation](screenshots/validate-and-plan.webp).

### Missing `public_ipv4` input

After adding the `public_ipv4` variable to the EC2 module, I initially left it out of the root module call. Terraform reported **Missing required argument**. I supplied `public_ipv4 = var.public_ipv4` in the root `main.tf` and validated again successfully.

[Missing-argument error and fix](screenshots/troubleshoot-missing-variable.webp).

### EC2 replacement in a later plan

A later `terraform plan` showed `associate_public_ip_address` changing from `false` to `true`, which **forced EC2 replacement**. I reviewed the proposed change rather than treating it as a normal in-place update. The screenshot records the replacement **plan**, not another completed apply; the current `terraform.tfvars` contains the newer `true` value.

[EC2 replacement plan](screenshots/plan-public-ip-replacement.webp).

## Cleanup and result

Once the site, HTTP response and AWS configuration were captured, I ran `terraform destroy`. The command completed successfully:

```text
Destroy complete! Resources: 4 destroyed.
```

[Completed destroy evidence](screenshots/destroy-four-complete.webp).

The EC2 website and its recorded IP are no longer a live demo. The S3 backend bucket is separate from the four resources removed by this destroy.

This assignment gave me practical experience with **organising Terraform into modules, connecting a security-group output to an EC2 input, and using cloud-init to configure a server automatically**. The troubleshooting was just as useful as the successful deployment, especially understanding why a resource in one module cannot be referenced directly from another.

The [screenshots folder](screenshots/) retains all **29 evidence captures**, including individual screenshots of the source files, Terraform commands, AWS resources, the working website and cleanup.
