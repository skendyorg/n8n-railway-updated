# Uptime Kuma

Uptime Kuma runs in the production environment of Railway project
`tapps-internal-network`, alongside n8n.

- Image: official `louislam/uptime-kuma:2.5.11`.
- Service: `uptime-kuma`, ID `1e0e9b45-23b9-4c5d-92d0-c873e9e141ed`.
- Private upstream: `uptime-kuma.railway.internal:3001`.
- Persistent volume: `/app/data`, using SQLite.
- Railway startup health check: `/dashboard` (the root redirects with HTTP 302).
- Sleeping is disabled; one replica runs in `europe-west4-drams3a`.
- Public Railway domains and TCP proxies are not configured.
- Team dashboard: `https://uptime.internal.t-apps.nl/`, through WARP and Cloudflare Access.
- Public push endpoint: `https://uptime-hooks.t-apps.nl/api/push/<monitor-token>`.

The shared HTTPS gateway handles TLS and forwards Kuma's WebSocket connection.
The connector resolves the private dashboard hostname to the gateway through
Railway DNS. Cloudflare's private Access app uses the same four approved team
members as n8n and a one-week session. Do not add a separate Access bookmark
with the same hostname: removing that duplicate destination restored n8n login
on 17 November 2026, after which the old bookmark was hidden.

On first access, the owner creates the Kuma administrator account. Keep Kuma's
own authentication enabled. Customer monitors, notifications and public status
pages are configured separately once the account is ready.

## Incoming heartbeats

Create a Push monitor in Kuma and copy its generated URL. For external callers,
replace only `uptime.internal.t-apps.nl` with `uptime-hooks.t-apps.nl`, preserving
the token, path and query parameters. For example:

```text
https://uptime-hooks.t-apps.nl/api/push/<monitor-token>?status=up&msg=OK&ping=
```

The public hostname points to the existing Cloudflare Tunnel. Both tunnel
ingress and the gateway accept only `/api/push/` followed by one token segment
containing letters, digits, `_` or `-`. Other paths return 404, including the
dashboard, Socket.IO, metrics and setup routes. Kuma validates the monitor token;
keep complete heartbeat URLs out of source control. Responses use `no-store`.
Cloudflare skips only Browser Integrity Check on this host's push paths so
ordinary scripts can call them; other security rules remain enabled.

Kuma may continue to display the private hostname in generated URLs because the
dashboard itself is private. Do not publish its private Access hostname or change
the dashboard's access policy to make push monitors reachable.

The monitoring service shares Railway with n8n, so a Railway-wide outage can
also interrupt monitoring. Add an external heartbeat to detect loss of the
monitoring service itself. Back up `/app/data` with Railway volume backups or
another SQLite-consistent backup method before relying on stored history.

For updates, select an official release, preserve `/app/data`, and check the
private dashboard and WebSocket connection after deployment. The gateway and
connector are deployed from this repository using their existing watch paths;
Kuma is deployed directly from its pinned Docker image.
