FROM apolloconfig/apollo-configservice:1.9.1

RUN apk add curl -y
RUN apk add jq -y

COPY .docker-tmp/consul /usr/bin/consul

RUN mkdir -p /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

RUN apk add mysql-client -y
COPY ../sql/apolloconfigdb.sql /apollo-configservice/
COPY ../sql/apolloportaldb.sql /apollo-configservice/

CMD ["docker-entrypoint.sh"]
