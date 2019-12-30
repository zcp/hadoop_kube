#!/bin/bash
#!/bin/bash

master_ip=192.168.10.6
master_hostname=k8s-master
slave1_hostname=worker-6
#slave1_hostname=thinkstation-e32-1
#slave2_hostname=thinkstation-e32-2


nodes=($master_hostname $slave1_hostname)
node_num=${#nodes[@]}
range=`expr $node_num - 1`

password=123456

setLabels(){
   kubectl label nodes ${nodes[0]} diskspeed=k8s-master  --overwrite
   for i in $( eval echo {1..$range} ); do
       node=${nodes[$i]}
       kubectl label nodes $node diskspeed=thinkstation-e32  --overwrite
   done
}

mask_ssh_confirm(){
   #for master
   sudo bash -c 'echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config'
   #for other hosts.
   for i in $( eval echo {1..$range} ); do
       node=${nodes[$i]}
       sudo ssh $node "bash -c 'echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config'"
   done
}


activateDocker(){
   for i in $( eval echo {0..$range} ); do
       node=${nodes[$i]}
       port=${nodes_ports[$i]}
       yes y | sshpass -p $password sudo ssh $node "sudo groupadd docker"
       yes y | sshpass -p $password sudo ssh $node "sudo systemctl start docker.service"
       yes y | sshpass -p $password sudo ssh $node "sudo systemctl enable docker.service"
       #ssh $node "yes y | sudo apt-get install sysstat"
   done
}

activateMaster(){
    sudo swapoff -a
    rm -rf /var/lib/cni/flannel/* && rm -rf /var/lib/cni/networks/cbr0/* && ip link delete cni0  
    rm -rf /var/lib/cni/networks/cni0/*
    yes y | kubeadm reset
    systemctl restart kubelet

    kubeadm init --apiserver-advertise-address=$master_ip --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.13.1 --pod-network-cidr=10.244.0.0/16
    sudo mkdir -p $HOME/.kube
    yes y | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    export kubever=$(kubectl version | base64 | tr -d '\n')
    kubectl apply -f kube-flannel.yml
    #sudo kubectl create -f kube-flannel_eth0.yml 
    #cd /tmp/metrics-server;
    #kubectl create -f deploy/1.8+/
    #cd ..
}

addNodes(){
     join_token=$(kubeadm token create --print-join-command)
     #skip master nodes
     for i in $( eval echo {1..$range} ); do
         node=${nodes[$i]}
         yes y | sshpass -p $password ssh $node "rm -rf /var/lib/cni/flannel/* && rm -rf /var/lib/cni/networks/cbr0/* && ip link delete cni0"
         yes y | sshpass -p $password ssh $node "rm -rf /var/lib/cni/networks/cni0/*"
         yes y | sshpass -p $password ssh $node  "yes y | kubeadm reset; swapoff -a; $join_token"
     done
}

setTimeZone(){
     for i in $( eval echo {0..$range} ); do
        node=${nodes[$i]}
        yes y | sudo ssh $node "sudo timedatectl set-timezone America/New_York"
     done
}

#We have to run the following two commands first to run spark on kubernetes
createSparkAccount(){
   kubectl create serviceaccount spark
   kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=default
}

#mask_ssh_confirm
activateDocker
activateMaster
#setTimeZone
addNodes
createSparkAccount
setLabels
#install_numpy
