# Assignment 2 — Application Load Balancer

[← AWS assignments](../README.md) · [← Assignment 1](../assignment-1/README.md) · [Assignment 3 →](../assignment-3/README.md) · [Architecture](../zz-architecture.md)

## Objective

Serve two different EC2 web pages through one Application Load Balancer (ALB), with healthy targets and HTTP access to the instances restricted to the ALB security group. I also configured Route 53, ACM HTTPS and an Auto Scaling Group as bonus work.

## Implementation

| Task | My AWS configuration |
|---|---|
| Two instances | NGINX web applications in `eu-west-2a` and `eu-west-2b`, returning distinct App 1 and App 2 pages |
| Public subnets | `10.0.0.0/24` (2a) and `10.0.2.0/24` (2b) in `threadX-vpc` |
| ALB | Internet-facing `threadX-ALB` spanning both public subnets |
| Target group | `ThreadX-TargetGroup` using instance targets and HTTP port `80`; health checked at `/` |
| Security groups | ALB accepted web traffic; App 2's HTTP `80` rule accepted the ALB security group as its source, rather than open internet HTTP |
| DNS and HTTPS (bonus) | Route 53 Alias for `threadx.muhyadinelmi.com` and an ACM certificate in `eu-west-2` on the ALB HTTPS `443` listener |
| Auto Scaling (bonus) | `Grow-to-5-ThreadX` used `ThreadX-ASG-Template`. At creation, desired capacity was `1` and the group initially showed `0` instances while updating. A subsequent running EC2 instance explicitly listed `Grow-to-5-ThreadX` as its Auto Scaling Group. Later cleanup: desired `0`, min `0`, max `2` |

The named EC2 applications ran in **public subnets**. Their HTTP security-group rules were intended to restrict web requests to the ALB; separate, restricted SSH access was used during troubleshooting. This is not a claim that the backends were in private subnets or that every possible route to the instances was eliminated.

## EC2 user-data starter script

The recorded App 2 bootstrap installed NGINX and started it on Amazon Linux:

```bash
#!/bin/bash
set -e
dnf install -y nginx
systemctl enable --now nginx
echo "<h1>Welcome to THREADX Online Clothing Store - EC2 Application 2</h1>" > /usr/share/nginx/html/index.html
```

[View the script](user-data/app2-bootstrap.sh).

## Evidence from my AWS Console and terminal

<a href="screenshots/04-backend-security-rules.jpg"><img src="screenshots/04-backend-security-rules.jpg" alt="App 2 HTTP access is sourced from the ALB security group." width="520"></a>

*App 2 HTTP access is sourced from the ALB security group.*

<a href="screenshots/01-alb-three-healthy-targets.jpg"><img src="screenshots/01-alb-three-healthy-targets.jpg" alt="ALB target-group view with three healthy registered HTTP targets at the captured moment." width="520"></a>

*Three healthy registered HTTP targets were visible after the ASG launched additional EC2 capacity. This view confirms target health, not a CPU- or traffic-triggered scale-out event.*

<a href="screenshots/09-curl-backend-responses.jpg"><img src="screenshots/09-curl-backend-responses.jpg" alt="Repeated curl requests returned both App 1 and App 2 HTML responses through the ALB." width="520"></a>

*Repeated curl requests returned both App 1 and App 2 HTML responses through the ALB.*

<a href="screenshots/08-http-https-listeners.jpg"><img src="screenshots/08-http-https-listeners.jpg" alt="ALB HTTP 80 and HTTPS 443 listeners forwarding to the target group." width="520"></a>

*ALB HTTP 80 and HTTPS 443 listeners forwarding to the target group.*

<a href="screenshots/10-custom-domain-https.jpg"><img src="screenshots/10-custom-domain-https.jpg" alt="Application response served at the custom HTTPS hostname during the ALB stage." width="520"></a>

*Application response served at the custom HTTPS hostname during the ALB stage.*

<a href="screenshots/03-asg-capacity-and-template.jpg"><img src="screenshots/03-asg-capacity-and-template.jpg" alt="Auto Scaling Group linked to the launch template; captured cleanup state shows desired capacity zero." width="520"></a>

*ASG linked to the launch template. This particular screenshot shows the later cleanup state (desired capacity zero); earlier workshop captures show the group creating an EC2 instance at desired capacity one.*

<a href="screenshots/02-nginx-service-recovery.jpg"><img src="screenshots/02-nginx-service-recovery.jpg" alt="App 1 NGINX service was inactive; the terminal shows the systemctl enable --now recovery command." width="520"></a>

*App 1 NGINX service was inactive; the terminal shows the systemctl enable --now recovery command.*


## One issue I fixed

**Unhealthy backend:** One target was unhealthy even though its EC2 instance was running. Checking the instance showed that NGINX was inactive and disabled. I used `sudo systemctl enable --now nginx`; later health checks and actual requests showed the application serving traffic.

**Lesson learned:** EC2 “Running” does not mean an application is healthy. Check the service first, then port/security-group access, target health and a real HTTP response.

## What I verified

Repeated requests to the ALB returned distinct App 1/App 2 identifiers, three registered targets showed healthy, and the custom HTTPS hostname served the application. **Auto Scaling was also demonstrated beyond configuration:** the group was created at desired capacity `1`, initially showed `0` instances while updating, and a subsequent running EC2 instance identified `Grow-to-5-ThreadX` as its Auto Scaling Group. This demonstrates **automatic instance provisioning to meet desired capacity**. A later screenshot shows the group scaled down to desired `0` for cleanup.

**Scope of the bonus test:** The captures do not establish a scaling policy increasing desired capacity because CPU or traffic rose. They also do not show a deliberate AZ outage or instance replacement test. Those additional tests were not required by the assignment; the ASG provisioning result was real.

[Next: S3, CloudFront and Route 53 →](../assignment-3/README.md)
