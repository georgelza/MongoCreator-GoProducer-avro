FROM bitnami/golang:1.22 AS base_arm64

LABEL Author="George Leonard (georgelza@gmail.com)"

ENV GOPROXY=https://proxy.golang.org,direct
ENV GOSUMDB=sum.golang.org

WORKDIR /app

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change

COPY go.mod /app/
COPY go.sum /app/

RUN go mod download && go mod tidy

# RUN go get github.com/TylerBrock/colorjson
# RUN go get github.com/brianvoe/gofakeit
# RUN go get github.com/confluentinc/confluent-kafka-go/v2/kafka
# RUN go get github.com/confluentinc/confluent-kafka-go/v2/schemaregistry
# RUN go get github.com/confluentinc/confluent-kafka-go/v2/schemaregistry/serde
# RUN go get github.com/confluentinc/confluent-kafka-go/v2/schemaregistry/serde/avrov2
# RUN go get github.com/google/uuid
# RUN go get github.com/tkanos/gonfig
# RUN go get go.mongodb.org/mongo-driver/bson/bsonrw
# RUN go get go.mongodb.org/mongo-driver/mongo
# RUN go get go.mongodb.org/mongo-driver/mongo/options
# RUN go get go.mongodb.org/mongo-driver/mongo/readpref
# RUN go get google.golang.org/grpc/grpclog

###########START NEW IMAGE###################
FROM base_arm64 AS client

WORKDIR /app

COPY . .

RUN go build -v -o /app/cmd/main /app/cmd/main.go

###########START NE W IMAGE###################
FROM bitnami/golang:1.22 AS prod

WORKDIR /app

COPY --from=client /app/cmd/main /app/cmd/
COPY .pwd /app
COPY conf/*.json /app/conf
COPY runs_avro.sh /app

ENV PATH=/app:/app/cmd:$PATH

CMD ["main", "avro"]
#CMD ["runs_avro.sh"]
