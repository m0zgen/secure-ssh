# Script for Secure SSH

Secure SSH configuring:

* Random port generator or custom port setup or you can set static port number with (`-p`)
* Disable passwords or allow passwords with (`-a`)
* Yes/No *permit* `root` settings (`-r`)
* Allow port to internal Firewalld zone (`-i`)
* Disable X11 forwarding
* Secure protocol settings
* Session intervals
* Backup previous `sshd_config`

*Please use this script after clean install system CentOS / Fedora / Debian . Tested and using on CentOS / Fedora / Debian 11*

*Note:* Script *disable* PasswordAuthentication, before script usage, setup [key authentication](https://sys-adm.in/systadm/nix/454-connect-remote-server-with-rsa-key.html) (one more [link](https://www.ibm.com/docs/en/sia?topic=kbaula-enabling-rsa-key-based-authentication-unix-linux-operating-systems-2)) please.

## Usage

Custom ssh port and add custom port to internal `firewalld` zone:

```
/secure-ssh.sh -p 1234 -i
```

Allow root ssh (script default: root logon will disable) logon:

```
./secure-ssh.sh -r
```

## Defaults

* PermitRootLogin no
* PermitEmptyPasswords no
* PasswordAuthentication no
* ClientAliveInterval 60
* ClientAliveCountMax 60
* X11Forwarding no
* Protocol 2
* Random generated port number between range: 40000-50000

Also script show finally message with created parameters:

```
Host <detected host name>
   HostName <detected host IP address>
   port <generated port number>
```
