# base-images

Hardened, customized base container images for the platform.

Iron Bank source → in-repo hardening layer → ECR.

## Images

| Image | Source | ECR repo |
|---|---|---|
| `java/25` | `registry1.dod.mil/ironbank/redhat/openjdk/openjdk25` | `${ECR_REPO_PREFIX}/java` |
| `python/3.13` | `registry1.dod.mil/ironbank/opensource/python/python3.13` | `${ECR_REPO_PREFIX}/python` |

Confirm the exact Iron Bank paths against your org's IB catalog — names occasionally differ between programs.

## Layout

```
.gitlab-ci.yml             # pipeline entrypoint
.gitlab/ci/                # split CI includes (build, scan, sign, promote)
images/<family>/<version>/ # one Dockerfile per image, owns its own context
shared/hardening/          # scripts copied into every image
shared/trivy/              # scanner config + ignore policy
scripts/                   # local build/scan/push helpers (also used by CI)
```

## Tags published

For every successful build of `images/<family>/<version>/`:

- `<family>:<version>-<YYYYMMDD>-<short-sha>` — immutable, always pushed
- `<family>:<version>-candidate` — overwritten each pipeline, pre-scan
- `<family>:<version>` — promoted manually from `-candidate` after scan + sign

## Local use

```bash
make build IMAGE=java/25
make scan  IMAGE=java/25
make push  IMAGE=java/25            # requires AWS creds in env
```

## Required CI/CD variables

| Name | Scope | Purpose |
|---|---|---|
| `AWS_ACCOUNT_ID` | project | ECR account |
| `AWS_ROLE_ARN` | project | role assumed via OIDC |
| `IRONBANK_USER` | project, masked | registry1.dod.mil pull user |
| `IRONBANK_TOKEN` | project, masked, protected | registry1.dod.mil CLI token |

OIDC trust policy on `AWS_ROLE_ARN` must permit `aud=sts.amazonaws.com` and `sub=project_path:<group>/<project>:ref_type:branch:ref:main` (tighten per branch as needed).
