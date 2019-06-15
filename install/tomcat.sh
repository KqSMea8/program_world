#!/bin/bash

CATALINA_LOG=/opt/tomcat/apache-tomcat-8.5.9/logs/catalina.out

rm -rf $CATALINA_LOG

sh /opt/tomcat/apache-tomcat-8.5.9/restart.sh

tail -f  $CATALINA_LOG

