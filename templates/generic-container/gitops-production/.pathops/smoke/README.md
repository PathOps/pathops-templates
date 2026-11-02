# .pathops/smoke

Smoke checks of production: short, safe checks run against the deployed
environment.

- `http-check.sh`: `TARGET_URL=<url> sh http-check.sh` checks that
  `<url>/healthz` answers `ok`.
