# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-08-31

First complete release of the platform: application, CI/CD, infrastructure,
and governance all working end to end.

### Added

- **Application**: a minimal FastAPI service with `/` and `/health`
  endpoints, and a `pytest` unit test suite.
- **Docker**: a multi-stage, non-root, Alpine-based `Dockerfile`.
- **Continuous Integration**: pull requests trigger reusable workflows for
  unit tests, Bandit (SAST), pip-audit (SCA), Gitleaks (secret scanning), and
  a Trivy container image scan - all failing the build on serious findings.
- **Continuous Deployment**: pushes to `main` build a Git-SHA-tagged image
  once, scan it, push it to ACR, deploy it to the `dev` namespace with Helm,
  run an automated smoke test against `/health`, wait for a manual reviewer
  approval on the `prod` GitHub Environment, then deploy the identical image
  to `prod` - Build Once, Promote Many.
- **Helm chart** (`helm/app-demo`) with shared base values and separate
  `values-dev.yaml` / `values-prod.yaml` overrides for replica count,
  resources, and environment labeling.
- **Terraform infrastructure** (`terraform-infra`): Azure Resource Group,
  Container Registry, and AKS cluster, plus the `dev` and `prod` namespaces,
  provisioned in two independently-applied stages with remote state in Azure
  Storage.
- **Terraform CI/CD**: `plan` on every pull request using a read-only PLAN
  identity, `apply` on push to `main` gated behind a manual approval job on
  the `infra-prod` GitHub Environment, using a separate, more privileged
  APPLY identity.
- **OIDC authentication everywhere**: no client secrets in any repository;
  every Azure login uses a GitHub-issued OIDC token exchanged via a Federated
  Identity Credential, with separate least-privilege identities for planning
  vs. applying infrastructure, and for deploying the application.
- **Reusable workflows** (`platform-workflows`): centralized `workflow_call`
  definitions for Python testing, security scanning, Docker image scanning,
  build-and-push, Helm deployment, and smoke testing - shared building blocks
  instead of one large per-repository pipeline.
- **Governance**: required feature-branch pull requests into `main`,
  `CODEOWNERS` assigning the `platform` team as code owner, and a repository
  Ruleset requiring reviewer approval and passing status checks while
  blocking direct and force pushes to `main`.
