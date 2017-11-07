FROM alpine:3.6

ENV LANG C.UTF-8

RUN { \
      echo '#!/bin/sh'; \
      echo 'set -e'; \
      echo; \
      echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u131
ENV JAVA_ALPINE_VERSION 8.131.11-r2
ENV HADOOP_HOME /usr/local/hadoop

RUN set -x \
    && apk add --no-cache openjdk8=$JAVA_ALPINE_VERSION curl tar gzip bash \
    && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# install common hadoop
RUN curl -OL https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.8.2/hadoop-2.8.2.tar.gz \
 && tar -xvf hadoop-2.8.2.tar.gz \
 && mv hadoop-2.8.2 /usr/local/hadoop \
 && rm hadoop-2.8.2.tar.gz

RUN mkdir -p ~/hdfs/namenode \
 && mkdir -p ~/hdfs/datanode \
 && mkdir $HADOOP_HOME/logs
