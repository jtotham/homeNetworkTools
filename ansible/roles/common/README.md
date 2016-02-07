# Ubuntu

## Description

Installs Ubuntu as per Jon's base requirements.

This role chiefly:

- Installs and configures NTP (see the ntp role)
- Runs the linux harden role
- Installs some useful packages for system administration/monitoring
- Configure resolv.conf
- Adds IPv6 configuration to eth0 in `/etc/network/interfaces`
- Modified gai.conf to prefer IPv4
- Installs ssh keys for the jon user
- Install vmware tools (NOT open-vm-tools)
- Installs and configures SNMPD
- Disables root login over ssh
- Configures sudo for the jon user
- Configures the console resolution

## Variables

| Variable                        | Type | Required          | Description                                             |
| -------------                   | ---  | --------          | -------------                                           |
| snmp_community                  | str  | no                | sets the snmp community in snmpd.conf                   |
| wirehive_support_email          | str  | if snmp_community | used in snmp.conf                                       |
| dns_nameservers                 | list | yes               | list of resolvers                                       |
| ipv6_address                    | str  | no                | eth0 ipv6 address                                       |
| ipv6_netmask                    | str  | if ipv6_address   | eth0 ipv6 netmask                                       |
| ipv6_gateway                    | str  | if ipv6_address   | eth0 ipv6 gateway                                       |
| server_hostname                 | str  | no                | updates hostname and adds to `/etc/hosts`               |
| manage_authorized_keys | bool | no (default true) | if false, do not update user jon's authorized_keys |


## Dependencies

  - yaegashi.blockinfile
  - ntp
  - linux_harden
