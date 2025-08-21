FROM quay.io/keycloak/keycloak:20.0.3-0 as builder

# Theme version, see https://github.com/radiorabe/keycloak-theme-rabe/releases
ARG THEME_VERSION=0.3.0

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak

# install curl so we can download our theme
USER 0
RUN    microdnf install -y \
           curl \
    && microdnf clean all
USER 1000

RUN    curl -L -o providers/keycloak-theme-rabe-$THEME_VERSION.jar \
           https://github.com/radiorabe/keycloak-theme-rabe/releases/download/v$THEME_VERSION/keycloak-theme-rabe.jar \
    && /opt/keycloak/bin/kc.sh build


FROM ghcr.io/radiorabe/ubi9-minimal:0.9.3

# from https://github.com/keycloak/keycloak/blob/main/quarkus/container/Dockerfile#L25-L35
RUN    microdnf install -y \
           glibc-langpack-en \
           java-17-openjdk-headless \
    && microdnf clean all \
    && echo "keycloak:x:0:root" >> /etc/group \
    && echo "keycloak:x:1000:0:keycloak user:/opt/keycloak:/sbin/nologin" >> /etc/passwd

COPY --from=builder /opt/keycloak/ /opt/keycloak/

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
