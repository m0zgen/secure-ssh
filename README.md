# Script for Secure SSH

Simple SSH configurator:

* Random port generator or custom port setup
* Disable passwords
* Disable X11 forwarding
* Secure protocol settings
* Session intervals
* Yes/No *permit* `root` settings
* Backup previous `sshd_config`

*Please use this script after clean install system CentOS / Fedora / Debian . Tested and using on CentOS / Fedora / Debian 11*

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
