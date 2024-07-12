# MongoCreator - GoTransactionProducer

https://github.com/georgelza/MongoCreator-GoProducer-pb

## Basic idea.

Golang app that generate fake sales (maybe split as a basket onto one kafka topic and then a payment onto another, implying the 2 was out of band), then sinking the topic/s into MongoDB using a sink connectors.
At this point I want to show a 2nd stream to it all, and do it via Python. was thinking…
maybe based on data sinked into the MongoDB store, do a trigger… with a do a source connector out of Mongo onto Kafka (some aggregating) and then consume that via the Python app and for simplistic just echo this to the console (implying it can be pushed somewhere further)

## Using the app.

This application generates fake data (salesbaskets), how that is done is controlled by the *_app.json configuration file that configures the run environment. The *_seed.json in which seed data is provided is used to generate the fake basket + basket items and the associated payments (salespayments) documents.

the *_app.json contains comments to explain the impact of the value.

on the Mac (and Linux) platform you can run the program by executing runs_pb.sh
a similar bat file can be configured on Windows

The User can always start up multiple copies, specify/hard code the store, and configure one store to have small baskets, low quantity per basket and configure a second run to have larger baskets, more quantity per product, thus higher value baskets.

## Note: Not included in the repo is a file called .pwd

This file would be located in the project root folder next to the runs_**.sh filesystem
Example: 

export Sasl_password=Vj8MASendaIs0j4r34rsdfe4Vc8LG6cZ1XWilAJjYS05bZIk7AaGx0Y49xb

export Sasl_username=3MZ4dfgsdfdfIUUA

This files is executed via the runs_*.sh file, reading the values into local environment, from where they are injested by a os.Getenv call, if this code is pushed into a docker container then these values can be pushed into a secret included in the environment.

## Overview/plan.

See example/MongoCreatorProject *.jpg for a visual diagram if the thinking.

1. Create salesbaskets and salespayments documents (Golang app).
2. Push salesbaskets and salespayments onto 2 Kafka topics.
3. Combine 2 topics/streams into a salescompleted topic/document.
4. Sink Salesbaskets and Salespayments topics onto MongoDB collections using Kafka sink connectors.
5. Using Kafka Stream processing and kSQL extract sales per store_id per hour into new topic.
6. Sink sales per store per hour onto MongoDB collection using Kafka sink connector.
7. Using Apache Flink processing calculate sales per store per terminal per hour into new kafka topic.
8. Using Kafka Sink connector sink the sales per store per terminal per hour onto MongoDB collection.
9. On MongoDB Atlas cluster merge the salesbaskets and salespayments collection feeds into a salescompleted collection.
10. Using Mongo Aggregation calculate sales by brand by hours and sales by product by hour into 2 new collections.
11. Using Kafka source connector extract 4 Mongo collections onto 4 new Kafka topics.
12. Using 4 Python applications echo the messages from the 4 topics onto the terminal. 

Note: all by hour group'ing on Kafka/kSQL is done at the moment using emit final, which means we wait for the window to complete and then emit the aggregated value... Another option would be to emit changes which means as the number increases then a new record is released - point of self research... is this new record key'd in such a way as as to upsert into a target database, other words replace previous record in a ktable.

Note: all/most subdirectories have local README.md files with some more local topic specific comments.

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


## Some Version notes.
0.2	- 10/01/2024	Pushing/posting basket docs and associated payment docs onto Kafka.

0.3	- 24/01/2024	To "circumvent" Confluent Kafka cluster "unavailability" at this time I'm modifying the code here to insert directly into Mongo Atlas into 2 collections. This will allow the Creator community to interface with the inbound docs on the Atlas environment irrespective how they got there.

... Just look at the top of main.go... 