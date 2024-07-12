# the Below file contains the following variables.
# This is done as such to not include these values into the git repo sync.
# The files themself are added/listed in the .gitignore file.
# 
# Mongo and Kafka credentials as local env variables
# Kafka Creds
#
#export Sasl_username=               
#export Sasl_password=

# MongoDB ATLAS Creds
# https://medium.com/mongoaudit/how-to-enable-authentication-on-mongodb-b9e8a924efac
#
#export mongo_username=    # Same as Atlas / Google auth georgelza@gmail.com
#export mongo_password=
. ./.pwdloc


########################################################################
# Golang  Examples : https://developer.confluent.io/get-started/go/

########################################################################
# MongoDB Params
# Mongo -> Kafka -> MongoDB 
# https://blog.ldtalentwork.com/2020/05/26/how-to-sync-your-mongodb-databases-using-kafka-and-mongodb-kafka-connector/
#
# *_mongo.json & -> See .pws

go run -v cmd/main.go pb


# https://docs.confluent.io/platform/current/app-development/kafkacat-usage.html
# kafkacat -b localhost:9092 -t SNDBX_AppLab