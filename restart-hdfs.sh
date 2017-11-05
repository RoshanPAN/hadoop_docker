#/bin/bash

# 1. Delete data in slave machine01
# 2. Format the namenode
# 3. start cluster using my-start-cluster-from-master.sh 
HADOOP_PREFIX/sbin/stop-all.sh && sleep 10 && \
       ssh machine02 "rm -r $HADOOP_PREFIX/tmp/dfs/data/* && \
       ssh machine03 "rm -r $HADOOP_PREFIX/tmp/dfs/data/* && \
       $HADOOP_PREFIX/bin/hadoop namenode -format && \
       $HADOOP_PREFIX/my-start-cluster-from-master.sh
