FROM confluentinc/cp-kafka-connect-base:latest

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
RUN echo "Installing Connector Plugins"
RUN confluent-hub install --no-prompt jcustenborder/kafka-connect-spooldir:2.0.43
RUN confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.12.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:latest
RUN confluent-hub install --no-prompt markteehan/file-chunk-sink:latest
RUN confluent-hub install --no-prompt tabular/iceberg-kafka-connect:latest
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:latest

USER root
RUN wget -O /usr/share/java/kafka/mysql-connector-j-8.4.0.jar \
    https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar
USER appuser

# docker build -t kafka-connect-custom:1.0 .