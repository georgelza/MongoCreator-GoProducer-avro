# Some docker-compose Notes

This directory includes a docker compose.yml file which can be used to spin :

- Confluent Platform Cluster as
- Confluent Platform Broker
- Confluent Connector
- Confluent Control Center
- Confluent Schema Manager
- MongoDB Atlas

## Note:
This Interation is based around the usage of MongoDB Atlas and Atlas Change Streams and Charts.



Take notice of the .env file which is used to name the docker compose project, allowing the docker compose.yml file (project) to be moved around if required.

Note the same 'export COMPOSE_PROJECT_NAME=devlab' is specified in the creTopics.sh to allow the docker-compose commands to know which compose project to use, other words if you change the project name in .env also make sure you change it in creTopics.sh

Note: I work on a M1 based Mac, so my architecture is arm64, aka aarch64, ss such see all Dockerfile's under "./devlab/*" for the base images used.

If you are going to use shadowtraffic to generate data make sure you get yourself a license key from https://www.shadotraffic.com/

Note: I had to change the schema_manager default port from 8081 to 9081 as 8081 is already in use by the flink cluster/jobmanager, and it was easier to change the port for schema_manager than to change the jobmanager port.

Note: I realise by building a seperate apachepod for the job manager and task manager and then a second for the sql-client i could probably collapse this into a more elegant solution, next time, later...

Note: allot of the technical bits came from Robin Moffatt's blogs (You can't do Kafka or Flink and not follow him as a first stop):

    https://github.com/decodableco/examples/blob/main/catalogs/flink-iceberg-jdbc/README.adoc
    &
    https://rmoff.net

    