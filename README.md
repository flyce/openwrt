# OpenWrt arm64 Container Image

This repository builds a minimal OpenWrt root filesystem container image (arm64) and publishes it to GitHub Container Registry (GHCR).

## Image
`ghcr.io/<owner>/<repo>:latest`

Tags include:
- `latest` (only for main/master)
- Branch names
- Git tags
- Image digest (sha)

## How it works
The GitHub Actions workflow downloads an official prebuilt OpenWrt rootfs tarball for the selected target/subtarget and assembles a `scratch` based image.

Change variables in `Dockerfile` if you need a different target or version:
- `OPENWRT_VERSION` (default 23.05.3)
- `TARGET` (default armsr)
- `SUBTARGET` (default armv8)
- `PROFILE` (default generic)

## Usage
Run an ephemeral container:
```sh
# Pull (replace owner/repo)
docker pull ghcr.io/OWNER/REPO:latest

# Start (detached) -- OpenWrt init will run
docker run --name openwrt -d --privileged ghcr.io/OWNER/REPO:latest

# Enter shell
docker exec -it openwrt /bin/ash
```

> Note: Some OpenWrt services expect additional kernel capabilities; using `--privileged` is simplest for experimentation. For production, grant only required capabilities/devices.

## Adjusting RootFS Source
If the `armsr/armv8` rootfs layout changes or you want a different architecture, edit `TARGET`, `SUBTARGET`, and `PROFILE` build args in the Dockerfile or override at build time:
```sh
docker build \
  --build-arg OPENWRT_VERSION=23.05.3 \
  --build-arg TARGET=rockchip \
  --build-arg SUBTARGET=armv8 \
  --build-arg PROFILE=generic \
  -t test-openwrt:local .
```

## Manual Local Multi-arch Build (optional)
```sh
docker buildx create --use --name multi || true
docker buildx build --platform linux/arm64 -t ghcr.io/OWNER/REPO:test --load .
```

## Publishing
On pushes to `main` (or `master`) or manual dispatch, the workflow builds and pushes the image.

Ensure the repository visibility is public (or, if private, consumers must authenticate to GHCR).

## License
OpenWrt is GPL-2.0. This repository's workflow/Dockerfile is MIT unless otherwise stated.
