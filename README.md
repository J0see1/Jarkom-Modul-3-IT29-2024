# Praktikum-Jarkom-Modul-3

# Anggota

| Nama                            | NRP          |
| ------------------------------- | ------------ |
| Marcelinus Alvinanda Chrisantya | `5027221012` |
| Bintang Ryan Wardana            | `5027221022` |


# Setup Topologi

Arakis - Router (DHCP Relay)

```
auto eth0
iface eth0 inet dhcp
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.78.0.0/16

auto eth1
iface eth1 inet static
	address 10.78.1.1
	netmask 255.255.255.0

auto eth2
iface eth2 inet static
	address 10.78.2.1
	netmask 255.255.255.0

auto eth3
iface eth3 inet static
	address 10.78.3.1
	netmask 255.255.255.0

auto eth4
iface eth4 inet static
	address 10.78.4.1
	netmask 255.255.255.0
```

### Switch 1

Dmitri - Client

```
auto eth0
iface eth0 inet dhcp
```

Vladimir - PHP Worker

```
auto eth0
iface eth0 inet static
	address 10.78.1.3
	netmask 255.255.255.0
	gateway 10.78.1.1
```

Rabban - PHP Worker

```
auto eth0
iface eth0 inet static
	address 10.78.1.4
	netmask 255.255.255.0
	gateway 10.78.1.1
```

Feyd - PHP Worker

```
auto eth0
iface eth0 inet static
	address 10.78.1.5
	netmask 255.255.255.0
	gateway 10.78.1.1
```

### Switch 2

Paul - Client

```
auto eth0
iface eth0 inet dhcp
```

Leto - Laravel Worker

```
auto eth0
iface eth0 inet static
	address 10.78.2.3
	netmask 255.255.255.0
	gateway 10.78.2.1
```

Duncan - Laravel Worker

```
auto eth0
iface eth0 inet static
	address 10.78.2.4
	netmask 255.255.255.0
	gateway 10.78.2.1
```

Jessica - Laravel Worker

```
auto eth0
iface eth0 inet static
	address 10.78.2.5
	netmask 255.255.255.0
	gateway 10.78.2.1
```

### Switch 3

Irulan - DNS Server

```
auto eth0
iface eth0 inet static
	address 10.78.3.2
	netmask 255.255.255.0
	gateway 10.78.3.1
```


Mohiam - DHCP Server

```
auto eth0
iface eth0 inet static
	address 10.78.3.3
	netmask 255.255.255.0
	gateway 10.78.3.1
```

### Switch 4

Chani - Database Server

```
auto eth0
iface eth0 inet static
	address 10.78.4.3
	netmask 255.255.255.0
	gateway 10.78.4.1
```

Stilgar - Load Balancer 

```
auto eth0
iface eth0 inet static
	address 10.78.4.2
	netmask 255.255.255.0
	gateway 10.78.4.1
```

# 0. Konfigurasi Node

## Arakis 

```
apt-get update
apt-get install isc-dhcp-relay -y
```

## Irulan

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf

apt-get update
apt install bind9 -y

echo -e "options {
directory \"/var/cache/bind\";
forwarders {
           192.168.122.1;
};

allow-query{any;};
listen-on-v6 { any; };
};" > /etc/bind/named.conf.options

echo -e "zone \"atreides.it29.com\" {
        type master;
        file \"/etc/bind/jarkom/atreides.it29.com\";
};

zone \"harkonen.it29.it29.com\" {
        type master;
        file \"/etc/bind/jarkom/harkonen.it29.com\";
};" > /etc/bind/named.conf.local

mkdir /etc/bind/jarkom

echo -e ";
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     harkonen.it29.com. root.harkonen.it29.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
;
@       IN      NS      harkonen.it29.com.
@       IN      A       10.78.1.3" > /etc/bind/jarkom/harkonen.it29.com

echo -e ";
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     atreides.it29.com. root.atreides.it29.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      atreides.it29.com.
@       IN      A       10.78.2.3" > /etc/bind/jarkom/altreides.it29.com

service bind9 restart                    
```

# 1. Client