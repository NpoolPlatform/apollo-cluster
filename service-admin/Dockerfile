FROM apolloconfig/apollo-adminservice:1.9.1

RUN apk add curl -y
RUN apk add jq -y

COPY .docker-tmp/consul /usr/bin/consul

RUN mkdir -p /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin
COPY startup.sh /apollo-adminservice/scripts/startup.sh
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

CMD ["docker-entrypoint.sh"]
