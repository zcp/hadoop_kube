#!/bin/bash
#test the hadoop cluster by running wordcount

# create input files 
mkdir input
echo "Hello Docker" >input/file2.txt
echo "Hello Hadoop" >input/file1.txt

# create input directory on HDFS
hadoop fs -mkdir -p input

# put input files to HDFS
hdfs dfs -put ./input/* input

# show these files
hdfs dfs -ls input

# read these files
hdfs dfs -cat input/file2.txt
hdfs dfs -cat input/file1.txt

# run wordcount 
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/sources/hadoop-mapreduce-examples-2.9.2-sources.jar org.apache.hadoop.examples.WordCount input output

# print the input files
echo -e "\ninput file1.txt:"
hdfs dfs -cat input/file1.txt

echo -e "\ninput file2.txt:"
hdfs dfs -cat input/file2.txt

# print the output of wordcount
echo -e "\nwordcount output:"
hdfs dfs -cat output/part-r-00000

# get output file to local filesystem
hdfs dfs -get output/part-r-00000
#check
ls

# place output file to a specific directory
hdfs dfs -copyToLocal output/part-r-00000 /tmp
#check
ls



