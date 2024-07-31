HADOOP_VERSION = 3.3.5-java11
DOCKER_NETWORK = devlab
ENV_FILE = hadoop.env

buildbase:
	sudo docker build -t hadoop-base:$(HADOOP_VERSION) ./base

build:  
	sudo docker build -t hadoop-namenode:$(HADOOP_VERSION) ./namenode
	sudo docker build -t hadoop-datanode:$(HADOOP_VERSION) ./datanode
	sudo docker build -t hadoop-resourcemanager:$(HADOOP_VERSION) ./resourcemanager
	sudo docker build -t hadoop-nodemanager:$(HADOOP_VERSION) ./nodemanager
	sudo docker build -t hadoop-historyserver:$(HADOOP_VERSION) ./historyserver
