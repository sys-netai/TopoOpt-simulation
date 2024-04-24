

IMAGE=wxcsky/dnnsim:v0
NAME="--name topoopt-container_1"
DIR_MAPPING=" --volume /home/xinchen/TopoOpt-simulation:/TopoOpt-simulation"
docker run -it --gpus all $NAME $DIR_MAPPING $IMAGE

# #!/bin/bash

# #set -eu -o pipefail
# IF_PREFIX="eno"

# if [ $UID -ne 0 ]; then
# 	echo "please execute this script as root" exit 1
# fi

# function create_docker_network() {
# 	DEV=$1
# 	NAME=$2

# 	docker network ls | grep $NAME 2>&1 >/dev/null
# 	if [ $? -eq 0 ]; then
# 		echo $NAME network has been created
# 		return 0
# 	fi

# 	echo "This may take several seconds, please wait..."

# 	SUBNET=$(ip a show $DEV | grep 'inet ' | awk '{print $2}')
# 	GW=$(ip r | grep $DEV | grep via | awk '{print $3}')

# 	echo $DEV, $NAME, $SUBNET, $GW

# 	docker network create -d sriov --subnet=$SUBNET -o netdevice=$DEV -o prefix=$IF_PREFIX $NAME
# 	num_vfs=$(cat /sys/class/net/$DEV/device/sriov_numvfs)
# 	for ((i = 0; i < $num_vfs; i++)); do
# 		# set speed to 10Gbps
# 		sudo ip link set $DEV vf $i trust on
# 		sudo ip link set $DEV vf $i max_tx_rate 10000 min_tx_rate 10000
# 	done
# }

# IMAGE=topoopt-sim
# DIR_MAPPING=" --volume /data/glusterfs/project/TopoOpt:/TopoOpt"
# SSH_PORT=22

# function create_container() {
# 	DEV=$1
# 	NET_NAME=$2
# 	CONTAINER_NAME=$3
# 	GPU_ID=$4
# 	POST_FIX=$5
# 	GW=$(ip r | grep $DEV | grep via | awk '{print $3}')
# 	if [ $GPU_ID = 'server' ]; then
# 		IP=$(echo $GW | awk 'BEGIN{FS="."}{print $1 "." $2 "." $3}')
# 		IP="$IP.$POST_FIX"
# 		HOST=$(echo $GW | awk 'BEGIN{FS="."}{print $1 "-" $2 "-" $3}')
# 		HOST="$HOST-$POST_FIX"
# 	else
# 		IP=$(echo $GW | awk 'BEGIN{FS="."}{print $1 "." $2 "." $3}')
# 		IP="$IP.$POST_FIX"
# 		HOST=$(echo $GW | awk 'BEGIN{FS="."}{print $1 "-" $2 "-" $3}')
# 		HOST="$HOST-$POST_FIX"
# 	fi

# 	echo "conatiner: $CONTAINER_NAME, IP: $IP"

# 	if [ $GPU_ID = 'server' ]; then
# 		docker_rdma_sriov run -it -d --name=$CONTAINER_NAME $DIR_MAPPING --hostname=$HOST --net=$NET_NAME --ip=$IP --runtime=nvidia --ulimit memlock=-1 --shm-size=65536m --cap-add=IPC_LOCK --cap-add SYS_NICE --cap-add=NET_ADMIN --device=/dev/infiniband $IMAGE /usr/sbin/sshd -D -p $SSH_PORT
# 	else
# 		docker_rdma_sriov run -it -d --name=$CONTAINER_NAME $DIR_MAPPING --hostname=$HOST --net=$NET_NAME --ip=$IP --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=$GPU_ID --ulimit memlock=-1 --shm-size=65536m --cap-add=IPC_LOCK --cap-add SYS_NICE --cap-add=NET_ADMIN --device=/dev/infiniband $IMAGE /usr/sbin/sshd -D -p $SSH_PORT
# 	fi
# 	pid=$(sudo docker inspect -f '{{.State.Pid}}' $CONTAINER_NAME)
# 	nsenter -t $pid -n ip route add 10.0.0.0/8 dev "${IF_PREFIX}0" via $GW
# 	nsenter -t $pid -n ip link set "${IF_PREFIX}0" mtu 1500

# 	#mkdir -p /var/run/netns
# 	#ln -s /proc/$pid/ns/net /var/run/netns/$pid
# 	#ip netns exec $pid ip route add 10.0.0.0/8 dev eth0 via $GW

# 	#docker exec -it $CONTAINER_NAME ip route add 10.0.0.0/8 dev eth0 via $GW

# 	docker network connect bridge $CONTAINER_NAME

# 	# inspect
# 	docker exec -it "$CONTAINER_NAME" ip addr
# 	docker exec -it $CONTAINER_NAME ip route
# }

# create_docker_network rdma0 nd0

# create_container rdma0 nd0 TopoOpt-sim 0 210
