
## Push Gateway method...

NOT USED in project yet.

This is my test environment to explore Prometheus and Grafana.
When I choose.. I instrument my project to see the impact, what can be done, these metrics are then scraped using the below stack and displayed.

Metrics specified as part of a struct

- Start Prometheus Push Gateway process
- Start Prometheus processes
- Start Grafana client

-- Prometheus Push Gateway
docker run -d \
    -p 9091:9091 \
    prom/pushgateway

-- Prometheus
- Remember to modify the prometheus.yaml to use/reference the push gateway to be scraped.
- Update prometheus.yaml replacing 172.16.20.29 with the ip of the pushgateway host, this will match the value in sit_app.json
- Add a hostname/alias to local machine pointing to machine IP.
- Modify below to point to your location for prometheus.yaml
- If you're running the pushgateway locally in docker then use your host/ip address

docker run -d \
    -p 9090:9090 \
    -v /Users/george/Desktop/ProjectsCommon/fs/fs_scenario_tester2.2/prometheus/config:/etc/prometheus \
    prom/prometheus

or

docker volume create a-new-volume
docker run \
    --publish 9090:9090 \
    --volume a-new-volume:/prometheus-data \
    --volume /Users/george/Desktop/ProjectsCommon/fs/fs_scenario_tester2.2/prometheus/config:/etc/prometheus \
    prom/prometheus
or
docker run \
    --publish 9090:9090 \
    --volume a-new-volume:/prometheus-data \
    --volume "$(pwd)"/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus




-- Start Grafana
docker volume create grafana-storage

docker run -d \
    -p 3000:3000 
    --name=grafana \
    --volume grafana-storage:/var/lib/grafana \
  grafana/grafana-enterprise

 or 

mkdir data
docker run -d \
    -p 3000:3000 
    --name=grafana \
    --user "$(id -u)" \
    --volume "$PWD/data:/var/lib/grafana" \
  grafana/grafana-enterprise

Now go into Grafana (default username/password is admin/admin)
Configure a prometheus data source, that uses the above configured hostname,

    http://localhost:3000

Do not use 127.0.0.1 as the Grafana container will think of that in a local 
sense and look for the prometheus datastore locally.


Notes
https://prometheus.io/docs/prometheus/latest/installation/
https://prometheus.io/docs/prometheus/latest/getting_started/
https://antonputra.com/monitoring/monitor-golang-with-prometheus/#gauge

