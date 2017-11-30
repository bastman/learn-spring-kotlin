FROM java:8

EXPOSE 8080 8081

COPY build/libs/learn-spring-kotlin-0.0.1-SNAPSHOT.jar /opt/learn-spring-kotlin/app.jar
COPY src/main/resources/application*.yml /opt/learn-spring-kotlin/debug/

COPY docker/app/check-health.sh /usr/local/bin/

WORKDIR /opt/learn-spring-kotlin
CMD java -jar app.jar
