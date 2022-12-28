# Container Image: RaBe Keycloak

Our [Keycloak](https://keycloak.org) container image include the [rabe-keycloak-theme](https://github.com/radiorabe/keycloak-theme-rabet ) and the included keycloak is augmented for our use-case.

The final image is based on the [RaBe Universal Base Image 8 Minimal](https://github.com/radiorabe/container-image-ubi8-minimal).

## Usage

Use any standard Keycloak container deployment strategy to deploy `ghcr.io/radiorabe/keycloak:lateset` (but replace `latest` with a specific version).

## Development

The development setup provides a `docker-compose.yaml` file to spin up a local instance
for testing purposes.

The `docker-compose.example.yaml` contains some minimal settings for running locally
can be used as an override as follows.

```bash
cp docker-compose.example.yaml docker-compose.override.yaml

# start database
podman-compose up -d db

# generate a keystore with a self-signed cert for local dev
keytool -genkeypair \
  -storepass password \
  -storetype PKCS12 \
  -keystore conf/server.keystore
  -alias server \
  -keyalg RSA \
  -keysize 2048 \
  -dname "CN=server" \
  -ext "SAN:c=DNS:localhost,IP:127.0.0.1" \

# build the container locally if you have changes you want to test
podman-compose build keycloak

# run keycloak in local terminal (and recreate it with each start to enasure the latest image is used)
podman-compose up keycloak --force-recreate
```

At this point you should be able to access keycloak via https://localhost:8443.

## Release Management

The CI/CD setup uses semantic commit messages following the [conventional commits standard](https://www.conventionalcommits.org/en/v1.0.0/).
There is a GitHub Action in [.github/workflows/semantic-release.yaml](./.github/workflows/semantic-release.yaml)
that uses [go-semantic-commit](https://go-semantic-release.xyz/) to create new
releases.

The commit message should be structured as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The commit contains the following structural elements, to communicate intent to the consumers of your library:

1. **fix:** a commit of the type `fix` patches gets released with a PATCH version bump
1. **feat:** a commit of the type `feat` gets released as a MINOR version bump
1. **BREAKING CHANGE:** a commit that has a footer `BREAKING CHANGE:` gets released as a MAJOR version bump
1. types other than `fix:` and `feat:` are allowed and don't trigger a release

If a commit does not contain a conventional commit style message you can fix
it during the squash and merge operation on the PR.

## Build Process

The CI/CD setup uses the [Docker build-push Action](https://github.com/docker/build-push-action) to publish container images. This is managed in [.github/workflows/release.yaml](./.github/workflows/release.yaml).

## License

This application is free software: you can redistribute it and/or modify it under
the terms of the GNU Affero General Public License as published by the Free
Software Foundation, version 3 of the License.

## Copyright

Copyright (c) 2022 [Radio Bern RaBe](http://www.rabe.ch)
