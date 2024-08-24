### Reading Parquet Files Directly via Paradedb which is PostgreSQL + extensions


- [ParadeDB](https://www.paradedb.com)

- [ParadeDB -S3](https://docs.paradedb.com/analytics/object_stores/s3)

- [Querying S3 Directly from PostgreSQL: A Step-by-Step Guide](https://siddique-ahmad.medium.com/querying-s3-directly-from-postgresql-a-step-by-step-guide-06a0a2f4828b)


### If you want to start the image manually

```
      docker start \
    --name paradedb \
    -e POSTGRES_USER=pdbadmin \
    -e POSTGRES_PASSWORD=pdbpassword \
    -e POSTGRES_DB=iceberg \
    -v ./data/paradedb:/var/lib/postgresql/data/ \
    -p 15432:5432 \
    --network devlab \
    -d \
    paradedb/paradedb:latest
```

### Some Makefile commands
```
start_pdb:
	docker compose -p devlab up -d paradedb
stop_pdb:
	docker compose -p devlab stop paradedb
monitor_pdb:
	docker compose logs -f paradedb
```