FROM bitnami/golang:1.22 AS builder

LABEL Author="George Leonard (georgelza@gmail.com)"

ENV GOPROXY=https://proxy.golang.org,direct
ENV GOSUMDB=sum.golang.org

WORKDIR /build

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY . .

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


RUN go build -v -o ./main /build/cmd/main.go

###########START NE W IMAGE###################
FROM bitnami/golang:1.22 AS production

WORKDIR /app

COPY --from=builder /build/main .
RUN chmod +x /app/main
COPY .pwd .
COPY conf /app/conf/

CMD ["/app/main", "avro"]
