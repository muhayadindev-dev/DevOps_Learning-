# Networking — AWS EC2, NGINX and DNS Deployment

## Project overview

This project brought together the networking concepts I had been covering and applied them in a practical AWS deployment. The goal was to understand the full path from a public domain name to a web server running on an Ubuntu EC2 instance, and how DNS, IP addressing, security groups, SSH, HTTP and NGINX fit together end to end.

For the CoderCo Networking project, I deployed NGINX on an Ubuntu EC2 instance, controlled inbound access with an AWS security group, and configured Cloudflare DNS so `muhyadinelmi.com` resolved to the instance's public IPv4 address.

**Domain:** `muhyadinelmi.com`  
**AWS region:** London (`eu-west-2`)  
**Server:** Ubuntu on Amazon EC2 (`t3.micro`)  
**Web server:** NGINX  
**DNS provider:** Cloudflare  
**Protocol:** HTTP (TCP port 80)

> **Project status:** The deployment was tested successfully and the evidence is captured below. I later terminated the EC2 instance to avoid unnecessary ongoing infrastructure costs, so the live URL is no longer expected to serve this project.

## How the components fit together

The deployment had two separate stages: DNS resolution first, then the HTTP request to the server.

```text
1. DNS lookup

muhyadinelmi.com
        |
        v
Cloudflare authoritative DNS (A record, DNS only)
        |
        v
18.133.183.107  <- IP returned to the browser

2. Web request (after DNS resolution)

Browser -> 18.133.183.107:80
                |
                v
         AWS VPC routing
                |
                v
        AWS security group
        (HTTP TCP 80 allowed)
                |
                v
         Ubuntu EC2 instance
         Private IP: 172.31.7.56
                |
                v
              NGINX
                |
                v
       Welcome to nginx!
```

The key distinction is that **DNS finds the IP address; it does not carry the web page back to the browser**. After DNS resolution, the browser makes a separate HTTP request to the server.

## 1. Launching the EC2 instance

I launched an Ubuntu EC2 instance in the London region. The instance acted as a remote Linux server that I could administer from my own machine over SSH.

I used the default VPC and an AWS-selected subnet. The instance had a private IPv4 address inside the VPC and an auto-assigned public IPv4 address for internet reachability. The public address only made the instance reachable when the VPC routing, security group rules and application configuration also allowed the traffic.

| Setting | Value during deployment |
|---|---|
| Instance name | `coderco-networking-webserver` |
| Instance type | `t3.micro` |
| Region | `eu-west-2` (London) |
| Private IPv4 | `172.31.7.56` |
| Public IPv4 | `18.133.183.107` |

![EC2 instance overview](screenshots/01-ec2-instance.png)

I used my Windows computer to connect to the remote Ubuntu machine using SSH and a private key. The private key is **not** included in this repository.

```bash
ssh -i PATH_TO_PRIVATE_KEY.pem ubuntu@18.133.183.107
```

## 2. Configuring network access

The EC2 security group acted as a stateful virtual firewall for the instance and controlled permitted inbound connections:

| Purpose | Protocol | Port | Source |
|---|---|---|---|
| SSH administration | TCP | 22 | My public IP address only (`/32`) |
| Public web traffic | TCP | 80 | Anywhere IPv4 (`0.0.0.0/0`) |

The SSH rule limited remote administration to my public IP, while the HTTP rule allowed visitors to reach NGINX on port 80 from the internet.

![EC2 security group inbound rules](screenshots/02-security-group.png)

## 3. Installing and checking NGINX

After connecting to the Ubuntu server over SSH, I installed NGINX using APT and checked the service status.

```bash
sudo apt update
sudo apt install nginx
sudo systemctl status nginx
```

The service showed as `active (running)`, confirming that NGINX was running on the instance.

![NGINX service status](screenshots/03-nginx-status.png)

Before adding DNS, I opened the instance's public IPv4 address over HTTP. The default **Welcome to nginx!** page loaded, confirming that NGINX and inbound HTTP access were working independently of the domain configuration.

Testing the server by IP first also gave me a clean troubleshooting boundary: if the IP worked but the domain did not, the next place to investigate was DNS rather than the web server.

## 4. Configuring Cloudflare DNS

I registered `muhyadinelmi.com` through Cloudflare and created an **A record** for the root domain pointing to the EC2 instance's public IPv4 address.

| DNS setting | Value |
|---|---|
| Record type | `A` |
| Name | `@` (root domain) |
| IPv4 address | `18.133.183.107` |
| Proxy status | **DNS only** (grey cloud) |
| TTL | Auto |

An A record maps a hostname to an IPv4 address. I used **DNS only** so clients would resolve the domain directly to the EC2 public IP rather than connect through Cloudflare's HTTP reverse proxy.

![Cloudflare A record](screenshots/04-cloudflare-dns.png)

## 5. Verifying the result

Finally, I opened `http://muhyadinelmi.com` and saw the **Welcome to nginx!** page. That was the end-to-end check that the DNS record, public addressing, VPC routing, security group and NGINX service were working together.

I verified the result in the browser; I did not include a separate `nslookup` result in this project.

![NGINX website accessed through custom domain](screenshots/05-nginx-domain.png)

The assessment deployment used **HTTP**, not HTTPS. HTTPS would require additional TLS configuration and was outside the scope of this build.

## Troubleshooting

### SSH key permissions on Windows

My initial SSH connection failed because the `.pem` private key file had permissions that were too broad. I placed a copy in my Windows `.ssh` directory, restricted access using Windows file permissions, and then connected successfully.

This reinforced that having the correct private key is only part of SSH access; the client can also reject a key when its local file permissions are too open.

### Connecting through AWS versus connecting directly

AWS's browser-based EC2 Instance Connect could not connect while SSH was restricted to my home public IP address. I used the SSH client on my own Windows computer instead, where the connection source matched the security group rule.

That made source-based filtering much more concrete: a valid SSH service and key are not enough if the connection itself comes from an IP address the security group does not allow.

### APT package error

My initial attempt to install NGINX returned a `404 Not Found` package-download error. Updating Ubuntu's package index with `sudo apt update` and then retrying the installation resolved it.

The issue was an outdated package index, not the security group or the EC2 instance itself, so updating the package metadata was the right fix.

### Cloudflare DNS entry mistakes

During setup, I initially entered the wrong DNS name/value and briefly used Cloudflare's **Proxied** mode. I corrected the root record name to `@`, checked the full public IPv4 address (`18.133.183.107`), and switched to **DNS only**.

Because the site already worked through the EC2 public IP, I knew the instance, security group and NGINX were working. That made it much easier to isolate the remaining problem to the DNS configuration.

## Learning notes

- An **A record** maps a hostname to an IPv4 address; DNS resolution and HTTP communication are separate steps.
- An AWS **security group** is stateful and filters traffic using rules such as protocol, port and source.
- A public IPv4 address can make an EC2 instance reachable from outside its VPC when the routing, security rules and application also permit the traffic. The instance still has a private address inside the VPC.
- **NGINX** runs as a Linux service and can continue serving traffic independently of an open SSH session.
- Testing the server through its public IP **before** connecting the domain makes DNS problems easier to isolate.
- An **auto-assigned EC2 public IPv4 address** is not permanent and can change after a stop/start cycle, which would require the A record to be updated.

## After the test: infrastructure cleanup

After capturing the working deployment and screenshots, I terminated the EC2 instance because I did not need to leave the practice server running. The URL is therefore **not a live demo anymore**.

The Cloudflare domain is separate from the EC2 instance and remains registered. Any DNS record still pointing to the released public IP should be removed, and any leftover billable AWS resources, such as EBS volumes, should also be checked.

---

**Result:** The deployment successfully served NGINX through my own domain and gave me a practical end-to-end example of how Linux, DNS, IP addressing, ports, security groups and HTTP fit together.
