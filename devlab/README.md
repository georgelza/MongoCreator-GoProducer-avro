# Some docker-compose Notes

This directory includes a docker-compose.yml file which can be used to spin up a local flink cluster in addition to a local mongodb, mysqldb & postgresqldb.

Take note of the .env file which is used to name the compose project, allowing the file to be moved around if required.

Note the same .env file is located in the Topics directory to allow the docker-compose commands to know which compose project to use.

If we want to include the project name on all containers created then removed the container definition from the docker-compose.yml file.

Note: this would require things like the creTopics.sh to be modified to include the project name.

This might also have impact on the various depends_on sections in the docker-compose.yml file.