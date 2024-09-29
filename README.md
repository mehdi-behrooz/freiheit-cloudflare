# Freiheit Cloudflare

## Intro

Configures and monitores basic Cloudflare settings.

## Usage

### docker-compose

```yaml
services:
  cloudflare
    container_name: cloudflare
    image: ghcr.io/mehdi-behrooz/freiheit-cloudflare:latest
    environment:
      - CLOUDFLARE_EMAIL=$CLOUDFLARE_EMAIL
      - CLOUDFLARE_KEY=$CLOUDFLARE_KEY
      - ZONE=mydomain.com
      - RECORDS_IPV4_DIRECT=@, www
      - RECORDS_IPV4_PROXY=panel
      - RECORDS_IPV6_DIRECT=myip6
      - RECORDS_IPV6_PROXY=proxy6
      - ALWAYS_USE_HTTPS=true
      - MINIMUM_TLS_VERSION=1.3
      - SSL_MODE=auto
      - WORKER_NAME=myworker
      - WORKER_SUBDOMAIN=destination.com/path
      - PERIOD_IN_SECONDS=86400
      - IPV6_OVERRIDE=2602:ffb6:4:538d:1111:2222:3333:4444
```
