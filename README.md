# ddev-coolify-bootstrap

A **ddev add-on** that wraps OpenTofu to provision Coolify infrastructure as code. It provides the `ddev coolify-bootstrap` command for a one-shot bootstrap of production and staging Coolify stacks.

## Installation

```bash
ddev add-on get vanWittlaer/ddev-coolify-bootstrap
ddev restart  # bake OpenTofu into the web container
```

## One-Shot Bootstrap Model

The production and staging stacks are provisioned **once** from [`infra/`](infra/) — a **one-shot bootstrap**; afterwards the **Coolify UI is the single source of truth**. One module ([`terraform-coolify-shopware-stack`](https://github.com/vanWittlaer/terraform-coolify-shopware-stack)) is instantiated once per environment and creates the **web** app, the **worker/scheduler** service, **MariaDB**, **cache + session Redis**, **RabbitMQ**, **Elasticsearch**, **Mailpit** (staging), the **S3** media wiring + CORS, and the optional **backup** stack.

All application env — `DATABASE_URL`, `REDIS_*`, `MESSENGER_*` (RabbitMQ), `APP_SECRET`, `INSTANCE_ID`, the `S3_*` keys, … — is **computed and injected by OpenTofu**, so there is no `.env.local` to copy by hand.

## Usage

### Initialize (fresh projects only)

```bash
ddev coolify-bootstrap init   # scaffold infra/ and required tfvars templates
```

### Bootstrap

```bash
cd infra
cp secrets.auto.tfvars.example secrets.auto.tfvars   # fill in the few secrets you own
cd .. && ddev coolify-bootstrap up
```

`ddev coolify-bootstrap` wraps OpenTofu (baked into the ddev web container): prereq checks → plan → **one** confirmation → apply → post-setup checklist. It refuses to bootstrap an environment that already exists in Coolify — the setup is **strictly one-time**; maintain the live environment in the Coolify UI. Teardown of a trial run: `ddev coolify-bootstrap destroy`.

### Post-Bootstrap

After bootstrap, **archive** `infra/secrets.auto.tfvars` and `infra/tofu.tfstate` off-machine (password manager / vault) — they are recovery records, not living artifacts. See [`infra/README.md`](infra/README.md) for the full runbook and the [module's FINDINGS.md](https://github.com/vanWittlaer/terraform-coolify-shopware-stack/blob/main/FINDINGS.md) for provider/Coolify quirks.

## Installed Files

This add-on installs:

| File                               | Purpose |
|:-----------------------------------|:--------|
| `.ddev/web-build/Dockerfile.opentofu` | Multi-stage build that bakes OpenTofu and dependencies into the ddev web container |
| `.ddev/commands/web/coolify-bootstrap` | Main command wrapper (init/up/destroy subcommands) |
| `.ddev/coolify-bootstrap/`         | Embedded Bootstrap scripts and templates (scaffolding, validation, wrappers) |

## Maintainer Notes: Template Sync

The embedded templates in `.ddev/coolify-bootstrap/templates/` are synchronized from the [`terraform-coolify-shopware-stack`](https://github.com/vanWittlaer/terraform-coolify-shopware-stack) module and should be re-synced whenever that module is updated. Update the version pin in `install.yaml` and re-run the sync process.
