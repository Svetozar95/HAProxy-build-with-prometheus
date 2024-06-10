FROM oraclelinux:8

RUN dnf install -y gcc gcc-c++ make readline-devel nc net-tools wget pcre-devel openssl-devel ruby-devel rpm-build

# Разрешить переключение потоков модулей 
RUN sed -i 's/^module_stream_switch_disabled/module_stream_switch_enabled/' /etc/dnf/dnf.conf


# Скачивание и компиляция Lua
ENV LUA_VERSION=5.4.4
RUN wget https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz && \
    tar -zxf lua-${LUA_VERSION}.tar.gz && \
    cd lua-${LUA_VERSION} && \
    make linux && \
    make install

ENV LUA_INC=/usr/local/include
ENV LUA_LIB=/usr/local/lib

# Установка systemd-devel для сборки HAProxy с systemd
RUN dnf install -y systemd-devel
RUN mkdir RPMS
RUN chmod -R 777 RPMS

WORKDIR /opt/haproxy

#RUN wget http://www.haproxy.org/download/2.4/src/haproxy-2.4.6.tar.gz && \
#    tar -zxf haproxy-2.4.6.tar.gz && \
RUN wget https://www.haproxy.org/download/3.0/src/haproxy-3.0.0.tar.gz && \ 
    tar -xzf haproxy-3.0.0.tar.gz && \
    cd haproxy-3.0.0 && \
    make TARGET=linux-glibc USE_OPENSSL=1 USE_ZLIB=1 USE_PCRE=1 USE_SYSTEMD=1 USE_PROMEX=1 USE_LUA=1 LUA_INC="${LUA_INC}" LUA_LIB="${LUA_LIB}" && \
    strip haproxy  && \
    cp -r /opt/haproxy/* /RPMS


