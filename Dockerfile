FROM golang:1.22-alpine AS base

WORKDIR /app

COPY . .

COPY go.mod go.sum .
RUN go mod download

COPY . .

FROM base AS build-client

RUN GOOS=linux GOARCH=arm64 go build -g cmd/main.go ./cmd/main
#RUN go build -o cmd/main.go ./cmd/main

FROM scratch

COPY --from=build-client ./cmd/main cmd/
COPY ./*.json ./
COPY ./.pwdloc ./
COPY ./runs_avro.sh ./run.sh

ENTRYPOINT [ "run.sh", "avro" ]



