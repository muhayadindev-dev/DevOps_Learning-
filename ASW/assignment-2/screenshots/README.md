# Assignment 2 — Visual Evidence

Three real lab screenshots are committed here, with each embedded beside the appropriate passage in the [Assignment 2 README](../README.md).

| Evidence | What the screenshot actually proves | Limitation |
|---|---|---|
| [01 — ALB healthy targets](01-alb-three-healthy-targets.webp) | ALB resource map reported **three healthy HTTP targets** | A health check is not a complete application functional test |
| [02 — NGINX recovery](02-nginx-unhealthy-service-recovery.webp) | Terminal displayed NGINX inactive/disabled and the attempt to enable/start with `systemctl` | Health was confirmed later through ALB and responses |
| [03 — ASG configuration](03-asg-template-version-2.webp) | Auto Scaling Group settings, Default launch-template selection and scaled-down configuration | Doesn't prove five instances ran merely because "5" is in the ASG name |

Repeated `curl` responses identifying App 1 and App 2 were recorded in the test notes of the parent README. The ALB was later deleted and the ASG scaled down, so these are **historical** screenshots.
