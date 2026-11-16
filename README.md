# Internal n8n

This independent repository belongs to skendyorg. Railway deploys n8n and its private-access infrastructure from it.

## Addresses

- Editor: `https://n8n.internal.t-apps.nl/` — accessible through the company Cloudflare One Client (WARP).
- Webhooks: `https://hooks.t-apps.nl/` — public webhook endpoints only. The root URL intentionally returns 404.

## Team access

1. Install the [Cloudflare One Client](https://developers.cloudflare.com/cloudflare-one/team-and-resources/devices/cloudflare-one-client/download/).
2. Log in to Cloudflare Zero Trust with organization **tappshq**.
3. Use an approved email address and complete the email-code login.
4. Connect WARP and open the editor address. Complete a separate n8n sign-in or accept your n8n invitation.

The initial allowlist is `mozes@t-apps.nl`, `tygo@t-apps.nl`, `orbay@t-apps.nl`, and `otto@t-apps.nl`. Cloudflare Access and WARP enrollment both use this explicit list. To add someone later, update both allowlists and the matching WARP device profile, then invite them inside n8n. Do not add users to unrelated existing Access policies.

The dedicated WARP profile routes the Cloudflare private-hostname ranges; it does not route all ordinary web browsing through the company network. Gateway TLS decryption is disabled. Email-code sign-in is not an MFA policy; n8n users should enable n8n's own MFA where available.

## Railway services

- **n8n** uses the root Dockerfile and PostgreSQL. Preserve its encryption key and persistent volume.
- **Postgres** and **n8n-runners** stay on Railway's private network.
- **Cloudflared** uses `infra/connector/Dockerfile`. CoreDNS on loopback rewrites the private editor hostname to `n8n-gateway.railway.internal`, using Railway DNS for the current private address. The existing `railway-n8n-internal` tunnel token remains a Railway secret.
- **n8n-gateway** uses `infra/gateway/Dockerfile`. Caddy serves private HTTPS on 443 and a webhook-only HTTP listener on 8080. Its `/data` volume stores certificates. `CF_DNS_API_TOKEN` is restricted to DNS edit and zone read for `t-apps.nl` and supports automatic certificate renewal.

No secrets belong in this repository. Do not create public Railway service domains or TCP proxies for the editor, gateway, database, or runners.

## Webhook authentication

The tunnel and gateway allow only `/webhook/*`, `/webhook-test/*`, and `/webhook-waiting/*` on the public hostname. The editor, `/rest`, `/api`, forms, and other paths are not published. The gateway's `/healthz` is an internal readiness endpoint only.

Path filtering is not webhook authentication. Configure authentication for every workflow before activating it:

- For GitHub, configure and verify the webhook secret / `X-Hub-Signature-256` signature using the supported trigger or a signature-verification step before side effects. Do not assume every generic Webhook node verifies signatures.
- For scripts, use the Webhook node's Header Auth or another supported authentication method with a strong, unique secret.
- For other services, use their native signature verification or supported authentication. Keep signature verification compatible with the unmodified request body.

Do not put an interactive Cloudflare login in front of the public webhook address; webhook providers cannot complete it. Test-mode endpoints work only while n8n is listening for that test webhook. Wait/resume URLs contain sensitive tokens and should not be shared publicly.

## URL configuration and operations

Use `N8N_EDITOR_BASE_URL=https://n8n.internal.t-apps.nl/` and `N8N_WEBHOOK_URL=https://hooks.t-apps.nl/`. Caddy sends one authoritative forwarded-address header to n8n, with `N8N_PROXY_HOPS=1`.

Check the gateway's Railway readiness check, certificate renewal logs, tunnel health, and a real signed webhook after changes. Confirm that the public hostname's `/` and `/rest/settings` return 404 and that the editor is inaccessible without WARP. Back up PostgreSQL, the n8n volume, and the encryption key independently; verify the backup schedule in Railway before relying on it.
