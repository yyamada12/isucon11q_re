#!/bin/bash

set -eux

date -R
echo "Started deploying."

# rotate logs
function rotate_log () {
  if sudo [ -e $1 ]; then
    sudo mv $1 ${1%.*}_$(date +"%Y%m%d%H%M%S").${1##*.}
  fi
}
rotate_log /var/log/nginx/access.log
rotate_log /var/log/mysql/slow.log
rotate_log ~/pprof/pprof.png


# build go app
cd /home/isucon/webapp/go
go build -o isucondition

# update 50-server.cnf
if [ -e ~/etc/50-server.cnf ]; then
  sudo cp ~/etc/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
fi

# restart services
sudo systemctl restart mysql
sudo systemctl restart isucondition.go
sudo systemctl restart nginx

date -R
echo "Finished deploying."
