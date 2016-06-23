FROM sequenceiq/hadoop-docker:2.6.0
MAINTAINER antlypls

#JAVA 1.8
RUN yum -y remove jdk*
RUN curl -LO "http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.rpm" -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-8u91-linux-x64.rpm
RUN rm jdk-8u91-linux-x64.rpm

#support for Hadoop 2.6.0
RUN curl -s https://www.apache.org/dist/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.6.1-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.6.1-bin-hadoop2.6/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin
# update boot script
COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENTRYPOINT ["/etc/bootstrap.sh"]
