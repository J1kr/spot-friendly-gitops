# --- 1단계: 빌드용 이미지 ---
FROM gradle:8.5-jdk17 AS builder

# 캐시 최적화를 위해 의존성 먼저 복사
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle gradle
COPY src src

# 빌드 실행
RUN gradle build --no-daemon

# --- 2단계: 실행용 경량 이미지 ---
FROM eclipse-temurin:24-jdk-alpine

WORKDIR /app

# 빌드된 jar 복사
COPY --from=builder /home/gradle/build/libs/*.jar app.jar

# 실행
ENTRYPOINT ["java", "-jar", "app.jar"]