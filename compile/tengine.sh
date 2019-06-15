#!/bin/bash


# 1、安装tengine依赖
yum install -y gcc openssl-devel pcre-devel zlib-devel
# 2、安装配置（自己修改路径，在tengine解压目录下）：
# 预编译
./configure \
--prefix=/opt/module/tengine-2.1.0/ \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx/nginx.pid  \
--lock-path=/var/lock/nginx.lock \
--with-http_ssl_module \
--with-http_flv_module \
--with-http_stub_status_module \
--with-http_gzip_static_module \
--http-client-body-temp-path=/var/tmp/nginx/client/ \
--http-proxy-temp-path=/var/tmp/nginx/proxy/ \
--http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ \
--http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
--http-scgi-temp-path=/var/tmp/nginx/scgi \
--with-pcre
# 编译安装
make && make install






#### Tengine预编译命令

# yum install -y gcc openssl-devel pcre-devel zlib-devel

# ./configure \
# --prefix=/opt/module/tengine-2.1.0/ \
# --error-log-path=/var/log/nginx/error.log \
# --http-log-path=/var/log/nginx/access.log \
# --pid-path=/var/run/nginx/nginx.pid  \
# --lock-path=/var/lock/nginx.lock \
# --with-http_ssl_module \
# --with-http_flv_module \
# --with-http_stub_status_module \
# --with-http_gzip_static_module \
# --http-client-body-temp-path=/var/tmp/nginx/client/ \
# --http-proxy-temp-path=/var/tmp/nginx/proxy/ \
# --http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ \
# --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
# --http-scgi-temp-path=/var/tmp/nginx/scgi \
# --with-pcre


# default_type 'text/html';
# charset utf-8;


# yum -y install chkconfig python bind-utils psmisc libxslt zlib sqlite cyrus-sasl-plain cyrus-sasl-gssapi fuse portmap fuse-libs redhat-lsb
