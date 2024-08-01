
###############################################################################
# https://www.decodable.co/blog/kafka-to-iceberg-with-flink
###############################################################################

FROM arm64v8/flink:1.18.1-scala_2.12-java11
SHELL ["/bin/bash", "-c"]

WORKDIR /opt/flink


RUN "--> Echo Install some useful tools" && \
    buil_deps="neovim tree lnav unzip" && \
    apt-get update && \
    apt-get install -y $buil_deps

    
RUN "--> Set up Hive config"
COPY flink/conf/hive-site.xml ./conf/hive-site.xml


RUN "--> Enable SQL Client to find the job manager when running it from this image" && \
    sed -i "s/jobmanager.rpc.address: localhost/jobmanager.rpc.address: devlab-flink-jobmanager/g" ./conf/flink-conf.yaml

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
    curl https://repository.apache.org/snapshots/org/apache/paimon/paimon-flink-1.18/0.9-SNAPSHOT/ -O && \
    curl https://repository.apache.org/snapshots/org/apache/paimon/paimon-flink-action/0.9-SNAPSHOT/ -O && \
    popd


RUN echo "--> Install JARs: Flink HIVE dependencies" && \
    mkdir -p ./lib/hive && pushd $_ && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-hive-3.1.3_2.12/1.19.1/flink-sql-connector-hive-3.1.3_2.12-1.19.1.jar && \
    popd


RUN echo "--> Install JARs: Flink's Hive connector" && \
    mkdir -p ./lib/hive && pushd $_ && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-hive_2.12-1.19.1/???/flink-connector-hive_2.12-1.19.1.jar && \
    popd


RUN echo "--> Install JARs: Hive dependencies" && \
    mkdir -p ./lib/hive && pushd $_ && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/hive-exec-3.1.0./???/hive-exec-3.1.0.jar && \
    curl https://repo.maven.apache.org/maven2/org/apache/flink/libfb303-0.9.3/???/libfb303-0.9.3.jar && \
    popd


RUN echo "--> Install JARs: add antlr-runtime if you need to use hive dialect" && \
    mkdir -p ./lib/hive && pushd $_ && \
    curl https://repo.maven.apache.org/maven2/org/apache/???/antlr-runtime-3.5.2/???/antlr-runtime-3.5.2.jar && \
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


RUN echo "--> urge apt artifacts" && \
    apt-get purge -y --auto-remove $buil_deps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the launch command
CMD ./bin/start-cluster.sh && sleep infinity
