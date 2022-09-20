FROM maven:3.6.0-jdk-11-slim as build

WORKDIR /app

COPY src ./src
COPY pom.xml ./pom.xml

RUN mvn -f pom.xml clean package

FROM openjdk:8-jdk-alpine

ENV TOMCAT_MAJOR=8 \
    TOMCAT_VERSION=8.5.37 \
    CATALINA_HOME=/opt/tomcat

RUN apk -U upgrade --update && \
    apk add curl && \
    apk add ttf-dejavu

RUN mkdir -p /opt

RUN curl -jkSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME

RUN apk del curl && \
    rm -rf /tmp/* /var/cache/apk/*

COPY --from=build /app/target/demo.war ./opt/tomcat/webapps

RUN sh $CATALINA_HOME/bin/startup.sh

EXPOSE 8080




