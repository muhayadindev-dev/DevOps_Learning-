# THREADX — Three AWS Infrastructure Assignments

I built three AWS labs as part of the CoderCo DevOps course. I wanted to understand **why** I was creating each resource, rather than just following the Console until everything turned green. I spent much longer on the networking and DNS parts than I expected. Some things clicked quickly; others took screenshots, failed checks and going back over the same idea before it made sense.

The labs follow one THREADX clothing-store theme, but **they are three separate exercises**, not one always-running production system.

## Start here — the three assignments

| Assignment | What I built | What I actually tested |
|---|---|---|
| **[01 — VPC & Networking](assignment-1/README.md)** | A custom VPC, public/private subnet routing, IGW, NAT Gateway, EC2 and a bastion design | AWS network configuration, private EC2 address placement and NAT availability; full private SSH/egress still need a retest |
| **[02 — ALB & Auto Scaling](assignment-2/README.md)** | Two-zone NGINX EC2 application, ALB, target group, security groups, launch template, ASG and HTTPS | Healthy targets, alternating EC2 responses using `curl`, the NGINX failure/recovery sequence |
| **[03 — S3, CloudFront & Route 53](assignment-3/README.md)** | Static HTML website in S3, CloudFront CDN, ACM certificate, custom DNS and cache invalidation | HTTPS site, CloudFront cache hit and the updated site after a completed invalidation |

Every assignment folder contains **one README**, its own `screenshots/` folder and, where relevant, the user-data script. I put screenshot links immediately beside the part of the walkthrough they prove. I have kept the diagrams in GitHub Mermaid so they are readable without another image.

## Project approach

- **Region:** London (`eu-west-2`) for the VPC/EC2/S3 components. The CloudFront viewer certificate was issued in `us-east-1`, as CloudFront requires.
- **Provisioning:** AWS Management Console. There is no Terraform or CI/CD deployment in these three exercises.
- **Domain:** `threadx.muhyadinelmi.com`. I own the parent domain through Cloudflare; the THREADX subdomain was delegated to Route 53.
- **Application:** A small NGINX test page for the ALB assignment and a separate static THREADX storefront in S3 for the CDN assignment.

## The biggest lessons

**Networking:** The VPC, subnet, route table and security group have different responsibilities. A subnet does not become public because I called it “public”, and having an IGW doesn't automatically give an instance a public IP. I needed to separate routing from permissions and from the application that listens on a port.

**Load balancing:** I originally treated an EC2 **running** state as if it should mean the website worked. It doesn't. The instance can be running while NGINX is stopped. The ALB target health check and an actual HTTP response are separate pieces of evidence.

**DNS and CloudFront:** I got tangled up in S3 website endpoints, Alias A records and CloudFront domain names. The part that eventually clicked was that DNS locates CloudFront, while CloudFront retrieves or caches content from S3. I also learned not to rebuild a working service because one recursive DNS lookup returns nothing.

## Where the evidence lives

I kept it intentionally light: **three screenshots per assignment**, stored in the assignment's `screenshots/` folder. The README links open the originals when you want to zoom in. This is easier to read on GitHub than nine enormous full-width console images.

My terminal commands and results are written next to the explanation, especially where a screenshot would only repeat the same information. **Configured**, **observed** and **end-to-end tested** are not interchangeable.

## Lab lifecycle and costs

These are snapshots from **6–8 November 2026**. After the tests, I removed the NAT Gateway/EIP and the ALB, brought the ASG down to zero and stopped practice EC2 instances to control spending. The custom DNS name was changed from the historical ALB target to CloudFront during Assignment 3. I am not claiming all three stages remain live today. Stopped instances can still leave chargeable EBS storage.

## Architecture reference (optional)

The three READMEs already contain their own diagrams. For a side-by-side architecture-only view, see **[the Mermaid architecture reference](zz-architecture.md)**.
