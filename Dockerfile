

# Creates pseudo distributed hadoop 2.7.4
#
# docker build -t sequenceiq/hadoop .
###
FROM sequenceiq/pam:centos-6.5
MAINTAINER LuoshangPan

USER root
###
# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync nc
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux
###
# passwordless ssh
# RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
# RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
# RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
# The authorized_keys file in SSH specifies the SSH keys that can be used
# for logging into the user account for which the file is configured.
# Allow itself to connect to itself (still need to add pub key of other server)
# All container will have the same private and public key, so they could connect
# to each other in this way 
# RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
# Use the host machine's ssh for container (so that all of them can communicate)
ADD id_rsa   /root/.ssh/id_rsa
ADD id_rsa.pub   /root/.ssh/id_rsa.pub
ADD authorized_keys  /root/.ssh/authorized_keys
ADD known_hosts   /root/.ssh/known_hosts

###
# java 1.8
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-8u151-linux-x64.rpm
RUN rm jdk-8u151-linux-x64.rpm

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin
# default -> /usr/java/latest， latest -> /usr/java/jdk1.8u151
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java 

###
# download native support
RUN mkdir -p /tmp/native
RUN curl -L https://github.com/sequenceiq/docker-hadoop-build/releases/download/v2.7.1/hadoop-native-64-2.7.1.tgz | tar -xz -C /tmp/native
###
# hadoop
RUN curl -s http://ftp.wayne.edu/apache/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-2.7.4 hadoop

ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
#RUN . $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

RUN mkdir $HADOOP_PREFIX/input
RUN cp $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

# distributed on a 3 machine cluster
ADD core-site.xml.template $HADOOP_PREFIX/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
ADD slaves $HADOOP_PREFIX/etc/hadoop/slaves

ADD mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

ADD my-start-cluster-from-master.sh $HADOOP_PREFIX/
RUN chmod 700 $HADOOP_PREFIX/my-start-cluster-from-master.sh


RUN $HADOOP_PREFIX/bin/hdfs namenode -format
###
# fixing the libhadoop.so like a boss 
# TODO: it seems this 2.7.1 native-lib does not work for 2.7.4
RUN rm -rf /usr/local/hadoop/lib/native
RUN mv /tmp/native /usr/local/hadoop/lib

###
ADD ssh_config /root/.ssh/config 
RUN chmod 600 /root/.ssh/config 
RUN chown root:root /root/.ssh/config 

# # installing supervisord
# RUN yum install -y python-setuptools
# RUN easy_install pip
# RUN curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -o - | python
# RUN pip install supervisor
#
# ADD supervisord.conf /etc/supervisord.conf

#### TODO Add it back 
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh
#### TODO Add it back 
ENV BOOTSTRAP /etc/bootstrap.sh
###
# workingaround docker.io build error
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh
RUN ls -la /usr/local/hadoop/etc/hadoop/*-env.sh

# Create this folder if not exists
RUN mkdir -p $HADOOP_PREFIX/tmp/name

###
# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

# Add script to restart cluster in 3 steps 
ADD restart-hdfs.sh $HADOOP_PREFIX/restart-hdfs.sh

# SSH's requirement on file permission is very picky
RUN chmod 400 /root/.ssh/id_rsa
RUN service sshd start 
# RUN $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root
# RUN service sshd start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -put $HADOOP_PREFIX/etc/hadoop/ input

WORKDIR /usr/local/hadoop

# HDFS Web UIs
# Namenode, dfs.http.address
EXPOSE 50070
# Datanodes, dfs.datanode.http.address
EXPOSE 50075
# Secondarynamenode, dfs.secondary.http.address
EXPOSE 50090
# Backup/Checkpoint node, dfs.backup.http.address
EXPOSE 50105

# MR Web UIs
# Jobracker, mapred.job.tracker.http.address
EXPOSE 50030
# Tasktrackers, mapred.task.tracker.http.address
EXPOSE 50060
# Job tracker
EXPOSE 8088

# HDFS Daemons
# Namenode	fs.defaultFS.	IPC: ClientProtocol	 Filesystem metadata operations
EXPOSE 8020
# Datanode dfs.datanode.address	Custom Hadoop Xceiver: DataNode and DFSClient	DFS data transfer
EXPOSE 50010
# Datanode dfs.datanode.ipc.address	IPC: InterDatanodeProtocol, ClientDatanodeProtocol ClientProtocol	Block metadata operations and recovery
EXPOSE 50020
# Backupnode dfs.backup.address	Same as namenode	HDFS Metadata Operations 
EXPOSE 50100

# ssh
EXPOSE 2122

CMD ["/etc/bootstrap.sh", "-d"] # Run this inside container
