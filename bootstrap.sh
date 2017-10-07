#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

# Add IP-Host mapping into /etc/Hosts
echo "164.107.119.20      machine01" >> /etc/hosts
echo "164.107.119.21      machine02" >> /etc/hosts
echo "164.107.119.22      machine03" >> /etc/hosts

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
# sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

# create $HADOOP_PREFIX/tmp/dfs/name folder if not exists
mkdir -p $HADOOP_PREFIX/tmp/dfs/name

# format namenode during run time
$HADOOP_PREFIX/bin/hdfs namenode -format

service sshd start

# Better to start HDFS manually, since it's not on the same machine any more.
# use my-start-cluster-from-master.sh on master
$HADOOP_PREFIX/my-start-cluster-from-master.sh


if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
