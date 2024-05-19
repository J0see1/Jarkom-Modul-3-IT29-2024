# Chani

apt-get update
apt-get install mariadb-server -y
service mysql start

mysql -e "CREATE USER 'it29'@'%' IDENTIFIED BY 'passwordit29';"
mysql -e "CREATE USER 'it29'@'atreides.it29.com' IDENTIFIED BY 'passwordit29';"
mysql -e "CREATE DATABASE DBIT29;"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'it29'@'%';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'it29'@'atreides.it29.com';"
mysql -e "FLUSH PRIVILEGES;"

mysql="[mysqld]
skip-networking=0
skip-bind-address
"
echo "$mysql" > /etc/mysql/my.cnf

echo -e '[server]

[mysqld]

user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
socket                  = /run/mysqld/mysqld.sock
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql

bind-address            = 0.0.0.0

query_cache_size        = 16M

log_error = /var/log/mysql/error.log

expire_logs_days        = 10

character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci

[embedded]

[mariadb]

[mariadb-10.3]' > /etc/mysql/mariadb.conf.d/50-server.cnf

service mysql restart

# Laravel Worker

apt-get update
apt-get install mariadb-client -y