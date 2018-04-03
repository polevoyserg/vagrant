#!/bin/bash

if [ -f /.mysql_admin_created ]; then
    echo "MySQL 'admin' user already created!"
    exit 0
fi

/usr/bin/mysqld_safe > /dev/null 2>&1 &

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done
service haproxy restart
echo "=> Creating MySQL admin user with ${_word} password"
mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
mysql -uroot -e "create database \`database\`;"
mysql -uroot -e "grant usage on *.* to myadmin@localhost identified by 'myadmin';"
mysql -uroot -e "grant all privileges on \`database\`.* to myadmin@localhost;"
mysql -uroot -e "flush privileges;"

mysqladmin -uroot shutdown

echo "=> Done!"
touch /.mysql_admin_created

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"
