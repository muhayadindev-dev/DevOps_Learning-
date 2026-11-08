# THREADX — Architecture reference

**Read the [Assignment 1](assignment-1/README.md), [Assignment 2](assignment-2/README.md) and [Assignment 3](assignment-3/README.md) READMEs first.** They contain the build decisions, troubleshooting and screenshots. This file is just a convenient way to compare the three Mermaid diagrams.

These are **three successive historical labs**, not one permanently running architecture. The ALB was deleted before the custom DNS name was repointed to CloudFront.

## 1. Public/private VPC routing

```mermaid
flowchart TB
  Internet["Internet"]
  subgraph VPC["THREADX VPC | 10.0.0.0/16 | eu-west-2"]
    IGW["Internet gateway"]
    subgraph PUB["Public subnet | 10.0.0.0/24 | 2a"]
      PublicEC2["Public EC2 + bastion"]
      NAT["Zonal NAT gateway\npublic EIP (later deleted)"]
      PUBRT["Public RT\n10.0.0.0/16 -> local\n0.0.0.0/0 -> IGW"]
    end
    subgraph PRIV["Private subnet | 10.0.1.0/24 | 2a"]
      PrivateEC2["Private EC2\nno public IPv4"]
      PRIVRT["Private RT\n10.0.0.0/16 -> local\n0.0.0.0/0 -> NAT\n(while NAT existed)"]
    end
  end
  Internet <--> IGW
  IGW --- PUBRT
  PublicEC2 --- PUBRT
  NAT --- PUBRT
  PrivateEC2 --- PRIVRT
  PRIVRT -. "outbound default route while NAT existed" .-> NAT
  PublicEC2 -. "planned SSH hop\nnot proven end to end" .-> PrivateEC2
```

The NAT was later removed. A configured private route or bastion security rule is not proof of a successful SSH or outbound connection.

## 2. ALB, EC2 targets and Auto Scaling

```mermaid
flowchart TB
  Browser["Browser / curl"]
  DNS["Route 53 Alias A\nthreadx.muhyadinelmi.com\n(historical ALB target)"]
  ACM["ACM cert in eu-west-2\nfor HTTPS listener"]
  subgraph VPC["THREADX VPC | 10.0.0.0/16"]
    ALB["Internet-facing ALB\nlistener 80 / HTTPS 443"]
    TG["ThreadX-TargetGroup\nHTTP :80 health checks"]
    subgraph AZa["eu-west-2a | public 10.0.0.0/24"]
      App1["EC2 App 1\nNGINX :80"]
      ASGNode["ASG launched EC2\none extra healthy target"]
    end
    subgraph AZb["eu-west-2b | public 10.0.2.0/24"]
      App2["EC2 App 2\nNGINX :80"]
    end
    ASG["Grow-to-5-ThreadX ASG\nlaunch template v2"]
  end
  Browser --> DNS --> ALB
  ACM -. "TLS cert attached" .-> ALB
  ALB --> TG
  TG --> App1
  TG --> App2
  TG --> ASGNode
  ASG -. "creates managed instances" .-> ASGNode
```

Healthy describes the ALB health-check status. It does not replace an actual application response test.

## 3. S3, CloudFront and DNS

```mermaid
flowchart TB
  Visitor["Browser\nhttps://threadx.muhyadinelmi.com"]
  CFProvider["Cloudflare parent DNS\nNS delegation for threadx"]
  R53["Route 53 public hosted zone\nAlias A -> CloudFront"]
  ACM["ACM in us-east-1\nDNS-validated TLS certificate"]
  subgraph CDN["CloudFront | GLOBAL"]
    Edge["Edge location\nGET / HEAD\nCachingOptimized"]
  end
  subgraph AWSLondon["S3 | eu-west-2 | outside VPC"]
    Origin["S3 static website endpoint\nHTTP only | public read"]
    Files["threadx-bucket-web\nindex.html / error.html"]
  end
  Visitor -. "DNS lookup" .-> CFProvider
  CFProvider --> R53
  R53 -. "CloudFront IPv4 addresses" .-> Visitor
  Visitor -->|"HTTPS :443"| Edge
  ACM -. "certificate" .-> Edge
  Edge -->|"HTTP :80 on cache miss"| Origin
  Origin --> Files
```

DNS provides the address to connect to; CloudFront receives the HTTPS web request, uses its cache and can fetch public S3 website content over HTTP.

[← THREADX overview](README.md)
