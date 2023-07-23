FROM quay.io/keycloak/keycloak:22.0.1 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

# Set the database connection properties for MySQL
ENV KC_DB=mysql
ENV KC_DB_VENDOR=MYSQL
ENV KC_DB_ADDR=localhost
ENV KC_DB_PORT=3306
ENV KC_DB_DATABASE=D3L1V3RY_F00d
ENV KC_DB_USER=U534_1NPR0L1Nk
ENV KC_DB_PASSWORD=P455W0Rd_1NPR0lL!nK
ENV KC_HOSTNAME=localhost

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
#docker run -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:22.0.1 start-dev