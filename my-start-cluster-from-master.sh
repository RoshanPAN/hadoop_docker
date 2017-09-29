# Run it on master (namenode) in $HADOOP_PREFIX/etc/hadoop/
# Better to start HDFS manually, since it's not on the same machine any more.
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver
