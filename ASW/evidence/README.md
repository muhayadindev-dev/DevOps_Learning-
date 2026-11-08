# THREADX — Evidence Index

Nine **real, cropped lab screenshots** are published in the three assignment screenshot directories. Each image is embedded **next to the specific configuration or test it supports**, with a technically limited caption. The optimised WebP files are compressed copies of the recorded screenshots, not illustrative mock-ups.

| Project | Proof 1 | Proof 2 | Proof 3 |
|---|---|---|---|
| [Assignment 1](../assignment-1/README.md) | [Private routing](../assignment-1/screenshots/01-vpc-route-tables.webp) | [Private EC2 addressing](../assignment-1/screenshots/02-private-ec2-no-public-ip.webp) | [NAT creation configuration](../assignment-1/screenshots/03-nat-configuration.webp) |
| [Assignment 2](../assignment-2/README.md) | [ALB three healthy targets](../assignment-2/screenshots/01-alb-three-healthy-targets.webp) | [NGINX inactive → enable/start](../assignment-2/screenshots/02-nginx-unhealthy-service-recovery.webp) | [ASG settings](../assignment-2/screenshots/03-asg-template-version-2.webp) |
| [Assignment 3](../assignment-3/README.md) | [CloudFront cache hit](../assignment-3/screenshots/01-cloudfront-cache-hit.webp) | [Completed invalidation](../assignment-3/screenshots/02-invalidation-completed.webp) | [Updated custom HTTPS site](../assignment-3/screenshots/03-updated-https-storefront.webp) |

**How to read the evidence:** a route shown in the AWS Console is configured routing; it is not proof of successful private outbound traffic. Healthy ALB targets demonstrate success of the target-group health check, not full application correctness. A completed invalidation proves the cache entries were invalidated; the browser screenshot separately verifies updated content appeared.

Additional **command-based evidence** is described in the relevant README: the ALB alternated between App 1/App 2 responses, and DNS testing queried both authoritative and public recursive resolvers. Those findings are documented without manufacturing extra terminal screenshots.

**Lifetime:** These screenshots are from 6–8 November 2026. NAT/EIP and ALB were later deleted and the ASG capacity reduced to zero. This is a portfolio record of a temporary learning lab, not a claim of permanently deployed infrastructure.
