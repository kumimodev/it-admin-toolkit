# Acronis Cyber Protect Cloud samples

Helpers for talking to the Acronis Cyber Protect Cloud API from a lab or RMM style workflow.

## Safety

1. Store `ACRONIS_CLIENT_ID`, `ACRONIS_CLIENT_SECRET` and `ACRONIS_DATA_CENTER` in environment variables or a secret store.
2. Never commit a live client secret, a tenant UUID, or a data centre URL that points at a paid production account.
3. Do not publish raw policy exports that still contain real `context.items` resource identifiers.
4. Prefer a dedicated API client with the smallest role that can list agents or read policies.

## Scripts

| File | Purpose |
|------|---------|
| `Get-AcronisApiToken.ps1` | Client credentials token request |
| `Get-AcronisAgents.ps1` | List agents for a tenant id you supply |
| `policies/` | Sanitised policy shape examples for monitoring, RMM and security |

## Typical flow

```powershell
$env:ACRONIS_DATA_CENTER = 'https://YOUR-DATACENTER.acronis.com'
$env:ACRONIS_CLIENT_ID = '<YourApiClientId>'
# Prefer a secure prompt or a secret store. Do not paste a live value into a file.
$env:ACRONIS_CLIENT_SECRET = [Environment]::GetEnvironmentVariable('ACRONIS_CLIENT_SECRET')
$token = .\Get-AcronisApiToken.ps1
.\Get-AcronisAgents.ps1 -AccessToken $token -TenantId '00000000-0000-0000-0000-000000000000'
```

Replace the tenant id with a lab value. Rotate any client secret that ever appeared in a shared drive or chat.
