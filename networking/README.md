# Networking — My First AWS EC2, NGINX and DNS Deployment

## Project overview

This was my first time using AWS. Until this project, I had never actually launched a cloud server. I wanted to understand how the networking I had been studying came together in practice: launching a remote Ubuntu machine, allowing traffic to reach it, running a web server, and connecting that server to my own domain.

For the CoderCo Networking project, I deployed NGINX on an AWS EC2 instance and configured Cloudflare DNS so I could open the website through `muhyadinelmi.com`.

**Domain:** `muhyadinelmi.com`  
**AWS region:** London (`eu-west-2`)  
**Server:** Ubuntu on Amazon EC2 (`t3.micro`)  
**Web server:** NGINX  
**DNS provider:** Cloudflare  
**Protocol:** HTTP (TCP port 80)

> **Project status:** The deployment was tested successfully and the evidence is captured below. I subsequently terminated the EC2 instance to avoid unnecessary ongoing infrastructure costs, so the live URL is no longer expected to serve this project.

## How the components fit together

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

The distinction I wanted to get clear was that **DNS finds the IP address; it does not carry the web page back to the browser**. After DNS resolution, the browser makes a separate HTTP request to the server.

## 1. Launching the EC2 instance

I launched an Ubuntu EC2 instance in the London region. This was the moment the cloud concept clicked for me: I was operating a remote computer from my own laptop, rather than installing NGINX on my local machine.

I used the default VPC and an AWS-selected subnet. The instance had a private IP inside the VPC and a public IP for incoming internet traffic.

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

The EC2 security group controlled permitted inbound connections:

| Purpose | Protocol | Port | Source |
|---|---|---|---|
| SSH administration | TCP | 22 | My public IP address only (`/32`) |
| Public web traffic | TCP | 80 | Anywhere IPv4 (`0.0.0.0/0`) |

The SSH rule limited remote administration to my connection, while the HTTP rule allowed visitors to reach NGINX from the internet.

![EC2 security group inbound rules](screenshots/02-security-group.png)

## 3. Installing and checking NGINX

After connecting to the Ubuntu server over SSH, I installed NGINX using APT and checked whether its service was actually running. These are the commands I used during setup and troubleshooting:

```bash
sudo apt update
sudo apt install nginx
sudo systemctl status nginx
```

The service status showed `active (running)` and `enabled`, indicating NGINX was running and configured to start at boot.

![NGINX service status](screenshots/03-nginx-status.png)

Before adding DNS, I opened the instance's public IPv4 address using HTTP. The default **Welcome to nginx!** page loaded, confirming that NGINX and inbound HTTP access worked independently of the domain configuration.

## 4. Configuring Cloudflare DNS

I registered my own domain, `muhyadinelmi.com`, through Cloudflare. Then I created an **A record** for the root domain to point at my EC2 instance. This was the part where the server stopped being just an IP address I had to remember.

| DNS setting | Value |
|---|---|
| Record type | `A` |
| Name | `@` (root domain) |
| IPv4 address | `18.133.183.107` |
| Proxy status | **DNS only** (grey cloud) |
| TTL | Auto |

An A record maps a hostname to an IPv4 address. I chose **DNS only** so that clients would resolve the domain directly to the EC2 public IP rather than connect through Cloudflare's HTTP reverse proxy.

![Cloudflare A record](screenshots/04-cloudflare-dns.png)

## 5. Verifying the result

Finally, I opened `http://muhyadinelmi.com` and saw the **Welcome to nginx!** page. Seeing that page under my own domain was the end-to-end check: the DNS configuration, public address, security group and NGINX server were working together.

I verified this in the browser; I have not included a separate `nslookup` result in this project.

![NGINX website accessed through custom domain](screenshots/05-nginx-domain.png)

The assessment deployment used **HTTP**, not HTTPS. HTTPS would require additional TLS configuration; it was not part of this build.

## Problems I ran into

### SSH key permissions on Windows

My initial SSH connection failed because the `.pem` private key file had permissions that were too broad. I placed a copy in my Windows `.ssh` directory, restricted access using Windows file permissions, and then connected successfully. I learned that having the correct private key is not enough if its file permissions allow too much access.

### Connecting through AWS versus connecting directly

AWS's browser-based EC2 Instance Connect could not connect while SSH was restricted to my home IP address. I used the SSH client on my own Windows computer instead. This made the security group rule more concrete: restricting SSH to my own public IP also means a connection coming from somewhere else can be rejected.

### APT package error

My initial attempt to install NGINX returned a `404 Not Found` package-download error. Updating Ubuntu's package index with `sudo apt update`, then retrying the install, resolved the issue. The fix was not to change the security group or reinstall Ubuntu. The package index was outdated, so updating it before retrying was the right step.

### Cloudflare DNS entry mistakes

During setup, I initially entered the wrong DNS name/value and briefly used Cloudflare's **Proxied** mode. I corrected the root record name to `@`, checked the full public IPv4 address (`18.133.183.107`), and switched to **DNS only**. Because the site already worked through the EC2 public IP, I knew NGINX was running. That made it much easier to focus on the DNS record instead of changing the server.

## Learning notes

- An **A record** maps a hostname to an IPv4 address; DNS resolution and HTTP communication are separate steps.
- An AWS **security group** filters traffic by protocol, port, and source, including SSH on port 22 and HTTP on port 80.
- A public IPv4 address makes a cloud server reachable from outside its VPC when routes, security rules, and the application permit it. The instance also has a private address inside the VPC.
- **NGINX** is a web server running as a Linux service. It can continue serving traffic independently of an open SSH session.
- Testing the server through its IP **before** connecting the domain makes DNS problems easier to isolate.
- An **auto-assigned EC2 public IPv4** is not a permanent address and can change after a stop/start cycle, requiring an A-record update.

## After the test: infrastructure cleanup

After I had captured the working deployment and screenshots, I terminated the EC2 instance because I did not need to leave this practice server running. That means the URL is **not a live demo anymore**. My Cloudflare domain is separate from the instance and remains registered. The old A record needs removing if it still points to the released IP, and I should check for any leftover billable AWS resources, including EBS volumes.

---

**Result:** My first AWS-hosted NGINX site worked through my own domain. More importantly, I now have a practical example of how Linux, ports, security groups, public/private IPs and DNS fit together.
