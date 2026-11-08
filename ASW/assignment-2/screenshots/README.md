# Assignment 2 — Screenshot selection

**Curated evidence selects three actual historical captures.** The genuine cropped PNGs are packaged separately and **not yet uploaded to this GitHub folder**.

1. `01-alb-three-healthy-targets.png` — ALB resource map showing three HTTP targets marked healthy at that moment.
2. `02-nginx-unhealthy-service-recovery.png` — EC2 terminal showing `nginx.service` **inactive (dead)** and **disabled**, followed by `sudo systemctl enable --now nginx`. Evidence of a real troubleshooting decision, not a generic screenshot.
3. `03-asg-template-version-2.png` — Auto Scaling Group settings showing the `Default` launch-template version reference and scaled-down capacity, not five running instances.

The alternating App 1/App 2 `curl` results are recorded in the README from the lab, but a separate terminal screenshot of both was **not selected** for this iteration. The ALB has since been deleted. Review crops for account identifiers before publication.
