#!/bin/bash

echo -e "\n"

# schematool --initSchema -dbType derby
schematool -dbType postgres --initSchema 

#schematool -info -dbType postgres -userName hive -passWord hive -verbose

echo -e "\n"

hive