# Simple upstream OpenWrt rootfs based image for arm64
# This uses the official OpenWrt downloadable rootfs tarball.
# Adjust OPENWRT_VERSION / TARGET / SUBTARGET / PROFILE as needed.

ARG OPENWRT_VERSION=23.05.3
ARG TARGET=armsr
ARG SUBTARGET=armv8
# Common profiles: generic. For other targets choose appropriate values.
ARG PROFILE=generic

FROM alpine:3.20 AS fetch
ARG OPENWRT_VERSION
ARG TARGET
ARG SUBTARGET
ARG PROFILE

# Example download URL pattern (rootfs tarball w/o kernel). For real deployments,
# you may prefer building from source; here we just fetch a prebuilt rootfs.
# We'll attempt both ext4-rootfs and rootfs variants.
RUN set -eux; \
    apk add --no-cache curl tar; \
    base="https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/${TARGET}/${SUBTARGET}"; \
    for kind in rootfs.tar.gz ext4-rootfs.tar.gz; do \
      url="$base/openwrt-${OPENWRT_VERSION}-${TARGET}-${SUBTARGET}-${PROFILE}-${kind}"; \
      echo "Trying $url"; \
      if curl -fsSLO "$url"; then tar -xf openwrt-*-$kind; break; fi; \
    done; \
    ls -al;

# Final image - scratch so it's minimal
FROM scratch
ARG OPENWRT_VERSION
# Labels (title, version, source, description, license) are injected by docker/metadata-action in the workflow.

# Copy filesystem
COPY --from=fetch / / 

# Default command: just a shell (busybox ash) if present
CMD ["/sbin/init"]
