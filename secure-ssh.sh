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
HOST_NAME=$(hostname)
SRV_IP=$(hostname -I | cut -d' ' -f1)
BACKUPS=$SCRIPT_PATH/backups

# If root / sudoer user
if ((EUID != 0)); then
    echo "Root or Sudo  Required for script ( $(basename $0) )"
    exit 1
fi

# Help information
usage() {

	echo -e "\nArguments:
	-i (internal firewalld zone)
	-r (allow root logon)
	-a (allow passwords)
	-p (custom port)\n"
	exit 1

}

# Checks arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--internal) _INTERNAL=1; ;;
        -r|--root) _ROOT=1; ;;
        -a|--allowp) _ALLOWP=1; ;;
        -p|--port) _PORT=1 _PORT_NUMBER="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Set port number
if [[ "$_PORT" -eq "1" ]]; then
	SSHD_PORT=$_PORT_NUMBER
else
	SSHD_PORT=$(shuf -i 40000-50000 -n 1)
fi

restrict_root() {
	sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
	sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
}

permit_root() {
	sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
	sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
}

restrict_passwords() {
	sed -i -E 's/(^|#)PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
}

permit_passwords() {
	sed -i -E 's/(^|#)PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
}

update_ssd_config() {

	if [[ ! -d "$BACKUPS" ]]; then
		mkdir -p $BACKUPS
	fi

	# Backup sshd_config
	local BACKUP_CONFIG=$BACKUPS/sshd_config_$(date +"%Y_%m_%dT%H_%M_%S")
	cp /etc/ssh/sshd_config "${BACKUP_CONFIG}"

	sed -i "s/#Port.*/Port "$SSHD_PORT"/" /etc/ssh/sshd_config
	
	if [[ "$_ROOT" -eq "1" ]]; then
		echo "Root ssh logon is allowed"
		permit_root
	else
		restrict_root
	fi

	if [[ "$_ALLOWP" -eq "1" ]]; then
		echo "Using passwords is allowed"
		permit_passwords
	else
		restrict_passwords
	fi
	
	# RHEL / Debian
	# sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
	sed -i 's/#ClientAliveInterval.*/ClientAliveInterval 60/' /etc/ssh/sshd_config
	sed -i 's/#ClientAliveCountMax.*/ClientAliveCountMax 60/' /etc/ssh/sshd_config
	sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
	
	sed -i 's/^X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config

	sed -i '/^Protocol/d' /etc/ssh/sshd_config
	echo "Protocol 2" >> /etc/ssh/sshd_config

	systemctl restart sshd

	echo "Done. Backup saved to: ${BACKUP_CONFIG}"
}

set_firewall() {

	if [[ "$_INTERNAL" -eq "1" ]]; then
		firewall-cmd --add-port=$SSHD_PORT/tcp --permanent --zone=internal
		firewall-cmd --reload
	else
		firewall-cmd --add-port=$SSHD_PORT/tcp --permanent
		firewall-cmd --reload
	fi
}

check_endpoint() {
	if [ $(which yum) ]; then

		# Selinux support
		yum install policycoreutils-python -y
		set_firewall
		semanage port -a -t ssh_port_t -p tcp $SSHD_PORT

	elif [ $(which apt) ]; then
		
		if command -v ufw &> /dev/null
		then
		    ufw allow $SSHD_PORT
		elif command -v firewall-cmd &> /dev/null
		then
			set_firewall
		else
			echo "Firewall does not found. Please add $SSHD_PORT manually."
	    	exit 1
		fi

	fi
}

finality() {
	
	echo -e "Your ~/.ssh/config:\n"
	echo -e "Host $HOST_NAME\n   HostName $SRV_IP\n   port $SSHD_PORT"
	echo -e "\nIf you will see Many auth error, please use IdentitiesOnly options\as example: ssh -o IdentitiesOnly=yes -p $SSHD_PORT user@$SRV_IP"

}

# Action
# -------------------------------------------------------------------------------------------\
check_endpoint
update_ssd_config
finality
