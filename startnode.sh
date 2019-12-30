#!/usr/bin/env bash
sed -i "s/@HDFS_MASTER_SERVICE@/$HDFS_MASTER_SERVICE/g" $HADOOP_HOME/etc/hadoop/core-site.xml
sed -i "s/@HDOOP_YARN_MASTER@/$HDOOP_YARN_MASTER/g" $HADOOP_HOME/etc/hadoop/yarn-site.xml
yarn-master
HADOOP_NODE="${HADOOP_NODE_TYPE}"
if [ $HADOOP_NODE = "datanode" ]; then
    echo "Start DataNode ..."
    hdfs datanode  -regular
 
else
if [  $HADOOP_NODE = "namenode" ]; then
    echo "Start NameNode ..."
    hdfs namenode
else
    if [ $HADOOP_NODE = "resourceman" ]; then
        echo "Start Yarn Resource Manager ..."
        yarn resourcemanager
    else
 
         if [ $HADOOP_NODE = "yarnnode" ]; then
             echo "Start Yarn Resource Node  ..."
             yarn nodemanager   
         else              
            echo "not recoginized nodetype "
         fi
    fi
fi  
 
fi
