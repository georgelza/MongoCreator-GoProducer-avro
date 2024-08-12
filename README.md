# MongoCreator - GoTransactionProducer

https://github.com/georgelza/MongoCreator-GoProducer-avro

## Basic idea.

Golang app that generate fake sales (maybe split as a basket onto one kafka topic and then a payment onto another, implying the 2 was out of band), then sinking the topic/s into MongoDB using a sink connectors.
At this point I want to show a 2nd stream to it all, and do it via Python. was thinking…
maybe based on data sinked into the MongoDB store, do a trigger… with a do a source connector out of Mongo onto Kafka (some aggregating) and then consume that via the Python app and for simplistic just echo this to the console (implying it can be pushed somewhere further)

See ./blog-doc/Blog.docx for writeup. This will eventually be posted onto XXX as a multi part article.

## Medium Article

- Part 1: https://medium.com/@georgelza/an-exercise-in-discovery-streaming-data-in-the-analytical-world-part-1-e7c17d61b9d2
- Part 2: https://medium.com/@georgelza/an-exercise-in-discovery-streaming-data-in-the-analytical-world-part-2-be1bfbca3139
- Part 3:
- Part 4:
- Part 5:
- Part 6:


## Overview/plan.

See example/MongoCreatorProject ./blog-doc/diagrams/*.jpg for visual diagrams of the thinking.

1. Create salesbaskets and salespayments documents (Golang app).
2. Push salesbaskets and salespayments onto 2 Kafka topics.
3. Combine 2 topics/streams into a salescompleted topic/document.
4. Sink Salesbaskets and Salespayments topics onto MongoDB collections using Kafka sink connectors.
5. Using Kafka Stream processing and kSQL extract sales per store_id per hour into new topic.
6. Sink sales per store per hour onto MongoDB collection using Kafka sink connector.
7. Using Apache Flink processing calculate sales per store per terminal per hour into new kafka topic.
    a.  Push from Apache Flink to Apache Iceberg on S3
        Added Apache Hive catalog in standalone with a internal DerbyDB back-end. 
        Changed to Apache Hive catalog with a PostgreSql back-end.
    b.  Push from Apache Flink to Apache Paimon on Hadoop/HDFS.
        Added a Apache Hadoop Cluster (3.3.5)
        Changed to Apache Hive catalog on HDFS back-end.
        Changed to Apache Hive catalog with a PostgreSql back end.
        (Using the stand alone Hive metastore for convenience, see infrastructure sub directory for a distributed Hive deployment the in works).
8. Using Kafka Sink connector sink the sales per store per terminal per hour onto MongoDB collection.
9. On MongoDB Atlas cluster merge the salesbaskets and salespayments collection feeds into a salescompleted collection. TooDo
10. Using MongoDB Aggregation calculate sales by brand by hours and sales by product by hour into 2 new collections. ToDo
11. Using Kafka source connector extract 4 Mongo collections onto 4 new Kafka topics. ToDo
12. Using 4 Python applications echo the messages from the 4 topics onto the terminal. ToDo


## Using the app.

This application generates fake data (salesbaskets), how that is done is controlled by the *_app.json configuration file that configures the run environment. The *_seed.json in which seed data is provided is used to generate the fake basket + basket items and the associated payments (salespayments) documents.

the *_app.json contains comments to explain the impact of the value.

on the Mac (and Linux) platform you can run the program by executing runs_avro.sh
a similar bat file can be configured on Windows

The User can always start up multiple copies, specify/hard code the store, and configure one store to have small baskets, low quantity per basket and configure a second run to have larger baskets, more quantity per product, thus higher value baskets.


## Note: Not included in the repo is a 2 files called ./*.pwd

This file would be located in the project root folder next to the runs_**.sh filesystem
Example: 

export Sasl_password=Vj8MASendaIs0j4r34rsdfe4Vc8LG6cZ1XWilAJjYS05bZIk7AaGx0Y49xb

export Sasl_username=3MZ4dfgsdfdfIUUA

This files is executed via the runs_*.sh file, reading the values into local environment, from where they are injested by a os.Getenv call, if this code is pushed into a docker container then these values can be pushed into a secret included in the environment.


## Note: 

All by hour group'ing on Kafka/kSQL is done at the moment using emit final, which means we wait for the window to complete and then emit the aggregated value... 

Another option would be to emit changes which means as the number increases then a new record is released - point of self research... is this new record key'd in such a way as as to upsert into a target database, other words replace previous record in a ktable.

## Note: 

1. all/most subdirectories have local README.md files with some more local topic specific comments.

2. See infrastructure directory for supporting container creates. Each infrastructure directory have a local Makefile.
    
    See blog-doc/diagrams/ImageAncestry.png for high level order of creation.

    As a start, execute the make pullall to docker pull the source images, followed by make buildall to build the images.
    After this you can change into one of the 5 sub directories devlab-* and do a make build followed by make run and then make deploy
    Note make deploy sometimes is a bit to fast, and the topic create fails, just execute it again.

    There is also a little script called cremongoatlassinks. If you populate a file .pwdmongoatlas with your Atlas credentials then this will create a sink job to push salesbaskets and salespayments onto MongoDB Atlas. Likewise if you decide to deploy a local mongodb instance/container then populate .pwdmongolocal with the credentials for cremonglocalsinks.sh use.

## Note:

The following steps was copied out of Rob Moffit's blog, all credit goes to him.

1. Inspecting the data stored in the MinIO S3 container can be accomplished via MC as follows:

    - List the files/folders in iceberg store, and as you get to know more you can increase the depth of the listing.

    docker exec minio mc ls -r minio/iceberg/

    - Copy contents of the hms-standalone DerbyDB out.

    docker cp hms-standalone:/tmp/metastore_db /tmp/hms_db


    rlwrap ij
    
    SHOW TABLE IN app;
    
    SELECT db_id, name FROM dbs;

    - Let's look at the data that's been written to MinIO:
    
    docker exec minio mc ls -r minio/warehouse/

    - Update the below folder/file structure as per your own needs.
    
    docker exec minio mc head minio/warehouse/db_rmoff.db/t_foo/metadata/00000-57d8f913-9e90-4446-a049-db084d17e49d.metadata.json


    docker exec minio mc \
        cat minio/warehouse/db_rmoff.db/t_foo/data/00000-0-e4327b65-69ac-40bc-8e90-aae40dc607c7-00001.parquet \
        /tmp/data.parquet && \
        duckdb :memory: "SELECT * FROM read_parquet('/tmp/data.parquet')"


## Deployable Sections/Sub projects:

The project is broken down into the following sections, the Blog will be aligned with these sections.

1. devlab-mongodb : Firstly we publish messages onto the 2 Kafka topics, which is in turn directly sinked into out MongoDB Atlast collections, from where we then MongoDB Change Stream process the records, after which they are persisted into a new collections which can then be consumed by Apache Kafka via source connectors.

2. devlab-hms-standalone : With the introduction of Apache Flink, the first iteration utilized hms in stand alone, with a internet DerbyDB back-end. this is deployed.

3. devlab-hms-postgres : Next up we migrated the internetl DerbyDB database workload into a external Postgresql datastore.
    For both 1 and 2 we pushed the data to a Apache Iceberg table format stored on a AWS S3 bucket, hosted inside MinIO.

4. devlab-hdfs-paimon-hdfs-cat : For the 3rd version we now going to persist the data onto Apache Paimon format hosted on a Apache Hadoop DFS. As Apache Flink is still involved we still have the HMS with postgres backend for the Flink object persistence/Catalog. The Paimon on HDFS is cataloged by creating catalog objects on hdfs as a file store.

5. devlab-hdfs-paimon-hms-cat : As we are now using Apache Paimon, we can now use the Hive metastore as the catalog for the Flink and Paimon object persistence, backed by a Postgresql database. In this last iteration we move the catalog into the Apache Hive catalog.

To deploy start by changing directory into the infrastructure directory, have a look at the Makefile, and then execute the following:

## Credits... due.

Without these guys and their willingness to entertain allot of questions and some times siply dumb ideas and helping me slowly onto the right path all of this would simply not have been possible.

    Dave Troiano,
        Apache Kafka or Confluent Kafka :
        (Developer support on Confluent Forum @dtroiano),
        https://www.linkedin.com/in/dave-troiano-49a8932/

    Barry Evans, 
        Someone that I consider a friend, just stepped in, starting helping me and as he happily calls it his community service. Helping others figure problems out that they have, whatever the nature, and another always curious mind himself.
        https://confluentcommunity.slack.com/team/U04UNKMRL4U

    Martijn Visser,
        Apache Flink Slack Community
        (PMC and Committer for Apache Flink, Product Manager at Confluent)
        https://apache-flink.slack.com/team/U03GADV9USX

    Ben Gamble,
        Apache Kafka, Apache Flink, streaming and stuff (as he calls it)
        A good friend, thats always great to chat to... and we seldom stick to original topic.
        https://confluentcommunity.slack.com/team/U03R0RG6CHZ
