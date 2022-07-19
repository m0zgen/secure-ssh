# Script for Secure SSH

Simple SSH configurator:

* Random port generator or custom port setup
* Disable passwords
* Secure protocol settings
* Yes/No *permit* `root` settings

*Please use this script after clean install system CentOS / Fedora / Debian . Tested and using on CentOS 7/8 / Fedora / Debian 11*

## Usage

Custom ssh port and add custom port to internal `firewalld` zone:

```
/secure-ssh.sh -p 1234 -i
```

Allow root ssh (script default: root logon will disable) logon:

```
./secure-ssh.sh -r
```

Default settings:

* Protocol 2
* PermitRootLogon no
* Random generated port number

Also script show finally message with created parameters:

```
Host <detected host name>
   HostName <detected host IP address>
   port <generated port number>
```