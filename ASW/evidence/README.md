# Evidence map — THREADX AWS Assignments 1–3

## What is actually published in Iteration 1?

The **README files, diagrams, captured App 2 user-data and this evidence manifest** are committed. Nine cropped screenshots have been prepared in a separate, downloadable screenshot package, but the current GitHub connection could not directly upload their binary PNGs. **Do not claim images are published in GitHub until those PNGs are added.**

Use a few screenshots for defensible facts, not every AWS Console page visited. These are historical lab captures; some infrastructure no longer exists.

| Assignment | Selected screenshot | What it proves | Limit |
|---|---|---|---|
| 1 | VPC private route-table view | Route table entries were configured | Not a private outbound `curl` test |
| 1 | Private EC2 details | Instance had no public IPv4 | Not a successful bastion SSH test |
| 1 | NAT setup configuration | Zonal NAT/public subnet/EIP choices | Screenshot shows configuration, not an Available-state proof |
| 2 | ALB resource map | Three registered HTTP targets marked healthy | Health checking, not entire app test |
| 2 | EC2 `systemctl` terminal | NGINX was inactive/disabled; `enable --now` was run | Follow-up ALB health was checked separately |
| 2 | ASG configuration | Launch template referenced through Default, capacity settings | Does not prove five instances ran |
| 3 | Terminal `curl -I` | HTTPS request `200`, `x-cache: Hit from cloudfront` | Cached response observed at that time |
| 3 | Completed invalidation | `/*` reached **Completed** | Must additionally check website content changed |
| 3 | Final custom-domain storefront | Updated metallic-grey website at THREADX address | The image is a browser result, not automatic CI/CD proof |

**Further evidence in text:** repeated ALB `curl` returned App 1 and App 2, and Route 53 authoritative `dig` distinguished DNS caching from missing records. These are documented in the relevant assignment README; not every text-only observation has an accompanying PNG.

Screenshot paths and filenames are documented in the individual `assignment-X/screenshots/README.md` files. Before uploading to this public repository, manually check every crop for account identifiers, personal names, unrelated tabs and secrets.
