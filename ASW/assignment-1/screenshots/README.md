# Assignment 1 — Visual Evidence

Three cropped, original lab screenshots are committed in this directory and embedded beside the corresponding explanations in the [Assignment 1 README](../README.md). They were converted to WebP to keep the GitHub project lean while preserving the visible console evidence.

| Evidence | What the screenshot actually proves | Limitation |
|---|---|---|
| [01 — Private route table](01-vpc-route-tables.webp) | Private routing configured with local and NAT default routes at that point in the lab | Not a private EC2 internet egress test |
| [02 — Private EC2](02-private-ec2-no-public-ip.webp) | Private IPv4 shown; public IPv4 not assigned | Not a successful bastion SSH connection |
| [03 — NAT configuration](03-nat-configuration.webp) | Zonal NAT creation input, public subnet and EIP selection | **This image is a configuration screen**, not an Available-status screenshot |

The NAT gateway was later deleted and its Elastic IP released. The screenshots are historical.
