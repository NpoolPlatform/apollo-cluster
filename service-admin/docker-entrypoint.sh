#!/bin/sh

CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT} consul services register -address=apollo-adminservice.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local -name=apollo-adminservice.npool.top -port=8090
if [ ! $? -eq 0 ]; then
  echo "FAIL TO REGISTER ADMINSERVICE TO CONSUL"
  exit 1
fi

export SPRING_DATASOURCE_USERNAME="root"
export SPRING_DATASOURCE_PASSWORD="$MYSQL_PASSWORD"

if [ "$DEBUG_MODE" == "fixed" ]; then
  MYSQL_HOST='mysql-0.mysql.kube-system.svc.cluster.local'
elif [ "$DEBUG_MODE" == "override" ]; then
  # nothing
else
  MYSQL_HOST=`curl http://${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}/v1/agent/service/mysql.npool.top | jq .Address`
fi

if [ ! $? -eq 0 ]; then
  echo "FAIL TO GET MYSQL HOST"
  exit 1
fi

MYSQL_PORT=`curl http://${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}/v1/agent/service/mysql.npool.top | jq .Port`
if [ ! $? -eq 0 ]; then
  echo "FAIL TO GET MYSQL PORT"
  exit 1
fi

MYSQL_HOST=`echo $MYSQL_HOST | sed 's/"//g'`
export SPRING_DATASOURCE_URL=jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/ApolloConfigDB?characterEncoding=utf8&createDatabaseIfNotExist=true&useSSL=false&autoReconnect=true&useUnicode=true&user=root&password=$MYSQL_PASSWORD

/apollo-adminservice/scripts/startup.sh $@
