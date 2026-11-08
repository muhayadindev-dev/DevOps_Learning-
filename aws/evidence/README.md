# Evidence map — THREADX AWS Assignments 1–3

I selected evidence based on **what each screenshot proves**, not on the number of Console pages visited. The screenshots are historical and must not be mistaken for currently running infrastructure. Original captures contain unrelated tabs/account UI, so only **redacted/cropped copies** should be published.

| Assignment | Evidence | What it should prove | Limits |
|---|---|---|---|
| 1 | VPC route tables / subnet associations | Public IGW and private NAT routing were configured | Not a private outbound `curl` proof; NAT later deleted |
| 1 | Private EC2 details | No public IPv4 on the private machine | Not a successful bastion connection |
| 1 | IGW/NAT public subnet details | Gateway attached / NAT `Available` at test time | Historical; NAT/EIP deleted |
| 2 | ALB resource map | Three registered targets were healthy | Health-check success, not full application test |
| 2 | Terminal `curl` responses | App 1 and App 2 answered through ALB | Historical ALB was deleted |
| 2 | Launch template / ASG details | Default template version 2; capacity management configuration | Does not prove five instances ran |
| 3 | Terminal `curl -I` | HTTPS request `200`, `x-cache: Hit from cloudfront` | Demonstrates cache hit at that point in time |
| 3 | CloudFront invalidation details | `/*` reached **Completed** | Completion does not by itself prove visual change |
| 3 | Browser at custom domain | Updated metallic-grey design on THREADX HTTPS URL | Website looked correct in browser |

**Screenshot selection and exact planned filenames:** see each assignment's `screenshots/README.md`. Do not add account identities, key material or irrelevant browser tabs. Diagram source is in Markdown Mermaid, not a fake screenshot.

The README text and the terminal outputs are also **evidence**. A claim like "NAT egress was tested" or "five instances were healthy" is intentionally absent because that was not established.
