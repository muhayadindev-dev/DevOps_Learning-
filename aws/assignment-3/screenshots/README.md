# Assignment 3 — screenshot selection (Iteration 1)

Keep this section to three strong pieces of proof, rather than every AWS Console page.

1. `01-cloudfront-cache-hit.png` — Mac terminal `curl -I https://threadx.muhyadinelmi.com` returning `HTTP/2 200`, `x-cache: Hit from cloudfront` and CloudFront `via`.
2. `02-invalidation-completed.png` — CloudFront invalidation details showing **Completed** for `/*`.
3. `03-updated-https-storefront.png` — browser address bar `threadx.muhyadinelmi.com` with the revised metallic-grey THREADX storefront.

For the screenshot of the website, confirm you're on the **custom HTTPS domain**, not the `s3-website` HTTP endpoint. Public screenshots should be cropped/redacted.
