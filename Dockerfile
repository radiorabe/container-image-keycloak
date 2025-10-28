FROM quay.io/keycloak/keycloak:26.4.2-0 AS upstream
FROM ghcr.io/radiorabe/ubi9-minimal:0.10.2 AS builder

COPY --from=upstream /opt/keycloak /opt/keycloak

# Theme version, see https://github.com/radiorabe/keycloak-theme-rabe/releases
ARG THEME_VERSION=0.4.5

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak

RUN    microdnf install -y \
           java-21-openjdk-headless \
    && microdnf clean all \
    && curl -L -o providers/keycloak-theme-rabe-$THEME_VERSION.jar \
           https://github.com/radiorabe/keycloak-theme-rabe/releases/download/v$THEME_VERSION/keycloak-theme-rabe.jar \
    && /opt/keycloak/bin/kc.sh build

RUN    mkdir -p /mnt/rootfs \
    && microdnf install -y \
           --releasever 9 \
           --installroot /mnt/rootfs \
           --nodocs \
           --noplugins \
           --config /etc/dnf/dnf.conf \
           --setopt install_weak_deps=0 \
           --setopt cachedir=/var/cache/dnf \
           --setopt reposdir=/etc/yum.repos.d \
           --setopt varsdir=/etc/yum.repos.d \
           glibc-langpack-en \
           java-21-openjdk-headless \
    && echo "keycloak:x:0:root" >> /mnt/rootfs/etc/group \
    && echo "keycloak:x:1000:0:keycloak user:/opt/keycloak:/sbin/nologin" >> /mnt/rootfs/etc/passwd \
    && cp \
       /etc/pki/ca-trust/source/anchors/rabe-ca.crt \
       /mnt/rootfs/etc/pki/ca-trust/source/anchors/ \
    && chmod a-s \
       /mnt/rootfs/usr/sbin/* \
       /mnt/rootfs/usr/libexec/*/* \
    && rm -rf \
       /mnt/rootfs/var/cache/* \
       /mnt/rootfs/var/log/dnf* \
       /mnt/rootfs/var/log/yum.*

FROM scratch AS app

COPY --from=builder /mnt/rootfs /
COPY --from=builder /opt/keycloak/ /opt/keycloak/

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
