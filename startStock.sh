#!/bin/bash

PWD=`pwd`

DB_IS_RUN=`docker ps --filter "name=mariadb" --filter "status=running" | wc -l `

if [ $DB_IS_RUN -lt 2 ]; then

    # 判断文件夹存在不。
    if [ ! -d "/data/mysqldb/data" ]; then
        mkdir -p /data/mysqldb/data
    fi

    HAS_DB=`docker images mysql:5.7 | wc -l `
    if [ $HAS_DB -ne 2 ];then
        docker pull mysql:5.7
    fi

    ####################### 启动数据库 #######################
    # 检查mysqldb是否启动
    DB_IS_RUN=`docker ps --filter "name=mysqldb" --filter "status=running" | wc -l `

    if [ $DB_IS_RUN -ne 2 ]; then
        docker run --name mysqldb -v ${PWD}/data/mysqldb/data:/var/lib/mysql --restart=always \
        -e MYSQL_ROOT_PASSWORD=mysqldb -e MYSQL_DATABASE=stock_data -e TZ=Asia/Shanghai \
        -p 3306:3306 -d mysql:5.7
        echo "Starting MySQL DB Server ..."
        echo "Wait 120 second , MySQL DB is starting ."
        sleep 120
    else
        echo "MySQL DB is running !!!"
    fi

    ####################### 创建数据库 #######################
    # 检查mysqldb是否启动，等待5秒钟，再次检查mysqldb启动
    DB_IS_RUN=`docker ps --filter "name=mysqldb" --filter "status=running" | wc -l `
    if [ $DB_IS_RUN -ne 2 ]; then
        echo "MySQL DB is not running !!!"
        exit 1;
    fi
fi

# 检查Stock启动
STOCK_IS_RUN=`docker ps --filter "name=stock" --filter "status=running" | wc -l `
if [ $STOCK_IS_RUN -ge 2 ]; then
    echo "Stop & rm stock ..."
    docker stop stock && docker rm stock
fi

sleep 1

echo "Starting stock ..."
# 1 是开发环境。映射本地代码。
if [ $# == 1 ] ; then
    echo "#############  Developing Mode ############# "
    # /data/stock 是代码目录 -v /data/stock:/data/stock 是开发模式。
    mkdir -p notebooks

    # 测试使用，自己需注册，申请：https://tushare.pro/user/token

    docker run -itd --link=mysqldb --name stock  \
      -e LANG=zh_CN.UTF-8 -e LC_CTYPE=zh_CN.UTF-8 -e PYTHONIOENCODING=utf-8 \
      -e TUSHARE_TOKEN=007b2f24bc3afb5ff5c604b0aee583956840210348169bc2436bddf9 \
      -e MYSQL_HOST=mysqldb \
      -e MYSQL_USER=root \
      -e MYSQL_PWD=mysqldb \
      -e MYSQL_DB=stock_data \
      -p 8888:8888 \
      -p 6006:6006 \
      -p 9999:9999 \
      -p 8500:8500 \
      -p 9001:9001 \
      --restart=always \
      -v ${PWD}/jobs:/data/stock/jobs \
      -v ${PWD}/libs:/data/stock/libs \
      -v ${PWD}/web:/data/stock/web \
      -v ${PWD}/supervisor:/data/supervisor \
      -v ${PWD}/notebooks:/data/notebooks \
      -v ${PWD}/data/logs:/data/logs \
       pythonstock/pythonstock:latest
    exit 1;
else
    echo "#############  Online Mode ############# "
    # /data/stock 是代码目录 -v /data/stock:/data/stock 是开发模式。
    docker run -itd --link=mysqldb --name stock  \
      -p 8888:8888 -p 9999:9999 --restart=always \
       pythonstock/pythonstock:latest
    exit 1;
fi

