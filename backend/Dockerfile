# 多阶段构建：编译用 JDK 8，运行用 JRE 8。
# Render 免费 Docker Web Service 会注入 PORT，应用监听 0.0.0.0:$PORT。
FROM maven:3.8.8-eclipse-temurin-8 AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests package

FROM eclipse-temurin:8-jre
WORKDIR /app
ENV PORT=8080
EXPOSE 8080
COPY --from=build /src/target/phm-rule-workbench.jar /app/app.jar
# 端口由环境变量 PORT 决定，默认 8080；地址在 application.yml 中绑定 0.0.0.0
ENTRYPOINT ["sh", "-c", "exec java -Dserver.port=${PORT:-8080} -jar /app/app.jar"]
