#!/bin/sh


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

mysql -uroot -p$MYSQL_PASSWORD -h $MYSQL_HOST < /apolloconfigdb.sql
mysql -uroot -p$MYSQL_PASSWORD -h $MYSQL_HOST < /apolloportaldb.sql
if [ ! $? -eq 0 ]; then
  echo "FAIL TO IMPORT SQL FILE"
  exit 1
fi

