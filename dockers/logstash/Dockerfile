FROM docker.elastic.co/logstash/logstash:7.9.3

ARG mysql_conn_version="8.0.22"

RUN curl -L --output "mysql-connector-java-${mysql_conn_version}.tar.gz" "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${mysql_conn_version}.tar.gz" \
 && tar -xf "mysql-connector-java-${mysql_conn_version}.tar.gz" "mysql-connector-java-${mysql_conn_version}/mysql-connector-java-${mysql_conn_version}.jar" \
 && mv "mysql-connector-java-${mysql_conn_version}/mysql-connector-java-${mysql_conn_version}.jar" "mysql-connector-java-${mysql_conn_version}.jar" \
 && rm -r "mysql-connector-java-${mysql_conn_version}" "mysql-connector-java-${mysql_conn_version}.tar.gz"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
