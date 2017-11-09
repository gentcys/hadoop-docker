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
    && apk add --no-cache openjdk8=$JAVA_ALPINE_VERSION curl tar gzip bash openssh rsync \
    && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# install common hadoop
RUN curl -OL http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.8.2/hadoop-2.8.2.tar.gz \
 && tar -xf hadoop-2.8.2.tar.gz \
 && mv hadoop-2.8.2 /usr/local/hadoop \
 && rm hadoop-2.8.2.tar.gz

RUN mkdir -p ~/hdfs/namenode \
 && mkdir -p ~/hdfs/datanode \
 && mkdir $HADOOP_HOME/logs

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
RUN mkdir -p /root/.ssh
RUN cp /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN cat /etc/ssh/ssh_host_rsa_key.pub >> /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# RUN /usr/sbin/sshd -D -f /etc/ssh/sshd_config

EXPOSE 22

ENTRYPOINT ["sh", "-c", "/usr/sbin/sshd -D -f /etc/ssh/sshd_config; bash"]
