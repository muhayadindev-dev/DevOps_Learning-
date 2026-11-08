# EC2 user-data record

`app2-bootstrap.sh` is the **captured corrected user data for App 2**. It was provided when the replacement App 2 EC2 launched in the second public subnet and it installs NGINX, enables the service at boot, starts it immediately and writes a uniquely identifiable test page.

**Why this file matters:** App 1 initially missed `#!/bin/bash` in user data and later suffered from NGINX not starting on reboot. The App 1 fixes were performed interactively, notably `sudo systemctl enable --now nginx`. An original complete App 1 user-data file was **not** preserved, so this directory does not invent one.

**Never paste actual key material, credentials or instance-specific secrets into user data committed to a public repository.**
