# 멀티 스테이지 Dockerfile
FROM gradle:jdk17 AS builder
# 빌드를 위한 gradle
WORKDIR /workspace
# builder 단계 내에서의 작업 폴더

COPY build.gradle settings.gradle ./
# build gradle, setting.gradle 빌드 스크립트 2종을 먼저 복사
RUN gradle dependencies --no-daemon || true
# 의존성 캐시 최적화를 위해 빌드 관련 의존성을 먼저 세팅

COPY src src
# 소스 코드를 복사
RUN gradle bootJar --no-daemon
# JAR 패키징

FROM azul/zulu-openjdk-alpine:17-jre-headless-latest
# 실행 환경을 위한 단계
WORKDIR /app
# docker 내에서 작업하는 폴더

#COPY build/libs/*-SNAPSHOT.jar app.jar
COPY --from=builder /workspace/build/libs/*-SNAPSHOT.jar app.jar
# 그 폴더에 현 프로젝트 내부의 jar를 복사해주겠다는 의미

ENV PORT=8080
# Docker에서 직접적으로 환경변수를 세팅
EXPOSE 8080
# 포트 권장사항
ENTRYPOINT ["java", "-jar", "app.jar"]
# jar 실행을 지시하는 구문