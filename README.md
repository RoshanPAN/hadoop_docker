# hadoop_docker
Project to create HDFS distributed cluster with docker images.

# How to use this Docker file

### Setup, Build and Run
- set up login without password in host machine to allow login with `ssh [host_IP]` between all pair of machines.
> A easier way to do this is to use same public/private key, authorized_keys files among all machines. The later on script will copy your hostmachine's ssh related files into their `/root/.ssh/`
- run `prepare_host.sh` in the host machine.
> This step helps to setup ufw for all the ports needed, as well as copy ssh public and private keys into the build context of docker. Then, it will start to build the image and run this image.

### Start the cluster
When the container starts, it will ask you to format the dfs, choose Y to format it.
Then, a bash will be open in the container and you can `cd $HADOOP_PREFIX` into the hdfs folder.
There is a `my-start-cluster-from-master.sh` file, which can help you start the cluster.

# END - Have Fun!
