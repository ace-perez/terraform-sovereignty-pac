# Test scenarios

Two layers of testing: real Terraform plans evaluated by Sentinel in HCP Terraform, and offline `sentinel test` cases using mock data. Run the offline cases with `bash scripts/run-sentinel-tests.sh`; CI runs them on every push.

## 1. HCP Terraform runs (real plans)

Each scenario is a variable file in `terraform/scenarios/`. Copy it to `terraform/active.auto.tfvars` and run `terraform apply` (it is blocked or you answer `no`; nothing can be created because the workspace only holds dummy AWS credentials).

| Scenario | File | Expected result | Rules it should trip |
| --- | --- | --- | --- |
| Compliant | `compliant.tfvars` | PASS | none |
| Everything wrong | `noncompliant-all.tfvars` | FAIL | sovereignty (regions, residency, backups), encryption, metadata, network (SSH, all traffic, public IP), instance_type |
| Wrong region | `noncompliant-region.tfvars` | FAIL | sovereignty (regions, residency) |
| SSH open to the internet | `noncompliant-ssh.tfvars` | FAIL | network (SSH not from the admin network) |

Supply chain violations cannot be produced with variables, because `required_providers` and module `source`/`version` must be literal values. They are covered by the mock cases below.

## 2. Offline Sentinel tests (mock data)

Mocks live in `tests/testdata/`. Each policy folder holds a pass and a fail case.

| Policy | `pass.hcl` | `fail.hcl` | Extra |
| --- | --- | --- | --- |
| sovereignty | compliant plan, `main = true` | sensitive replica in us-east-1, sensitive key in eu-central-1, untagged bucket (fail closed), backup copy to us-east-1, region unknown at plan time | |
| supply_chain | approved provider, `~> 6.0`, local + exact-version registry modules | Terraform 1.14, look-alike provider, `>= 5.0` constraint, ranged/git/untrusted modules | `fail-config-only.hcl`: clean plan, bad configuration |
| encryption | all volumes encrypted | unencrypted root, extra device and data volume | |
| metadata | `http_tokens = "required"` | `optional` on the instance | |
| network | SSH only from admin CIDR | inline ingress block, legacy `aws_security_group_rule`, SSH and all traffic from 0.0.0.0/0, public IP | |
| instance_type | `t3.micro` | `m5.4xlarge` | |
| atul_guardrails (HCP bundle) | passes | fails | proves the merged bundle behaves like the six policies |

The fail mock deliberately covers bypass attempts: ingress written in the two banned forms, a per-resource region override, and a missing classification tag.
