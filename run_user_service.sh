#!/bin/bash
set -e

APP_JAR_DIR="$(pwd)/build/libs"
JAR_FILE="user-service-0.0.1.jar"

if [ ! -f "$APP_JAR_DIR/$JAR_FILE" ]; then
    echo "Khong tim thay file $APP_JAR_DIR/$JAR_FILE! Dang build jar..."
    ./gradlew bootJar
fi

# Dung va xoa container cu neu co
docker stop quickbite-user 2>/dev/null || true
docker rm quickbite-user 2>/dev/null || true

# Khoi chay container voi Volume Mounting va network routing
docker run -d \
  --name quickbite-user \
  -p 8081:8081 \
  -v "$APP_JAR_DIR:/app" \
  -w /app \
  --add-host=host.docker.internal:host-gateway \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/postgres \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=12345678 \
  eclipse-temurin:17-jre-alpine \
  java -jar "$JAR_FILE"

echo "Container quickbite-user da duoc khoi chay thanh cong!"
docker ps | grep quickbite-user
