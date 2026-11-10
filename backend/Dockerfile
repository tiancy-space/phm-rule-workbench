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
# Render 免费实例 512MB。堆上限 300MB，串行 GC 比 G1 更省本地内存；
# JDK 8u191 起默认开启容器感知，这里再写明，避免按宿主机内存去估堆。
ENV JAVA_TOOL_OPTIONS="-Xms64m -Xmx300m -XX:MaxMetaspaceSize=96m -Xss256k -XX:+UseSerialGC -XX:+UseContainerSupport -XX:+ExitOnOutOfMemoryError"
EXPOSE 8080
COPY --from=build /src/target/phm-rule-workbench.jar /app/app.jar
# 端口由环境变量 PORT 决定，默认 8080；地址在 application.yml 中绑定 0.0.0.0
ENTRYPOINT ["sh", "-c", "exec java -Dserver.port=${PORT:-8080} -jar /app/app.jar"]
