FROM openjdk:17-jdk-alpine

# 创建目录
WORKDIR /works
COPY . /works/coze-discord/
ENV DEBIAN_FRONTEND=noninteractive
RUN cd /works/coze-discord  && \
    # install maven
    apk update && \
    wget -O /tmp/apache-maven.tar.gz https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && \
    mkdir -p /usr/share/maven && \
    tar -zxvf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 && \
    rm -f /tmp/apache-maven.tar.gz && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn && \
    # build maven
    mvn clean package && \
    mkdir -p /campus/server && \
    cp target/coze-discord-1.0.1.jar /campus/server/app.jar

ENV SERVER_PORT=8080 LANG=C.UTF-8 LC_ALL=C.UTF-8 JAVA_OPTS=""
EXPOSE ${SERVER_PORT}
WORKDIR /campus/server
ENTRYPOINT java -Djava.security.egd=file:/dev/./urandom -Dserver.port=${SERVER_PORT} \
    -Ddiscord.botToken=${DISCORD_BOT_TOKEN} \
    -Ddiscord.guildId=${DISCORD_GUILD_ID} \
    -Ddiscord.cozeBotId=${DISCORD_COZE_BOT_ID} \
    -Ddiscord.channelId=${DISCORD_CHANNEL_ID} \
    -Ddiscord.proxyHostPort=${DISCORD_PROXY_HOST_PORT} \
    -jar app.jar \
    -XX:+HeapDumpOnOutOfMemoryError -Xlog:gc*,:time,tags,level -XX:+UseZGC ${JAVA_OPTS}

