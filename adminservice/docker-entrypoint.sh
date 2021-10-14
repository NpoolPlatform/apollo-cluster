#!/bin/sh

CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT} consul services register -address=apollo-adminservice.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local -name=apollo-adminservice.npool.top -port=8090
if [ ! $? -eq 0 ]; then
  echo "FAIL TO REGISTER ME TO CONSUL"
  exit 1
fi

export SPRING_DATASOURCE_USERNAME="root"
export SPRING_DATASOURCE_PASSWORD="$MYSQL_ROOT_PASSWORD"

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

export SPRING_DATASOURCE_URL=jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/ApolloConfigDB?characterEncoding=utf8

/apollo-configservice/scripts/startup.sh $@
