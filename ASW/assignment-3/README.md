# Assignment 3 — S3 Static Website, CloudFront & Route 53

[← AWS assignments](../README.md) · [← Assignment 2](../assignment-2/README.md) · [Architecture](../zz-architecture.md)

## Objective

Host a static THREADX storefront in S3, serve it through CloudFront with HTTPS, point a custom domain to the distribution and verify that an edited `index.html` appears after cache invalidation.

## Implementation

| Task | My AWS configuration |
|---|---|
| S3 website | `threadx-bucket-web` in `eu-west-2`, static website hosting enabled, `index.html` and `error.html` at bucket root |
| Public read | Bucket policy allowed `s3:GetObject` on `arn:aws:s3:::threadx-bucket-web/*` for the public demo website |
| CloudFront origin | S3 **website endpoint** (`threadx-bucket-web.s3-website.eu-west-2.amazonaws.com`), accessed over HTTP |
| CloudFront behaviour | Managed `CachingOptimized` policy, GET/HEAD methods, `index.html` default root and viewer HTTP-to-HTTPS redirect |
| TLS | DNS-validated ACM viewer certificate from `us-east-1`; CloudFront served HTTPS to visitors |
| DNS | `threadx.muhyadinelmi.com` subdomain delegated from Cloudflare to Route 53, with an Alias A record directed to CloudFront |
| Cache update | Re-uploaded `index.html`, created invalidation `/*`, then viewed the updated metallic-grey storefront |

This was a **public S3 website origin**. CloudFront protected the viewer connection with HTTPS, but fetched the S3 website over HTTP; this is not a private-Origin Access Control setup or end-to-end TLS. Object compression was not independently confirmed in the saved response headers.

## Evidence from my AWS Console, terminal and browser

<a href="screenshots/01-s3-public-read-policy.jpg"><img src="screenshots/01-s3-public-read-policy.jpg" alt="S3 bucket policy grants public object read for the static demo website." width="520"></a>

*S3 bucket policy grants public object read for the static demo website.*

<a href="screenshots/02-s3-website-documents.jpg"><img src="screenshots/02-s3-website-documents.jpg" alt="Static website hosting configured with index.html and error.html." width="520"></a>

*Static website hosting configured with index.html and error.html.*

<a href="screenshots/03-cloudfront-creation-review.jpg"><img src="screenshots/03-cloudfront-creation-review.jpg" alt="CloudFront website origin, caching policy, allowed methods and HTTPS redirect selected." width="520"></a>

*CloudFront website origin, caching policy, allowed methods and HTTPS redirect selected.*

<a href="screenshots/05-route53-cloudfront-alias.jpg"><img src="screenshots/05-route53-cloudfront-alias.jpg" alt="Route 53 Alias A being changed from the former ALB to CloudFront." width="520"></a>

*Route 53 Alias A being changed from the former ALB to CloudFront.*

<a href="screenshots/06-dns-resolver-comparison.jpg"><img src="screenshots/06-dns-resolver-comparison.jpg" alt="DNS troubleshooting: different resolvers produced different answers for the custom hostname." width="520"></a>

*DNS troubleshooting: different resolvers produced different answers for the custom hostname.*

<a href="screenshots/07-cloudfront-cache-hit.jpg"><img src="screenshots/07-cloudfront-cache-hit.jpg" alt="curl -I over HTTPS returned HTTP/2 200 and x-cache: Hit from cloudfront." width="520"></a>

*curl -I over HTTPS returned HTTP/2 200 and x-cache: Hit from cloudfront.*

<a href="screenshots/09-invalidation-completed.jpg"><img src="screenshots/09-invalidation-completed.jpg" alt="CloudFront invalidation for /* reached Completed." width="520"></a>

*CloudFront invalidation for /* reached Completed.*

<a href="screenshots/10-updated-custom-domain.jpg"><img src="screenshots/10-updated-custom-domain.jpg" alt="Updated metallic-grey storefront visible at the custom HTTPS hostname." width="520"></a>

*Updated metallic-grey storefront visible at the custom HTTPS hostname.*


## One issue I fixed

**Custom-domain resolution:** The browser initially could not find the site. My local resolver returned no A record, so I compared it with a Route 53 authoritative nameserver and Google DNS. Those queries returned CloudFront IP answers, and later browser and HTTP checks succeeded. The screenshots establish the differing DNS answers and working result, not a proven cause of the delay.

**Lesson learned:** DNS delegation, resolver caching, the CloudFront hostname and the S3 origin do different jobs. Compare authoritative and recursive answers before changing otherwise working AWS resources.

## Testing the website update

I kept the object key `index.html`, uploaded the changed storefront and invalidated `/*`. The invalidation was marked `Completed`, and the custom domain displayed the new metallic-grey page. A separate `curl -I https://threadx.muhyadinelmi.com` captured `HTTP/2 200` and `x-cache: Hit from cloudfront` (with `age: 146`), confirming a cached CloudFront response at the time of that request.

The original storefront HTML and product imagery were produced with Codex; the engineering work documented here is my S3, CloudFront, DNS, certificate and cache setup and verification. This is a static demonstration site, not a checkout application.

**Not independently tested:** Compression in the response, custom error-page behaviour, and the HTTP redirect request path. Using a public S3 website origin is a lab configuration, not a private production-origin design.

[← AWS assignments](../README.md)
