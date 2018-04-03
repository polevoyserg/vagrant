#!/bin/bash

usermod -u $(ls -ldn /vagrant | awk '{print $3}') www-data
groupmod -g $(ls -ldn /vagrant | awk '{print $3}') www-data
service haproxy restart
exec supervisord -n
