
###############################################################################
#SQL CLI - inspired by https://github.com/wuchong/flink-sql-demo/tree/v1.11-EN/sql-client
###############################################################################

FROM arm64v8/flink:1.18.1-scala_2.12-java11


# Install some useful tools
RUN apt-get update && \
    apt-get install -y neovim tree lnav unzip

RUN echo "Purge apt artifacts" && \
    apt-get purge -y --auto-remove $build_deps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/duckdb/duckdb/releases/download/v1.0.0/duckdb_cli-linux-aarch64.zip \
    && unzip duckdb_cli-linux-aarch64.zip -d /usr/local/bin \
    && rm duckdb_cli-linux-aarch64.zip
    
# Create CLI lib folder

RUN echo "-> Creating directories"; \
    mkdir -p /opt/sql-client/conf;

# Copy configuration
COPY sql-client/bin/sql-client.sh /opt/sql-client/
COPY sql-client/conf/flink-conf.yaml /opt/flink/conf/flink-conf.yaml
COPY flink/conf/hive-site.xml /opt/sql-client/conf/hive-site.xml

RUN echo "-> Install JARs: Flink's Kafka connector"; \
    mkdir -p /opt/flink/lib/kafka; \
    wget -P /opt/flink/lib/kafka https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.1.0-1.18/flink-sql-connector-kafka-3.1.0-1.18.jar; \
    wget -P /opt/flink/lib/kafka https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.18.1/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.18/flink-connector-jdbc-3.1.2-1.18.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-json/1.18.1/flink-json-1.18.1.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-json/1.18.1/flink-sql-json-1.18.1.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro/1.18.1/flink-sql-avro-1.18.1.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro-confluent-registry/1.18.1/flink-sql-avro-confluent-registry-1.18.1.jar;

RUN echo "-> Install JARs: Flink's Hive connector (Catalogs)"; \
    mkdir -p /opt/flink/lib/hive; \
    wget -P /opt/flink/lib/hive https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.18.1/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar;

RUN echo "-> Install JARs: Dependencies for Iceberg"; \
    mkdir -p /opt/flink/lib/iceberg; \
    wget -P /opt/flink/lib/iceberg https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.18/1.5.0/iceberg-flink-runtime-1.18-1.5.0.jar; \
    wget -P /opt/flink/lib/iceberg https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.5.0/iceberg-aws-bundle-1.5.0.jar;


RUN echo "-> Install JARs: AWS / Hadoop S3"; \
    mkdir -p /opt/flink/lib/aws; \
    wget -P /opt/flink/lib/aws https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar; \
    wget -P /opt/flink/lib/aws  https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.648/aws-java-sdk-bundle-1.12.648.jar; 


RUN echo "-> Install JARs: Hadoop"; \
    mkdir -p /opt/flink/lib/hadoop; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/org/apache/commons/commons-configuration2/2.1.1/commons-configuration2-2.1.1.jar; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/commons-logging/commons-logging/1.1.3/commons-logging-1.1.3.jar; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.4/hadoop-auth-3.3.4.jar; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.4/hadoop-common-3.3.4.jar; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/org/codehaus/woodstox/stax2-api/4.2.1/stax2-api-4.2.1.jar; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/com/fasterxml/woodstox/woodstox-core/5.3.0/woodstox-core-5.3.0.jar; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs-client/3.3.4/hadoop-hdfs-client-3.3.4.jar; \
    wget -P /opt/flink/lib/hadoop https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.4/hadoop-mapreduce-client-core-3.3.4.jar;

#RUN echo "-> Install JARs: DB's"; \
#    wget -P /opt/flink/lib/ https://jdbc.postgresql.org/download/postgresql-42.7.1.jar; \
#    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.0.0/mysql-connector-j-9.0.0.jar;
#    wget -P /opt/flink/lib/ https://github.com/knaufk/flink-faker/releases/download/v0.5.3/flink-faker-0.5.3.jar; \
#    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-protobuf/1.18.1/flink-sql-protobuf-1.18.1.jar; \
#    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch7/3.0.1-1.17/flink-sql-connector-elasticsearch7-3.0.1-1.18.jar; 

    

WORKDIR /opt/sql-client
ENV SQL_CLIENT_HOME /opt/sql-client

USER root
COPY sql-client/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

