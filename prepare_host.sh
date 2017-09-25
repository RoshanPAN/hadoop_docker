# Run this Script in the folder contains docker file

# Allow ports in firewall
# HDFS Web UIs
# Namenode, dfs.http.address
ufw allow 50070
# Datanodes, dfs.datanode.http.address
ufw allow 50075
# Secondarynamenode, dfs.secondary.http.address
ufw allow 50090
# Backup/Checkpoint node, dfs.backup.http.address
ufw allow 50105

# MR Web UIs
# Jobracker, mapred.job.tracker.http.address
ufw allow 50030
# Tasktrackers, mapred.task.tracker.http.address
ufw allow 50060

# HDFS Daemons
# Namenode	fs.defaultFS.	IPC: ClientProtocol	 Filesystem metadata operations
ufw allow 8020
# Datanode dfs.datanode.address	Custom Hadoop Xceiver: DataNode and DFSClient	DFS data transfer
ufw allow 50010
# Datanode dfs.datanode.ipc.address	IPC: InterDatanodeProtocol, ClientDatanodeProtocol ClientProtocol	Block metadata operations and recovery
ufw allow 50020
# Backupnode dfs.backup.address	Same as namenode	HDFS Metadata Operations 
ufw allow 50100

# ssh
ufw allow 2122

# Build Docker Image && Create Contrainer from Image
docker build -t="pls331/centos:distributed" .
docker run -it --net=host \
  -p 50070:50070 -p 50075:50075 -p 50090:50090 -p 50105:50105 \
  -p 50030:50030 -p 50060:50060 -p 8020:8020 -p 50010:50010 \
  -p 50020:50020 -p 50100:50100 \
  -p 2122:2122 \
  pls331/centos:distributed /etc/bootstrap.sh -bash
