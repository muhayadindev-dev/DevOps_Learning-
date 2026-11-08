THREADX — AWS Infrastructure Labs
=================================

Three CoderCo assignments tracing a web application from VPC networking to load-balanced EC2 and then static delivery through CloudFront. I built the resources in the AWS Console and used terminal requests, service status and browser checks to understand what each layer was doing.

The work took place on 6–8 November 2026. These are separate lab stages with shared THREADX naming, not one continuously running production environment. The custom hostname moved from the Assignment 2 ALB to the Assignment 3 CloudFront distribution.

Assignments
-----------

| Project | Implementation | Evidence and limits |
|---|---|---|
| [1. VPC and networking](assignment-1/README.md) | Custom VPC, public/private subnets, IGW, NAT, EC2 and intended bastion access | Captured routes, subnet associations, addressing and NAT metrics. Later captures show corrected bastion permissions; private SSH and egress were not verified end to end. |
| [2. ALB and Auto Scaling](assignment-2/README.md) | NGINX applications across two AZs, ALB, target group, launch template, ASG and HTTPS | Captured responses from both applications, service recovery, target health and the HTTPS page. No load-triggered scaling or AZ-outage test is claimed. |
| [3. S3 and CloudFront](assignment-3/README.md) | Public S3 website origin, CloudFront, ACM, Route 53 and Cloudflare delegation | Captured cache-hit headers, completed invalidation and the updated custom-domain page. The origin remained public and HTTP-only. |

Each assignment has its own architecture, configuration decisions, walkthrough, verification and troubleshooting. I reviewed all 257 supplied screenshots and selected 30 evidence views across the three assignments. Each sits beside the step it supports, at a restrained width with a link to the full image. Browser distractions, AWS account identifiers, IAM owner fields and personal client addresses are cropped or visibly redacted; configuration values and test output are preserved.

Working context
---------------

| Area | Lab choice |
|---|---|
| Main AWS Region | London, `eu-west-2` |
| VPC | `threadX-vpc`, `10.0.0.0/16` |
| Compute | Amazon Linux EC2 instances running NGINX |
| Domain | `threadx.muhyadinelmi.com`; parent DNS at Cloudflare, subdomain delegated to Route 53 |
| TLS certificates | `eu-west-2` for the ALB; `us-east-1` for the CloudFront viewer certificate |
| Provisioning | AWS Console; no Terraform deployment or CI/CD pipeline in these labs |
| Application | EC2 identification pages for Assignment 2; a separate fictional static storefront for Assignment 3 |

The storefront HTML and product imagery were generated with Codex. My work documented here is the AWS hosting, networking, configuration, verification and troubleshooting.

How I treat the evidence
-----------------------

I separate a selected setting, a saved configuration and a working request. A creation-form screenshot records a choice; it does not establish that the resource was deployed. A healthy target proves a health check passed; a response containing an application identifier demonstrates that the backend served a request.

The verification tables distinguish captured results from observations retained only in my lab notes and tests I still need to repeat. Tests that remain unfinished are identified in each assignment.

What connected the three assignments
-----------------------------------

Networking made me separate address ranges, routing and permissions. Reviewing the bastion rules exposed an SSH source mismatch; later captures show the rule corrections.

The ALB exercise made service state concrete: an EC2 instance can be running while NGINX is inactive. Checking systemd and then issuing HTTP requests was more useful than repeatedly changing the load balancer.

The CDN exercise made me distinguish the stored object, the cached response and the DNS answer. An updated S3 object, a completed invalidation and the new page at the custom domain are different checks.

Lifecycle and costs
-------------------

My lab notes record deleting the NAT Gateway and releasing its Elastic IP, deleting the ALB, reducing the ASG to zero and stopping practice EC2 instances. The ASG screenshot confirms desired capacity `0` and limits `0–2`. These are historical cleanup records, not a current audit of the AWS account.

Stopped instances can retain billable EBS volumes. S3, CloudFront and Route 53 also need reviewing separately; deleting the old ALB did not remove the later static website or DNS resources.

Related work and references
---------------------------

These labs build on my [Linux/Bandit work](../linux/bandit/README.md), [EC2 and DNS networking project](../networking/README.md) and [Docker application](../docker/README.md).

For documentation structure I studied [mazin1hn/aws](https://github.com/mazin1hn/aws), [mohamed67471/aws](https://github.com/mohamed67471/aws) and [hasanenv/aws-alb-nginx-architecture](https://github.com/hasanenv/aws-alb-nginx-architecture). The resource settings, commands, screenshots and test boundaries in this directory describe my own labs.

Architecture reference (optional)
---------------------------------

[Compare the three architectures without the walkthroughs](zz-architecture.md). Start with the assignment READMEs for the evidence and limitations.
