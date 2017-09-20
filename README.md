# Apache Hadoop 2.7.1 Docker image

### Open allow the ports used in ufw
run `prepare_host.sh` in the host machine.

### Start the container:
Start the container while publish the port(map to same port on host). Publishing the port helps to map the port inside container to the port in host machine. 
See [Docker Docs](https://docs.docker.com/engine/userguide/networking/#exposing-and-publishing-ports) for more details.
```bash
docker run -it -p 50010:50010 -p 50020:50020 -p 50070:50070 50075:50075 \ 
  50090:50090 8020:8020 9000:9000 10020:10020 19888:19888 \
  8030:8030 8031:8031 8032:8032 8033:8033 8040:8040 8042:8042 8088:8088 \
  49707:49707 2122:2122 \
  sequenceiq/hadoop-docker \
  /etc/bootstrap.sh -bash
  --build-arg cur_hostname=[hostname_host_machine] \
```
