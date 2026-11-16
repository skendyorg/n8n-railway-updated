FROM cloudflare/cloudflared:2026.11.0 AS tunnel
FROM coredns/coredns:1.15.0 AS dns
FROM alpine:3.23
RUN apk add --no-cache ca-certificates
COPY --from=tunnel /usr/local/bin/cloudflared /usr/local/bin/cloudflared
COPY --from=dns /coredns /usr/local/bin/coredns
COPY infra/connector/Corefile /etc/coredns/Corefile
COPY infra/connector/start.sh /start.sh
RUN chmod 755 /start.sh
ENTRYPOINT ["/start.sh"]
