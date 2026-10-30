# Networking — AWS EC2, NGINX and DNS

**Section:** Networking · [Repository Home](../README.md)

I used this project to put the networking concepts I'd been covering into practice by deploying a web server on AWS and connecting it to my own domain.

## 1) Project Overview

For this CoderCo networking project, I launched an Ubuntu EC2 instance, installed NGINX, configured the security group and pointed `muhyadinelmi.com` to the server using Cloudflare DNS.

The main thing I wanted to understand was how all of those pieces actually connect. Not just what DNS, ports, IP addresses and security groups do on their own, but what happens from the moment someone enters a domain name to the point NGINX sends the page back.

**Domain:** `muhyadinelmi.com`  
**AWS region:** London (`eu-west-2`)  
**Server:** Ubuntu on Amazon EC2 (`t3.micro`)  
**Web server:** NGINX  
**DNS provider:** Cloudflare  
**Protocol:** HTTP (TCP port 80)

> **Project status:** The deployment worked and the evidence is included below. I terminated the EC2 instance after testing so I wasn't leaving unnecessary infrastructure running, which means the domain is no longer serving this project.

## 2) How It Fits Together

There are really two separate parts to the flow.

First, DNS has to resolve the domain name to an IP address.

Then the browser can make the HTTP request to the server.

```text
1. DNS resolution

muhyadinelmi.com
        |
        v
Cloudflare authoritative DNS
(A record, DNS only)
        |
        v
18.133.183.107
EC2 public IPv4 returned to the client


2. HTTP request

Browser
   |
   | HTTP TCP 80
   v
18.133.183.107
EC2 public IPv4
   |
   v
AWS VPC routing
   |
   v
Security Group
HTTP TCP 80 allowed
   |
   v
Ubuntu EC2 instance
Private IPv4: 172.31.7.56
   |
   v
NGINX
   |
   v
Welcome to nginx!
```

The bit I wanted to make clear for myself was that **DNS finds the IP address; it doesn't bring the website back**.

Once the browser gets the IP address, it then makes a separate HTTP request to the server.

## 3) Project Structure

```text
networking/
├── README.md
└── screenshots/
    ├── 01-ec2-instance.png
    ├── 02-security-group.png
    ├── 03-nginx-status.png
    ├── 04-cloudflare-dns.png
    └── 05-nginx-domain.png
```

The screenshots show the EC2 instance, security group rules, NGINX service, Cloudflare DNS record and the final browser test.

## 4) Building the Project

### 4.1) Launching the EC2 Instance

I launched an Ubuntu `t3.micro` instance in the London region using the default VPC and an AWS-selected subnet.

The instance had both a private and public IPv4 address:

| Address | Purpose |
|---|---|
| Private IPv4: `172.31.7.56` | Used inside the VPC |
| Public IPv4: `18.133.183.107` | Used to reach the instance from the internet during the project |

One thing I wanted to avoid mixing up was **having a public IP** with **everything being publicly accessible**.

The public address gave the instance internet reachability, but traffic still had to be allowed by the VPC routing, security group and whatever service was actually listening on the port.

![EC2 instance overview](screenshots/01-ec2-instance.png)

I connected to the server over SSH using a private key:

```bash
ssh -i PATH_TO_PRIVATE_KEY.pem ubuntu@18.133.183.107
```

The private key is **not** stored in this repository.

### 4.2) Security Group Rules

The EC2 security group controlled what inbound traffic could reach the instance.

I used these rules:

| Purpose | Protocol | Port | Source |
|---|---|---|---|
| SSH administration | TCP | 22 | My public IP only (`/32`) |
| Public web traffic | TCP | 80 | Anywhere IPv4 (`0.0.0.0/0`) |

SSH on port 22 was restricted to my own public IP because there was no reason to leave administrative access open to everyone.

HTTP on port 80 was open because the web server needed to accept requests from the internet.

The security group is stateful, so return traffic for an allowed connection did not need a separate inbound rule.

![EC2 security group inbound rules](screenshots/02-security-group.png)

### 4.3) Installing NGINX

Once I was connected to the Ubuntu server, I installed NGINX and checked the service:

```bash
sudo apt update
sudo apt install nginx
sudo systemctl status nginx
```

The service showed as `active (running)`, so NGINX was up on the instance.

![NGINX service status](screenshots/03-nginx-status.png)

Before configuring DNS, I tested the public IPv4 address directly in the browser.

The default **Welcome to nginx!** page loaded.

Doing that first made troubleshooting much easier. If the public IP worked but the domain didn't, I already knew the EC2 instance, security group and NGINX were doing their part and I could focus on DNS.

### 4.4) Cloudflare DNS

I then created an **A record** in Cloudflare for `muhyadinelmi.com` and pointed it to the EC2 public IPv4 address.

| DNS setting | Value |
|---|---|
| Record type | `A` |
| Name | `@` |
| IPv4 address | `18.133.183.107` |
| Proxy status | **DNS only** |
| TTL | Auto |

An A record maps a hostname to an IPv4 address.

I used **DNS only** so Cloudflare returned the EC2 public IP directly instead of proxying the HTTP traffic through Cloudflare.

![Cloudflare A record](screenshots/04-cloudflare-dns.png)

## 5) Testing the Full Setup

The final test was:

```text
http://muhyadinelmi.com
```

The **Welcome to nginx!** page loaded through my domain.

At that point the full path was working:

```text
Domain
  -> DNS A record
  -> EC2 public IPv4
  -> VPC routing
  -> Security Group
  -> NGINX
  -> HTTP response
```

![NGINX website accessed through custom domain](screenshots/05-nginx-domain.png)

This project used **HTTP**, not HTTPS. TLS/HTTPS wasn't part of the assignment.

## 6) Troubleshooting

### 6.1) SSH Key Permissions

My first SSH attempt failed because the `.pem` file permissions were too open.

I moved a copy into my Windows `.ssh` directory, tightened the file permissions and connected again successfully.

The useful bit here was realising that having the correct key isn't enough. SSH can still reject it if the local file permissions are too broad.

### 6.2) EC2 Instance Connect vs Direct SSH

AWS EC2 Instance Connect couldn't connect while SSH was restricted to my home public IP.

I connected from my own machine instead, where the source IP matched the security group rule.

That made the rule much easier to understand in practice: even if port 22 is open and the key is correct, the connection can still be rejected if it comes from a source the rule doesn't allow.

### 6.3) APT Package Error

My first attempt to install NGINX returned a `404 Not Found` package error.

I updated the package index and retried:

```bash
sudo apt update
sudo apt install nginx
```

That fixed it.

The problem wasn't the EC2 instance or networking setup. Ubuntu's package information was out of date.

### 6.4) Cloudflare DNS Configuration

I also made a mistake in the Cloudflare record during setup. I had the wrong DNS name/value and briefly used **Proxied** mode.

I corrected the root record to `@`, checked the full EC2 public IPv4 address and switched the record to **DNS only**.

Because the site was already working through the public IP, I knew there was no reason to start changing NGINX or the security group again. The problem was on the DNS side.

## 7) What I Took From the Project

- **DNS and HTTP are separate.** DNS gets the IP address. HTTP is what carries the web request and response.
- **Public and private IPs aren't interchangeable.** The private IP belongs to the instance inside the VPC, while the public IP was used for internet access.
- **A public IP doesn't mean every port is open.** Routing, security rules and the application all still matter.
- **Security groups are stateful.** They track allowed connections and automatically allow the return traffic.
- **Testing one layer at a time saves a lot of guessing.** Getting NGINX working through the IP before adding DNS made the DNS issue much easier to spot.
- **NGINX isn't tied to my SSH session.** Once the service is running, closing the terminal doesn't stop the website.
- **The default EC2 public IPv4 isn't permanent.** Stopping and starting the instance can change it, which would mean updating the DNS record.

## 8) Cleanup

Once I'd finished testing and captured the screenshots, I terminated the EC2 instance because I didn't need to leave the practice server running.

The domain itself is separate from the EC2 instance and remains registered through Cloudflare. Any old DNS record pointing at the released EC2 public IP should be removed, and I also need to make sure there aren't any leftover billable AWS resources.

---

## Result

I ended up with a working NGINX server on EC2 that I could reach through my own domain.

More importantly, the project gave me a proper end-to-end example of how DNS, IP addresses, ports, security groups, Linux and HTTP actually connect instead of seeing each one as a separate topic.
