# Some docker-compose Notes

This directory includes a docker-compose.yml file which can be used to spin up a local flink cluster in addition to a local mongodb, mysqldb & postgresqldb.

Take note of the .env file which is used to name the compose project, allowing the file to be moved around if required.

Note the same 'export COMPOSE_PROJECT_NAME=devlab' is specified in the creTopics.sh to allow the docker-compose commands to know which compose project to use.

Note: I work on a M1 based Mac, so my architecture is arm64, aka aarch64, ss such see all Dockerfile's under "./devlab/*" for the base images used.

If you are going to use shadotraffic to generate data make sure yo get yourself a license key from https://www.shadotraffic.com/

Note: I had to change the schema_manager default port from 8081 to 9081 as 8081 is already in use by the flink cluster/jobmanager.


