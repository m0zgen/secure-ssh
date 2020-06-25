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
# Random port generator
SSHD_PORT=$(shuf -i 40000-50000 -n 1)
HOST_NAME=$(hostname)
SRV_IP=$(hostname -I | cut -d' ' -f1)

if ((EUID != 0)); then
    echo "Root or Sudo  Required for script ( $(basename $0) )"
    exit 1
fi

if [ $(which yum) ]; then

	# Selinux support
	yum install policycoreutils-python -y
	firewall-cmd --add-port=$SSHD_PORT/tcp --permanent
	firewall-cmd --reload
	semanage port -a -t ssh_port_t -p tcp $SSHD_PORT

elif [ $(which apt) ]; then
	ufw allow $SSHD_PORT
fi

# Backup sshd_config
cp /etc/ssh/sshd_config $SCRIPT_PATH

sed -i "s/#Port.*/Port "$SSHD_PORT"/" /etc/ssh/sshd_config
# sed -i 's/#Port.*/Port 2345/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
# CentOS 8 (uncommented parameter)
sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval.*/ClientAliveInterval 60/' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax.*/ClientAliveCountMax 60/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config

echo "Protocol 2" >> /etc/ssh/sshd_config

systemctl restart sshd

# Echo's
# -------------------------------------------------------------------------------------------\
echo -e "Your ~/.ssh/config:\n"
echo -e "Host $HOST_NAME\n   HostName $SRV_IP\n   port $SSHD_PORT"
echo -e "\nIf you will see Many auth error, please use IdentitiesOnly options\as example: ssh -o IdentitiesOnly=yes -p $SSHD_PORT user@$SRV_IP"
