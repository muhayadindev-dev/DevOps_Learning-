# THREADX — AWS Infrastructure Assignments

Three hands-on AWS assignments completed 6–8 November 2026 using the AWS Console. The work moves from VPC networking to load-balanced EC2 applications and then to a static website delivered through CloudFront.

| Assignment | What I configured | Evidence of the result |
|---|---|---|
| [1 — VPC & Networking](assignment-1/README.md) | Custom VPC, public/private subnets, IGW, NAT, route tables, EC2 and security groups | Routing and subnet configuration, NAT in Available state, private EC2 without a public IPv4 |
| [2 — Application Load Balancer](assignment-2/README.md) | Two NGINX web servers across two AZs, ALB, target group and security groups; Route 53, ACM and ASG bonuses | Requests reached both apps; three healthy targets; the ASG launched an additional EC2 instance to meet desired capacity; HTTPS worked |
| [3 — S3, CloudFront & Route 53](assignment-3/README.md) | S3 website, CloudFront, Route 53 Alias, ACM certificate and caching | HTTPS 200/cache hit, completed invalidation and updated storefront at the custom hostname |

**Region:** London (eu-west-2) for VPC/EC2/S3. CloudFront's ACM viewer certificate was created in us-east-1.

**Scope:** These were three lab stages, not one continuously running production system. The hostname `threadx.muhyadinelmi.com` pointed to the ALB during Assignment 2 and then to CloudFront during Assignment 3. The storefront is a demo site; these assignments focus on my AWS infrastructure configuration and testing.

Each assignment README follows the same structure: objective, implementation, evidence, one troubleshooting example and lessons learned. The screenshots are a selected set from 257 workshop captures rather than a step-by-step photo diary.

For a visual comparison, see the [architecture reference](zz-architecture.md).

**Evidence boundaries:** Configured routing is not proof of a successful private-instance connection. ALB responses show working request distribution; ASG and instance captures show automatic capacity provisioning to meet desired capacity. A separate load-triggered scaling-policy event was not tested. A successful CloudFront response and invalidation do not make the public S3 website origin private or end-to-end HTTPS.

**Cleanup:** Lab notes record removal of the NAT Gateway and ALB, release of the NAT Elastic IP, and scaling the ASG down to zero. These are historical actions, not a current billing audit. Stopped EC2 instances may still incur EBS storage costs.
