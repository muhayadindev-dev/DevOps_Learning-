THREADX — Architecture Reference
=================================

Read the [VPC](assignment-1/README.md), [ALB](assignment-2/README.md) and [S3/CloudFront](assignment-3/README.md) walkthroughs for the implementation evidence. This optional reference compares their diagrams without repeating the screenshots.

These are historical lab stages. The ALB was deleted and the custom hostname was later repointed to CloudFront. The diagrams do not claim that all resources remain deployed.

VPC routing and corrected bastion rules
---------------------------------------

```mermaid
flowchart TB
    Internet["Internet"]
    Laptop["My laptop"]
    subgraph VPC["threadX-vpc | 10.0.0.0/16 | eu-west-2"]
        IGW["ig-threadX<br/>Internet Gateway"]
        subgraph Public["pub-threadx | 10.0.0.0/24 | eu-west-2a"]
            PublicEC2["EC2Pub-threadX<br/>10.0.0.243"]
            Bastion["Bastion-1<br/>10.0.0.234"]
            NAT["ng-threadX<br/>Public NAT + Elastic IP"]
        end
        subgraph Private["piv-threadX | 10.0.1.0/24 | eu-west-2a"]
            PrivateEC2["EC2PRIV-threadX<br/>10.0.1.16 | no public IPv4"]
        end
    end
    PublicEC2 -->|"Public default route"| IGW
    PrivateEC2 -->|"Private default route: configured"| NAT
    NAT -->|"Public default route"| IGW
    IGW --> Internet
    Laptop -. "SSH :22; rule corrected, session unverified" .-> Bastion
    Bastion -. "SSH :22; source group corrected, session unverified" .-> PrivateEC2
```

Solid paths record configured routing while NAT existed; dashed SSH paths show corrected permissions, without a captured session. NAT metrics did not establish the source instance.

ALB, EC2 and managed capacity
-----------------------------

```mermaid
flowchart TB
    Client["Browser / curl"]
    DNS["Route 53 Alias A<br/>threadx.muhyadinelmi.com<br/>Historical ALB target"]
    Certificate["ACM | eu-west-2"]
    subgraph VPC["threadX-vpc | 10.0.0.0/16 | eu-west-2"]
        ALB["threadX-ALB<br/>Public-subnet mapping across two AZs<br/>HTTP :80 / HTTPS :443"]
        TG["ThreadX-TargetGroup<br/>Instance targets | HTTP :80"]
        subgraph ZoneA["eu-west-2a | public 10.0.0.0/24"]
            App1["EC2 App 1 | 10.0.0.186<br/>NGINX :80"]
        end
        subgraph ZoneB["eu-west-2b | public 10.0.2.0/24"]
            App2["EC2 App 2 | 10.0.2.36<br/>NGINX :80"]
        end
        ASG["Grow-to-5-ThreadX<br/>ThreadX-ASG-Template | Default"]
        Managed["Additional registered EC2 target<br/>Final AZ not retained in the capture"]
    end
    Client -. "DNS lookup" .-> DNS
    DNS -. "Alias target" .-> ALB
    Client -->|"HTTP :80 or HTTPS :443"| ALB
    Certificate -. "Certificate on HTTPS listener" .-> ALB
    ALB --> TG
    TG --> App1
    TG --> App2
    TG --> Managed
    ASG -. "Launches managed capacity" .-> Managed
```

The named app instances were in public subnets. Three healthy targets were captured, but the additional target's final AZ was not retained. DNS and certificate relationships are separate from web traffic.

S3 website delivery through CloudFront
--------------------------------------

```mermaid
flowchart TB
    Browser["Browser<br/>threadx.muhyadinelmi.com"]
    Resolver["Recursive DNS resolver"]
    Parent["Cloudflare authoritative DNS<br/>muhyadinelmi.com"]
    Zone["Route 53 public hosted zone<br/>threadx.muhyadinelmi.com"]
    Certificate["ACM viewer certificate<br/>us-east-1"]
    Edge["CloudFront | GLOBAL<br/>HTTPS, cache, GET / HEAD"]
    subgraph London["Amazon S3 | eu-west-2 | outside the VPC"]
        Origin["Public S3 website endpoint<br/>threadx-bucket-web"]
        Objects["index.html<br/>error.html"]
    end
    Browser -. "DNS lookup" .-> Resolver
    Resolver -. "Parent delegation lookup" .-> Parent
    Parent -. "NS delegation for THREADX subdomain" .-> Zone
    Zone -. "Alias A targets distribution" .-> Edge
    Browser -->|"HTTPS :443"| Edge
    Certificate -. "Viewer TLS" .-> Edge
    Edge -->|"HTTP :80 on cache miss"| Origin
    Origin --> Objects
```

The browser uses HTTPS to CloudFront; the public website origin uses HTTP. DNS delegation and the Alias are lookup/configuration relationships, not content proxies.

[AWS overview](README.md)
