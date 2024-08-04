FROM postgres:12

USER root

RUN mkdir -p /var/log/postgresql/
RUN chown -R postgres:postgres /var/log/postgresql
RUN chmod -R 777 /var/log/postgresql/

USER postgres

COPY conf/postgresql.conf /etc/postgresql/postgresql.conf
COPY conf/pg_hba.conf /etc/postgresql/pg_hba.conf

# Override default Postgres config file
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

