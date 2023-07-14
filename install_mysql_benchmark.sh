wget -qO - https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash ;
sudo apt install -y sysbench ;
sysbench --version ;

mysql -u root -p ;
mysql> CREATE DATABASE sbtest;
mysql> CREATE USER sbtest;
mysql> GRANT ALL PRIVILEGES ON sbtest.* TO 'sbtest'@'localhost' IDENTIFIED BY 'sbtest';
mysql> FLUSH PRIVILEGES;
mysql> EXIT;

sysbench  \
    --mysql-host=127.0.0.1 \
    --mysql-port=3306 \
    --mysql-db=sbtest \
    --mysql-user=sbtest \
    --mysql-password=sbtest \
    --tables=3 \
    --table_size=10000 \
    oltp_common prepare ;

sysbench  \
    --mysql-host=127.0.0.1 \
    --mysql-port=3306 \
    --mysql-db=sbtest \
    --mysql-user=sbtest \
    --mysql-password=sbtest \
    --tables=3 \
    --table_size=10000 \
    --threads=3 \
    --time=10 \
    oltp_read_write run ;
