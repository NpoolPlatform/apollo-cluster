#!/bin/sh

CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT} consul services register -address=apollo-configservice.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local -name=apollo-configservice.npool.top -port=8080
if [ ! $? -eq 0 ]; then
  echo "FAIL TO REGISTER ME TO CONSUL"
  exit 1
fi

export SPRING_DATASOURCE_USERNAME="root"
export SPRING_DATASOURCE_PASSWORD="$MYSQL_PASSWORD"

MYSQL_HOST=`curl http://${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}/v1/agent/service/mysql.npool.top | jq .Address`
if [ ! $? -eq 0 ]; then
  echo "FAIL TO GET MYSQL HOST"
  exit 1
fi

MYSQL_PORT=`curl http://${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}/v1/agent/service/mysql.npool.top | jq .Port`
if [ ! $? -eq 0 ]; then
  echo "FAIL TO GET MYSQL PORT"
  exit 1
fi

echo "current conf: $MYSQL_HOST:$MYSQL_PORT"

MYSQL_HOST=`echo $MYSQL_HOST | sed 's/"//g'`
export SPRING_DATASOURCE_URL=jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/ApolloConfigDB?characterEncoding=utf8&createDatabaseIfNotExist=true&useSSL=false&autoReconnect=true&useUnicode=true&user=root&password=$MYSQL_PASSWORD

/apollo-configservice/scripts/startup.sh $@
