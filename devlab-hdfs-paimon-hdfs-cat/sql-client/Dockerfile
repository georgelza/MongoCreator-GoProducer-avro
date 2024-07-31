
###############################################################################
#SQL CLI - inspired by https://github.com/wuchong/flink-sql-demo/tree/v1.11-EN/sql-client
###############################################################################

FROM arm64v8/flink:1.18.1-scala_2.12-java11
SHELL ["/bin/bash", "-c"]

WORKDIR /opt/flink


RUN echo "--> Install some useful tools" && \
    apt-get update && \
    apt-get install -y neovim tree lnav unzip


RUN echo "--> Creating SQL Client directories" && \
    mkdir -p /opt/sql-client/conf


RUN echo "--> Copy SQL Client shell script" && \ 
    COPY sql-client/bin/sql-client.sh /opt/sql-client/


RUN echo "--> Copy Flink configuration" && \
    COPY conf/flink-conf.yaml ./conf/flink-conf.yaml

    
# Install JARs
# See https://repo.maven.apache.org/maven2/org/apache/flink/

RUN echo "--> Install JARs: Flink's Kafka connector" && \
    mkdir -p ./lib/kafka && pushd $_ && \
    curl https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.2.0-1.18/flink-sql-connector-kafka-3.2.0-1.18.jar -O && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-jdbc/3.2.0-1.18/flink-connector-jdbc-3.2.0-1.18.jar -O && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-json/1.18.1/flink-sql-json-1.18.1.jar -O && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro/1.18.1/flink-sql-avro-1.18.1.jar -O && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-parquet/1.18.1/flink-sql-parquet-1.18.1.jar -O && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro-confluent-registry/1.18.1/flink-sql-avro-confluent-registry-1.18.1.jar -O && \
    popd


RUN echo "--> Install JARs: Flink's HDFS connector (Catalogs)" && \
    mkdir -p ./lib/hive && pushd $_ && \
    curl https://repository.apache.org/content/groups/snapshots/org/apache/paimon/paimon-flink-1.18/0.9-SNAPSHOT/paimon-flink-1.18-0.9-20240727.002140-43.jar -O && \
    curl https://repository.apache.org/content/groups/snapshots/org/apache/paimon/paimon-flink-action/0.9-SNAPSHOT/paimon-flink-action-0.9-20240727.002140-43.jar -O && \
    popd


RUN echo "--> Install JARs: Flink Hadoop classes" && \
    mkdir -p ./lib/hadoop && pushd $_ && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/2.8.3-9.0/flink-shaded-hadoop-2-uber-2.8.3-9.0.jar && \
    popd


RUN echo "--> Install JARs: AWS / AWS Bundled classes:" && \
    mkdir -p ./lib/aws-bundle && pushd $_ && \
    curl https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.26.9/bundle-2.26.9.jar && \
    popd

    
RUN echo "--> Install JARs: Hadoop" && \
    mkdir -p ./lib/hadoop && pushd $_ && \
    curl https://repo1.maven.org/maven2/org/apache/commons/commons-configuration2/2.1.1/commons-configuration2-2.1.1.jar -O && \
    curl https://repo1.maven.org/maven2/commons-logging/commons-logging/1.1.3/commons-logging-1.1.3.jar -O && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-auth/3.3.4/hadoop-auth-3.3.4.jar -O && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.4/hadoop-common-3.3.4.jar -O && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/thirdparty/hadoop-shaded-guava/1.1.1/hadoop-shaded-guava-1.1.1.jar -O && \
    curl https://repo1.maven.org/maven2/org/codehaus/woodstox/stax2-api/4.2.1/stax2-api-4.2.1.jar -O && \
    curl https://repo1.maven.org/maven2/com/fasterxml/woodstox/woodstox-core/5.3.0/woodstox-core-5.3.0.jar -O && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-hdfs-client/3.3.4/hadoop-hdfs-client-3.3.4.jar -O && \
    curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-mapreduce-client-core/3.3.4/hadoop-mapreduce-client-core-3.3.4.jar -O  && \
    popd


RUN echo "--> Purge apt artifacts" && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    

WORKDIR /opt/sql-client
ENV SQL_CLIENT_HOME /opt/sql-client

COPY sql-client/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

