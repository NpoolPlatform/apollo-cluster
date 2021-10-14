FROM apolloconfig/apollo-adminservice:1.9.1

RUN apt-get update -y
RUN apt-get install curl -y

COPY .docker-tmp/consul /usr/bin/consul

RUN mkdir -p /usr/local/bin
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

CMD ["docker-entrypoint.sh"]
