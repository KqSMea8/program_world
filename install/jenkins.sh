#/bin/bash

source /etc/profile

java -jar jenkins.war --ajp13Port=-1 --httpPort=8082  &

#net start jenkins

#net stop jenkins
