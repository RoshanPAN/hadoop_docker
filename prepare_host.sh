# Run this Script in the folder contains docker file

# Allow ports in firewall
# Hdfs ports
ufw allow 50010 && ufw allow 50020 && ufw allow 50075 && ufw allow 50070 && ufw allow 50090 \
  && ufw allow 8020 && ufw allow 9000 
# Mapred ports
ufw allow 10020 && ufw allow 19888
# Yarn ports
ufw allow 8030 && ufw allow 8031 && ufw allow 8033 && ufw allow 8040 \
  && ufw allow 8042 && ufw allow 8088 
# 2122 = sshd, 
ufw allow 49707 && ufw allow 2122


# Build Docker Image && Create Contrainer from Image
docker build -t="pls331/centos:distributed" .
docker run -it --net=host \
  -p 50070:50070 -p 50075:50075 -p 50090:50090 -p 50105:50105 \
  -p 50030:50030 -p 50060:50060 -p 8020:8020 -p 50010:50010 \
  -p 50020:50020 -p 50100:50100 \
  -p 2122:2122 \
  pls331/centos:distributed /etc/bootstrap.sh -bash
