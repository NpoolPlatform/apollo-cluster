#!/bin/sh

export SPRING_DATASOURCE_USERNAME="root"
export SPRING_DATASOURCE_PASSWORD="$MYSQL_PASSWORD"

MYSQL_HOST=`curl http://${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}/v1/agent/health/service/name/mysql.npool.top | jq '.[0] | .Service | .Address'`
if [ ! $? -eq 0 ]; then
  echo "FAIL TO GET MYSQL HOST"
  exit 1
fi

MYSQL_PORT=`curl http://${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}/v1/agent/health/service/name/mysql.npool.top | jq '.[0] | .Service | .Port'`
if [ ! $? -eq 0 ]; then
  echo "FAIL TO GET MYSQL PORT"
  exit 1
else
  echo "debug info: $MYSQL_HOST:$MYSQL_PORT"
fi

echo "" > /apollo-portal/config/application-github.properties

MYSQL_HOST=`echo $MYSQL_HOST | sed 's/"//g'`
export SPRING_DATASOURCE_URL=jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/ApolloPortalDB?characterEncoding=utf8&createDatabaseIfNotExist=true&useSSL=false&autoReconnect=true&useUnicode=true

export JAVA_OPTS="$JAVA_OPTS -Dspring.datasource.url=$SPRING_DATASOURCE_URL -Dspring.datasource.username=$SPRING_DATASOURCE_USERNAME -Dspring.datasource.password=$SPRING_DATASOURCE_PASSWORD"

/apollo-portal/scripts/startup.sh $@
