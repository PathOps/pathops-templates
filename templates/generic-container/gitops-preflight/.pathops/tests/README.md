# .pathops/tests

Environment tests of preflight. They run against the deployed environment, not
the source, and may grow into integration, end-to-end or browser suites.

- `http-check.sh`: `TARGET_URL=<url> sh http-check.sh` checks that
  `<url>/healthz` answers `ok`.
