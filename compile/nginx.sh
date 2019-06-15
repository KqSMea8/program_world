
#!/bin/bash

NGINX_HOME='/opt/module/nginx-1.10.1'

cd $NGINX_HOME
yum install -y gcc gcc-c++ automake pcre pcre-devel zlib zlib-devel openssl openssl-devel
make clean
sudo mkdir $NGINX_HOME/build
./configure --prefix=$NGINX_HOME/build && make && make install

# ./configure --prefix=/usr/local/nginx
# --sbin-path=/usr/local/nginx/sbin/nginx
# --conf-path=/usr/local/nginx/conf/nginx.conf
# --pid-path=/usr/local/nginx/logs/nginx.pid \
# --with-http_ssl_module \
# --with-http_stub_status_module \
# --with-http_gzip_static_module \ 


# 1.安装GCC编译器等工具：
# yum install -y gcc gcc-c++ autoconf automake libtool make openssl openssl-devel pcre pcre-devel
# 2.下载安装Nginx:
# wget http://nginx.org/download/nginx-1.6.3.tar.gz
# 注：这里也可以下载tengine压缩包，比一般nginx多一些功能
# tar -zxvf nginx-1.6.3.tar.gz 
# cd nginx-1.6.3/  
# ./configure --prefix=/usr/local/nginx
# --sbin-path=/usr/local/nginx/sbin/nginx
# --conf-path=/usr/local/nginx/conf/nginx.conf
# --pid-path=/usr/local/nginx/logs/nginx.pid \
# --with-http_ssl_module \
# --with-http_stub_status_module \
# --with-http_gzip_static_module \ 
# make && make install 
# 注：查询"./configure --help"相关模块，按需求指定启用


