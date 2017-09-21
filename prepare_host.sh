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


# Build Docker Image
docker build -t="pls331/centos:psuedo-distributed" .

# Create Contrainer from Image
docker run -it -p 50010:50010 -p 2122:2122 -p 50070:50070 pls331/centos:psuedo-distributed /etc/bootstrap.sh -bash
