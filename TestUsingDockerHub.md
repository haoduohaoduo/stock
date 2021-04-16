
cd ~/WorkSpace/BuEr/
mkdir PythonStockDockerEnv
cd PythonStockDockerEnv
mkdir -p ./data/mariadb/data
docker pull pythonstock/pythonstock:latest
docker pull mariadb:latest

docker run --name mariadb -v ~/WorkSpace/BuEr/PythonStockDockerEnv/data/mariadb/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=mariadb -p 3306:3306 -d mariadb:latest

docker run -itd --link=mariadb --name stock  \
    -v ~/WorkSpace/BuEr/PythonStockDockerEnv/data/notebooks:/data/notebooks \
    -p 8888:8888 \
    -p 6006:6006 \
    -p 9999:9999 \
    -p 8500:8500 \
    -p 9001:9001 \
    pythonstock/pythonstock:latest



http://localhost:9999 web

http://localhost:8888 jupyter

http://localhost:6006 tensorBoard

http://localhost:9001 supervisor