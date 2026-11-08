# Assignment 3 — Visual Evidence

Three original screenshots document the full S3 → CloudFront verification, embedded inline in the [Assignment 3 README](../README.md).

| Evidence | What the screenshot actually proves |
|---|---|
| [01 — CloudFront cache hit](01-cloudfront-cache-hit.webp) | `curl -I` returned `HTTP/2 200`, `x-cache: Hit from cloudfront` and CloudFront response headers |
| [02 — Completed invalidation](02-invalidation-completed.webp) | CloudFront marked the wildcard `/*` invalidation **Completed** |
| [03 — Updated HTTPS storefront](03-updated-https-storefront.webp) | Metallic-grey THREADX website loaded using the custom hostname `threadx.muhyadinelmi.com` |

The website screenshot uses the **custom domain**, not the direct S3 website endpoint. The screenshot shows the application as it appeared at test time; it does not prove that a CI/CD pipeline or continuously running production service exists.
