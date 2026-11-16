FROM caddy:2.11.9-builder-alpine AS builder
RUN xcaddy build v2.11.9 --with github.com/caddy-dns/cloudflare@a8737d095ad5a48ca031cea6ab704057dbc2d250

FROM caddy:2.11.9-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY infra/gateway/Caddyfile /etc/caddy/Caddyfile
RUN caddy adapt --config /etc/caddy/Caddyfile --adapter caddyfile > /dev/null
EXPOSE 443 8080
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
