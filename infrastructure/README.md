# MongoCreator

## Supporting Infrastructure

This section contains most of the Makefile's and Dockerfiles that build the images used by the larger project.

See ImageAncestry.png for the creation order.

The distributed Apache Hive environment depicted in the picture is not used in the project, yet! - 05 Aug 2024

## Note

For the Flink 1.18.1 scala 2.12 image and Flink SQL Pod (ye i know should have left them as one), there are a, b, c and d copies build in the sub projects, the sub project builds modify, change the set of jar's required as per project.
