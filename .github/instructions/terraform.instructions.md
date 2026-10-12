---
applyTo: "**/*.tf"
---

# QBS Terraform instructions

Prefer least-privilege IAM, encryption, explicit log retention, private-by-default networking/storage and reversible changes. Run `terraform fmt` and `terraform validate`; prepare a plan before proposing apply. Never autonomously apply production changes, destroy resources, broaden IAM to unblock a task, or weaken security controls. Report replacement/destruction risk and rollback considerations for infrastructure changes.
