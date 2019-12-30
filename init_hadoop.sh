#!/bin/bash
#test the hadoop cluster by running wordcount

# create input files 
master_hostname=hadoop_master
slave1_hostname=hadoop_slave1
slave2_hostname=hadoop_slave2

nodes=($master_hostname $slave1_hostname $slave2_hostname)
node_num=${#nodes[@]}
range=`expr $node_num - 1`

password=123456

kubectl cp /etc/hosts $node:/etc/hosts


