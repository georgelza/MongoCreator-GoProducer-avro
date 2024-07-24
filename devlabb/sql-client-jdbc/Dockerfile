
###############################################################################
#SQL CLI - inspired by https://github.com/wuchong/flink-sql-demo/tree/v1.11-EN/sql-client
###############################################################################

FROM arm64v8/flink:1.18.1-scala_2.12-java11

USER root

# Install some useful tools
RUN echo "-> Install some useful tools"; \
    apt-get update && \
    apt-get install -y neovim tree lnav unzip

RUN echo "-> Install duckdb cli" ; \
    wget https://github.com/duckdb/duckdb/releases/download/v1.0.0/duckdb_cli-linux-aarch64.zip \
    && unzip duckdb_cli-linux-aarch64.zip -d /usr/local/bin \
    && rm duckdb_cli-linux-aarch64.zip


# Create CLI lib folder
RUN echo "-> Creating directories"; \
    mkdir -p /opt/sql-client/conf;

# Copy configuration
#COPY flink-iceberg-jdbc/conf/hive-site.xml /opt/sql-client/conf/hive-site.xml
COPY sql-client-jdbc/bin/sql-client.sh /opt/sql-client/
COPY sql-client-jdbc/conf/flink-conf.yaml /opt/flink/conf/flink-conf.yaml

USER flink

RUN echo "-> Install JARs: Flink's Kafka connector"; \
    mkdir -p /opt/flink/lib/kafka; \
    wget -P /opt/flink/lib/kafka https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.1.0-1.18/flink-sql-connector-kafka-3.1.0-1.18.jar; \
    wget -P /opt/flink/lib/kafka https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.18.1/flink-sql-connector-hive-3.1.3_2.12-1.18.1.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.2-1.18/flink-connector-jdbc-3.1.2-1.18.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-json/1.18.1/flink-json-1.18.1.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-json/1.18.1/flink-sql-json-1.18.1.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro/1.18.1/flink-sql-avro-1.18.1.jar; \
    wget -P /opt/flink/lib/kafka https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro-confluent-registry/1.18.1/flink-sql-avro-confluent-registry-1.18.1.jar;

RUN echo "-> Add Flink S3 Plugin"; \
    mkdir ./plugins/s3-fs-hadoop ; \
    cp ./opt/flink-s3-fs-hadoop-1.18.1.jar ./plugins/s3-fs-hadoop/


RUN echo "-> Install JARs: Postgres JDBC driver"; \
    mkdir -p ./lib/jdbc ; \
    wget -P /opt/flink/lib/jdbc https://jdbc.postgresql.org/download/postgresql-42.7.1.jar;


RUN echo "-> Install JARs: Dependencies for Iceberg"; \
    mkdir -p ./lib/iceberg ; \
    wget -P /opt/flink/lib/iceberg https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime-1.17/1.4.3/iceberg-flink-runtime-1.17-1.4.3.jar; \
    wget -P /opt/flink/lib/iceberg https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.4.3/iceberg-aws-bundle-1.4.3.jar;

RUN echo "-> Install JARs: AWS / Hadoop S3"; \
    mkdir -p /opt/flink/lib/aws; \
    wget -P /opt/flink/lib/aws https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar; \
    wget -P /opt/flink/lib/aws https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.648/aws-java-sdk-bundle-1.12.648.jar; 


RUN echo "-> Install JARs: Hadoop"; \
    mkdir -p /opt/flink/lib/hadoop; \
    wget -P /opt/flink/lib/hadoop https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/2.8.3-10.0/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar;

USER root

RUN echo "-> Purge apt artifacts"; \
    apt-get purge -y --auto-remove $build_deps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/sql-client
ENV SQL_CLIENT_HOME /opt/sql-client

COPY sql-client-jdbc/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

