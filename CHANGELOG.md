# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

- Initial release of the Artifact Registry Terraform module.
- Support for standard, virtual, and remote repository modes.
- Support for Docker, Maven, NPM, Python, APT, YUM, Go, and Generic formats.
- Configurable cleanup policies with dry-run support.
- Docker immutable tags configuration.
- Maven version policy and snapshot overwrite configuration.
- Virtual repository upstream policies with priority.
- Remote repository configuration for Docker Hub, Maven Central, npmjs, PyPI, and custom URIs.
- IAM bindings for repository-level access control.
- Customer-managed encryption key (CMEK) support.
- Comprehensive examples: basic, advanced, and complete.

## [0.1.0] - 2024-01-01

### Added

- Initial development version with core repository functionality.
