# THREADX architecture diagrams

These are **historical snapshots of three successive assignments**, not a single deployed production topology. The individual README files explain exact settings, failures and verification.

## Assignment 1 — VPC routing

```mermaid
flowchart LR
  Cloud["Internet"] <-->|"IGW"| IGW["IGW"]
  subgraph VPC["VPC 10.0.0.0/16"]
    subgraph PUB["Public 10.0.0.0/24"]
      P["Public EC2 / bastion"]
      R1["RT: 0.0.0.0/0 → IGW"]
      NAT["NAT (deleted)"]
    end
    subgraph PRIV["Private 10.0.1.0/24"]
      Q["Private EC2\nno public IPv4"]
      R2["RT: 0.0.0.0/0 → NAT\nwhile NAT existed"]
    end
  end
  P --- R1 --> IGW
  Q --- R2 -.-> NAT --> R1
```

**Evidence boundary:** bastion and private internet egress were configured but not confirmed end to end. NAT was later removed.

## Assignment 2 — Healthy target group

```mermaid
flowchart TD
  B["Client HTTPS 443 or HTTP 80"] --> A["ALB listeners / rules"]
  A --> T["Target group HTTP 80 + health checks"]
  T --> X["EC2 App 1 / NGINX | AZ a"]
  T --> Y["EC2 App 2 / NGINX | AZ b"]
  T --> Z["ASG managed EC2 | observed extra healthy target"]
  G["ASG + launch template v2"] -. "manages capacity" .-> Z
```

**Healthy** = the target passed the configured ALB health checks; it does not mean all application functionality was tested. NGINX boot/service corrections were required during this lab.

## Assignment 3 — CloudFront edge delivery

```mermaid
flowchart TD
  U["Browser"] -. "DNS lookup" .-> D["Cloudflare delegates threadx to Route 53"]
  D --> R["Route 53 Alias A → CloudFront"]
  R -. "resolved CloudFront IPv4" .-> U
  U -->|"HTTPS"| C["CloudFront edge cache\nGET / HEAD"]
  M["ACM cert us-east-1"] -. "TLS to viewer" .-> C
  C -->|"Cache miss: HTTP only"| S["S3 website endpoint eu-west-2"]
  S --> O["index.html + error.html\npublic objects"]
  C -. "Cache hit" .-> U
```

The AWS S3 website endpoint is **outside any user-managed VPC**. The origin is public HTTP; viewer HTTPS is supplied by CloudFront. DNS is a name-resolution step, not a proxy hop carrying the site's data.

[← AWS overview](../README.md)
