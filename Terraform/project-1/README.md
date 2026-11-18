# Terraform Assignment 1 — WordPress on AWS EC2

[← DevOps Learning](../../README.md) · [Assignment 2 — Apache EC2](../project-2/) · [Screenshot archive](screenshots/)

## Project overview

For my first Terraform assignment, I deployed WordPress on an Ubuntu EC2 instance using Terraform. A Bash user-data script installed Apache, MySQL, PHP and WordPress during the server's first boot, so I didn't have to set up the application manually over SSH.

I organised the configuration into an **EC2 module** and a **security-group module**, with the root module connecting them. I used the AWS London Region (`eu-west-2`) and an S3 backend to store Terraform state.

The first deployment used a `t3.micro`, but WordPress couldn't connect to its database because the instance was running out of memory. After tracing the failure through AWS system logs, I resized it to `t3.small` and got the WordPress site working. I then verified Terraform showed no further changes and destroyed the infrastructure.

## Project structure

```text
project-1/
├── main.tf
├── variable.tf
├── terraform.tfvars
├── output.tf
├── provider.tf
├── remote_backend.tf
├── modules/
│   ├── EC2/
│   │   ├── main.tf
│   │   ├── variable.tf
│   │   ├── output.tf
│   │   └── install-wordpress.sh
│   └── security_group/
│       ├── main.tf
│       ├── variable.tf
│       └── output.tf
└── screenshots/
```

The root module holds the AWS configuration, backend, variable values and module calls. The EC2 module creates the instance and runs the WordPress installation script. The security-group module defines access rules and exposes the security-group ID for the EC2 module.

## Implementation

### 1. Provider, backend and configuration

I configured the AWS provider in [`provider.tf`](provider.tf) for `eu-west-2`. The S3 backend in [`remote_backend.tf`](remote_backend.tf) uses the bucket `terra.1-bucket` and the key `projects/terra.1` to keep this assignment's state separate.

My root [`variable.tf`](variable.tf) declares the inputs, while [`terraform.tfvars`](terraform.tfvars) provides the Ubuntu AMI, EC2 size and security-group settings. I originally deployed with `t3.micro` and later changed the instance type to `t3.small` after troubleshooting the database.

Evidence: [root configuration](screenshots/source-root-main.webp) · [final variable values](screenshots/source-tfvars.webp).

### 2. Security group and module connection

In [`modules/security_group/main.tf`](modules/security_group/main.tf), I created the `wordpress-web` security group. TCP port `80` was open to `0.0.0.0/0` for public HTTP access, and outbound traffic was allowed. I later added a more restricted TCP `22` rule for EC2 Instance Connect, using `3.8.37.24/29` rather than opening SSH to everyone.

The security-group module exposes the resource ID:

```hcl
output "security_group_id" {
  value = aws_security_group.WordPress_sg.id
}
```

My root [`main.tf`](main.tf) passes that output into the EC2 module:

```hcl
module "ec2" {
  source            = "./modules/EC2"
  ami               = var.ami
  instance_type     = var.instance_type
  security_group_id = module.security_group.security_group_id
}
```

Inside the EC2 resource, `vpc_security_group_ids = [var.security_group_id]` attaches the group to the instance. The EC2 configuration also sets `associate_public_ip_address = true`, requesting an automatically assigned public IPv4 address rather than a fixed Elastic IP.

Evidence: [security-group source](screenshots/source-sg-main.webp) · [EC2 source](screenshots/source-ec2-main.webp) · [AWS security rules](screenshots/aws-final-sg-rules.webp).

### 3. EC2 and the WordPress user-data script

The EC2 resource in [`modules/EC2/main.tf`](modules/EC2/main.tf) runs my script with:

```hcl
user_data = file("${path.module}/install-wordpress.sh")
```

My [`install-wordpress.sh`](modules/EC2/install-wordpress.sh) updates Ubuntu, installs Apache/MySQL/PHP, creates a `wordpress` database and user, downloads WordPress, and places the files in `/var/www/html`. It generates a database password using `openssl rand -hex 16`, writes the connection settings into `wp-config.php`, sets the web-directory ownership and restarts Apache.

This is a first-boot setup: Terraform supplies the script through `user_data`, while Ubuntu executes it on the EC2 instance.

Evidence: [EC2 user-data configuration](screenshots/source-ec2-main.webp) · [WordPress installation script](screenshots/source-install-wordpress.webp).

## Deployment and verification

I followed the Terraform workflow from the project root:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

The initial plan showed **4 to add, 0 to change, 0 to destroy**: the EC2 instance, security group, inbound HTTP rule and outbound rule. The apply completed with **4 added**.

Evidence: [initial plan](screenshots/plan-four-create.webp) · [completed apply](screenshots/apply-four-created.webp).

After fixing the database problem, I checked the deployment in AWS and in the browser:

| Check | Result | Evidence |
|---|---|---|
| EC2 | Ubuntu instance running with a public IPv4 address | [EC2 console](screenshots/aws-final-ec2.webp) |
| Security group | TCP `80` allowed; outbound access present; restricted SSH rule added later | [Security rules](screenshots/aws-final-sg-rules.webp) |
| WordPress setup | WordPress installer loaded after the resize | [Installation screen](screenshots/wordpress-installer.webp) |
| Website | The WordPress site titled **Elmi Terraform Lab** loaded | [Working site](screenshots/wordpress-live-site.webp) |
| Idempotency | A fresh `terraform plan` returned **No changes** | [No-change plan](screenshots/terraform-no-changes.webp) |

This was a public HTTP learning project using the default VPC setup. I did not configure HTTPS, a load balancer or a custom VPC.

## Problems I ran into

### WordPress database connection error

The instance initially responded, but WordPress displayed **Error establishing a database connection**. A `curl -I` request returned `HTTP/1.1 500 Internal Server Error`, so the issue was on the server, not a browser-cache problem.

I checked **EC2 → Instance diagnostics → System log** and found repeated messages showing Linux killing `mysqld` because the machine was **out of memory**. This explained why Apache could respond but WordPress could not reach MySQL.

I changed `instance_type` from `t3.micro` to `t3.small` in `terraform.tfvars` and ran `terraform apply`. Terraform updated the EC2 instance in place (**0 added, 1 changed, 0 destroyed**). The next system log showed MySQL starting, and the WordPress setup and website loaded.

Evidence: [database error](screenshots/wordpress-database-error.webp) · [HTTP 500](screenshots/http-500.webp) · [MySQL out-of-memory logs](screenshots/mysql-oom-system-log.webp) · [instance resize](screenshots/resize-apply.webp) · [MySQL started](screenshots/mysql-started-after-resize.webp) · [working WordPress](screenshots/wordpress-live-site.webp).

### EC2 Instance Connect troubleshooting

I also tried connecting through the AWS browser terminal. Initially, port `22` was not permitted by the security group. I added the region-specific EC2 Instance Connect CIDR and applied the extra rule successfully, but the browser SSH session still failed even though AWS's connection checks passed. I kept the connection issue separate from the confirmed MySQL memory problem.

Evidence: [port 22 warning](screenshots/ec2-connect-port22-warning.webp) · [SSH rule applied](screenshots/ssh-rule-apply.webp) · [AWS connection checks](screenshots/ec2-connect-checks.webp) · [failed SSH session](screenshots/ssh-connect-failed.webp).

## Cleanup and result

Before cleanup, `terraform plan` showed **No changes**, confirming the managed resources matched the configuration. Then I ran `terraform destroy`, which removed the instance, security group and three security-group rules:

```text
Destroy complete! Resources: 5 destroyed.
```

Evidence: [destroy plan](screenshots/destroy-plan.webp) · [destroy complete](screenshots/destroy-five-complete.webp).

The WordPress site and its public IPv4 address are no longer a live demo. The S3 backend bucket is separate from the five resources destroyed.

This assignment gave me practical experience with **Terraform modules, passing resource IDs between modules, bootstrapping WordPress through EC2 user data, and using real system logs to diagnose an application failure**. The biggest lesson was that a running EC2 instance and a responding Apache server don't guarantee the database has enough memory to stay online.

The [screenshots folder](screenshots/) holds **25 evidence captures**, covering the Terraform code, original failure, troubleshooting, recovery, working WordPress site, idempotency check and cleanup.
