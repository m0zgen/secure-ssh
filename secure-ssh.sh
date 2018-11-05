#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Script for simple secure sshd service on CentOS servers
#

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Vars
# -------------------------------------------------------------------------------------------\
SSHD_PORT="2345"
# Random port generator
# cat /dev/urandom | tr -dc '4-5' | fold -w 5 | head -n 1
HOST_NAME=$(hostname)

yum install policycoreutils-python -y


sed -i "s/#Port.*/Port "$SSHD_PORT"/" /etc/ssh/sshd_config
# sed -i 's/#Port.*/Port 2345/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval.*/ClientAliveInterval 60/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax.*/ClientAliveCountMax 60/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config

echo "Protocol 2" >> /etc/ssh/sshd_config

firewall-cmd --add-port=$SSHD_PORT/tcp --permanent
firewall-cmd --reload

semanage port -a -t ssh_port_t -p tcp $SSHD_PORT

systemctl restart sshd

echo -e "Your ~/.ssh/config:\n\n"

echo -e "Host $HOST_NAME\n    HostName $HOST_NAME\n    port $SSHD_PORT"
