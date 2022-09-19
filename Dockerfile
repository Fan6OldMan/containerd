FROM maven:3.6.0-jdk-11-slim as build

WORKDIR /app

COPY src ./src
COPY pom.xml ./pom.xml

RUN mvn -f pom.xml clean package

FROM alpine:latest

ENV JAVA_HOME="/usr/lib/jvm/default-jvm/"

RUN apk add openjdk11

ENV PATH=$PATH:${JAVA_HOME}/bin

RUN apk -U upgrade --update && \
    mkdir /opt/tomcat && \
    wget -O /tmp/apache-tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz && \
    tar xvzf apache-tomcat-9.0.65.tar.gz --strip-components 1 --directory /opt/tomcat && \
    addgroup -g 2000 tomcat && \
    adduser -h /opt/tomcat -u 2000 -G tomcat -s /bin/sh -D tomcat && \
    mkdir -p /opt/tomcat/logs && \
    mkdir -p /opt/tomcat/work && \
    chown -R tomcat:tomcat /opt/tomcat/ && \
    chmod -R u+wxr /opt/tomcat

ENV CATALINA_HOME /opt/tomcat/
ENV PATH $CATALINA_HOME/bin:$PATH
ENV TOMCAT_NATIVE_LIBDIR=$CATALINA_HOME/native-jni-lib
ENV LD_LIBRARY_PATH=$CATALINA_HOME/native-jni-lib

COPY --from=build /app/target/demo.war ./opt/tomcat/webapps

EXPOSE 8080

CMD ["catalina.sh", "run"]
