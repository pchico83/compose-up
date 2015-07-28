FROM jpetazzo/dind:latest
MAINTAINER Pablo Chico de Guzman <pchico83@gmail.com>

ENV REFRESHED_AT 2015-08-01
ENV PATH /docker-compose.yml
ENV VERSION 1.3.2

RUN apt-get update && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD run.sh /

CMD ["/run.sh"]