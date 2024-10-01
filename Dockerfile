# syntax=docker/dockerfile:1

FROM alpine:3

RUN apk update && \
    apk add bash curl jq supervisor gettext-envsubst

RUN addgroup --system cf && \
    adduser --system --disabled-password cf --ingroup cf

COPY ./worker /home/cf/worker/
COPY --chmod=755 ./bash/* /usr/bin/
COPY supervisord.conf /etc/supervisor/supervisord.conf

ENV IPV4_OVERRIDE=
ENV IPV6_OVERRIDE=
ENV ZONE=
ENV RECORDS_IPV4_DIRECT=
ENV RECORDS_IPV4_PROXY=
ENV RECORDS_IPV6_DIRECT=
ENV RECORDS_IPV6_PROXY=
ENV MINIMUM_TLS_VERSION=1.3
ENV ALWAYS_USE_HTTPS=true
ENV SSL_MODE=auto
ENV WORKER_NAME=
ENV WORKER_SUBDOMAIN=
ENV PERIOD_IN_SECONDS=60

ENV OUTPUT_FILE=/home/cf/output
ENV WORKER_TEMPLATE=/home/cf/worker/script.js.tmpl

USER cf
WORKDIR /home/cf/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

HEALTHCHECK --interval=30s \
    --start-interval=30s \
    --start-period=30s \
    CMD pgrep supervisord \
        && [[ "$(cat $OUTPUT_FILE)" == "0" ]] \
        && exit 0 \
        || exit 1
