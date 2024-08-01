HADOOP_VERSION = 3.3.5-java11
VERSION=1.0.0

buildbase:
	sudo docker build -t hadoop-base-$(HADOOP_VERSION):$(VERSION) ./base

build:  
	sudo docker build -t hadoop-namenode-$(HADOOP_VERSION):$(VERSION) ./namenode
	sudo docker build -t hadoop-datanode-$(HADOOP_VERSION):$(VERSION) ./datanode
	sudo docker build -t hadoop-resourcemanager-$(HADOOP_VERSION):$(VERSION) ./resourcemanager
	sudo docker build -t hadoop-nodemanager-$(HADOOP_VERSION):$(VERSION) ./nodemanager
	sudo docker build -t hadoop-historyserver-$(HADOOP_VERSION):$(VERSION) ./historyserver
