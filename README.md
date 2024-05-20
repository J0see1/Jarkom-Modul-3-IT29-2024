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

zone \"harkonen.it29.com\" {
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
@       IN      A       10.78.2.3" > /etc/bind/jarkom/atreides.it29.com

service bind9 restart                    
```

# Soal 1-5
- Kemudian, karena masih banyak spice yang harus dikumpulkan, bantulah para aterides untuk bersaing dengan harkonen dengan kriteria berikut.:
Semua CLIENT harus menggunakan konfigurasi dari DHCP Server.
- Client yang melalui House Harkonen mendapatkan range IP dari [prefix IP].1.14 - [prefix IP].1.28 dan [prefix IP].1.49 - [prefix IP].1.70 (2)
- Client yang melalui House Atreides mendapatkan range IP dari [prefix IP].2.15 - [prefix IP].2.25 dan [prefix IP].2 .200 - [prefix IP].2.210 (3)
- Client mendapatkan DNS dari Princess Irulan dan dapat terhubung dengan internet melalui DNS tersebut (4)
- Durasi DHCP server meminjamkan alamat IP kepada Client yang melalui House Harkonen selama 5 menit sedangkan pada client yang melalui House Atreides selama 20 menit. Dengan waktu maksimal dialokasikan untuk peminjaman alamat IP selama 87 menit (5)
*house == switch

Menambahkan konfigurasi pada script.sh Arakis :
```
apt-get update
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start

echo -e
'SERVERS="10.78.3.3" #IP DHCP Mohiam
INTERFACES="eth1 eth2 eth3"
OPTIONS=' > /etc/default/isc-dhcp-relay
```

Jalankan script ini pada DNS server :
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

zone \"harkonen.it29.com\" {
        type master;
        file \"/etc/bind/jarkom/harkonen.it29.com\";
};" > /etc/bind/named.conf.local

mkdir /etc/bind/jarkom

echo -e "
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     harkonen.it29.com. root.harkonen.it29.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      harkonen.it29.com.
@       IN      A       10.78.1.3" > /etc/bind/jarkom/harkonen.it29.com

echo -e ";
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     atreides.it29.com. root.atreides.it29.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      atreides.it29.com.
@       IN      A       10.78.2.3" > /etc/bind/jarkom/atreides.it29.com

service bind9 restart
```

Jalankan script ini pada DHCP Server (Mohiam) :
```
echo 'nameserver 192.168.122.1' > /etc/resolv.conf

apt-get update 
apt-get install isc-dhcp-server

echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

echo '
subnet 10.78.3.0 netmask 255.255.255.0 {}

# Harkonen
subnet 10.78.1.0 netmask 255.255.255.0 {
    range 10.78.1.14 10.78.1.28;
    range 10.78.1.49 10.78.1.70;
    option routers 10.78.1.1;
    option broadcast-address 10.78.1.255;
    option domain-name-servers 10.78.3.2;
    default-lease-time 300;
    max-lease-time 5220;
}

subnet 10.78.2.0 netmask 255.255.255.0 {
    range 10.78.2.15 10.78.2.25;
    range 10.78.2.200 10.78.2.210;
    option routers 10.78.2.1;
    option broadcast-address 10.78.2.255;
    option domain-name-servers 10.78.3.2;
    default-lease-time '1200';
    max-lease-time '5220';
}
' > /etc/dhcp/dhcpd.conf
```

Sebelum menyalakan node client, lakukan command berikut pada Arakis(DHCP Relay)
```
service isc-dhcp-relay restart
```
Kemudian pada Mohiam :
```
service isc-dhcp-server restart
```

<h3>Output :</h3>
- service isc-dhcp-relay restart
  
![1](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/0b04aaf1-b779-4612-999d-8b81e3130fc8)

- Start node client (Paul & Dmitri), ketika client dimulai maka client akan mengirim request ke DHCP Server dan akan mendapatkan IP Address seperti gambar berikut : 
  
  ![2](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/efcfb3ae-8c6e-4b4f-a269-cc619ecb9f3e)
![3](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/fb62836c-606d-4d4a-8946-89f4cb89eec3)

- ping atreides.it29.com & ping harkonen.it29.com
  
![0](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/33e7c8ea-2df7-477f-84e1-4c72bcff9ab3)

# Soal 6
Vladimir Harkonen memerintahkan setiap worker(harkonen) PHP, untuk melakukan konfigurasi virtual host untuk website berikut dengan menggunakan php 7.3.

Kita buat config di ketiga worker PHP di '/root/.bashrc' :
```
echo nameserver 10.78.3.2 > /etc/resolv.conf

apt-get update
apt-get install nginx -y
apt-get install lynx -y
apt-get install php php-fpm -y
apt-get install wget -y
apt-get install unzip -y
service nginx start
service php7.3-fpm start

wget -O '/var/www/harkonen.it29.com' 'https://drive.usercontent.google.com/u/0/uc?id=1lmnXJUbyx1JDt2OA5z_1dEowxozfkn30&export=download'
unzip -o /var/www/harkonen.it29.com -d /var/www/
rm /var/www/harkonen.it29.com
mv /var/www/modul-3 /var/www/harkonen.it29.com

source /root/script.sh
```

Kemudian buat script.sh di PHP worker /root/script.sh:
```
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/harkonen.it29.com
ln -s /etc/nginx/sites-available/harkonen.it29.com /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

echo 'server {
     listen 80;
     server_name _;

     root /var/www/harkonen.it29.com;
     index index.php index.html index.htm;

     location / {
         try_files $uri $uri/ /index.php?$query_string;
     }

     location ~ \.php$ {
         include snippets/fastcgi-php.conf;
         fastcgi_pass unix:/run/php/php7.3-fpm.sock;
         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
         include fastcgi_params;
     }
 }' > /etc/nginx/sites-available/harkonen.it29.com

 service nginx restart
```

Kemudian kita run yang di '/root/.bashrc' tadi, kemudian run yang 'script.sh', `lynx localhost` Worker PHP :

![0](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/b6126817-9b1c-4952-836a-d638fdbd2554)

# Soal 7 
Aturlah agar Stilgar dari fremen dapat dapat bekerja sama dengan maksimal, lalu lakukan testing dengan 5000 request dan 150 request/second.

Pertama, ubah IP Address pada zone harkonen.it29.com agar mengarah ke Stilgar :
```
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     harkonen.it29.com. root.harkonen.it29.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      harkonen.it29.com.
@       IN      A       10.78.4.2 # IP Stilgar
```
Kemudian, jalankan command berikut pada Irulan :
```
service bind9 stop
service bind9 restart
```
Jalankan script di path `/root/.bashrc` pada Load Balancer Stilgar :
```
echo "nameserver 10.78.3.2" > /etc/resolv.conf

apt-get update
apt-get install apache2-utils -y
apt-get install nginx -y
apt-get install lynx -y

service nginx start

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/lb_php

echo ' 
upstream worker { #(round-robin(default), least_conn, ip_hash, hash $request_uri consistent)
#    hash $request_uri consistent;
#    least_conn;
#    ip_hash;
    server 10.78.1.3;
    server 10.78.1.4;
    server 10.78.1.5;
}

server {
    listen 80;
    server_name harkonen.it29.com www.harkonen.it29.com;

    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        proxy_pass http://worker;
    }
} ' > /etc/nginx/sites-available/lb_php

ln -sf /etc/nginx/sites-available/lb_php /etc/nginx/sites-enabled/

if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi


service nginx restart
```
Tambahkan config pada client sebelum melakukan load testing :
```
apt update
apt install lynx -y
apt install htop -y
apt install apache2-utils -y
apt-get install jq -y
```
Setelah itu, kita dapat melakukan load testing terhadap harkonen.it29.com pada kedua client Dmitri dan Paul dengan 5000 request dan 150 request/second : 
```
ab -n 5000 -c 150 http://harkonen.it29.com/
```
Berikut adalah hasil load testing :
![image](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/36fb0856-19a6-4f57-9e7d-41ca3e9133d5)

# Soal 8 
Karena diminta untuk menuliskan peta tercepat menuju spice, buatlah analisis hasil testing dengan 500 request dan 50 request/second masing-masing algoritma Load Balancer dengan ketentuan sebagai berikut:<br>
a. Nama Algoritma Load Balancer
b. Report hasil testing pada Apache Benchmark<br>
c. Grafik request per second untuk masing masing algoritma.<br>
d. Analisis<br>

Sebelum melakukan load testing, kita dapat mengatur Algoritma apa yang ingin digunakan pada konfigurasi Stilgar, dapat dilakukan dengan meng-uncomment salah satu algoritma :
```
upstream worker { #(round-robin(default), least_conn, ip_hash, hash $request_uri consistent) 
#    hash $request_uri consistent;
#    least_conn;
#    ip_hash;
    server 10.78.1.3;
    server 10.78.1.4;
    server 10.78.1.5;
}
```
Jika uncomment least_conn maka algortima yang digunakan adalah Least Connection, sementara jika tidak ada meng-uncomment satupun maka algoritma yang digunakan sesuai dengan default yaitu Round Robin.

Seteleh memilih algoritma, maka lakukan load testing dengan menjalankan command berikut pada client 
`ab -n 500 -c 50 http://harkonen.it19.com/`

**Berikut adalah report hasil testing pada Apache Benchmark untuk setiap Algoritma** 
- Round Roubin :
![round_robin](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/2f390143-ee21-4c36-bbaa-bb7e920ad4b4)

- Least Connection :
![least_conn](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/a0a1e22c-f23c-484b-957f-1f0f66342330)

- Ip Hash :
![ip_hash](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/66a74f58-c2da-4ce6-9783-816798f94c87)

- Generic Hash :
![generic_hash](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/28858ead-7afe-47df-adb7-2cd9125b18d1)

- Graphic :
![grafik](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/143849730/6eda13f7-e98d-4bfd-b5cc-fe9f00a86af3)
Berdasarkan grafik req per second setiap algoritma, didapatkan bahwa req per second tertinggi adalah Algoritma
Generic Hash dengan nilai 207.9 dan req per second terendah adalah Algoritma Lease Connection dengan nilai\
180.11

<h3>Analisis</h3>
Berdasarkan report pada Apache Benchmark, berikut adalah analisis untuk setiap algoritma :
1. Round Robin : <br>
Algoritma Round Robin tidak perform dengan baik dalam tes ini, dengan 333 dari 500 permintaan gagal. Ini menunjukkan bahwa algoritma ini mungkin tidak mengelola distribusi beban dengan efisien di bawah kondisi uji ini. Waktu per permintaan cukup tinggi, menunjukkan potensi latensi yang signifikan. RPS yang dihasilkan oleh Round Robin adalah 192.56, yang cukup tinggi, tetapi gagal menangani beban dengan baik dengan 333 permintaan gagal.
Meskipun RPS tinggi, tingkat kegagalan yang tinggi menunjukkan masalah dalam distribusi beban atau penanganan permintaan di bawah beban puncak.
2. Least Connection : <br>
Least Connection memiliki performa yang sedikit lebih buruk daripada Round Robin, dengan sedikit lebih banyak waktu yang dibutuhkan untuk menyelesaikan permintaan tetapi lebih sedikit permintaan yang gagal. RPS untuk Least Connection adalah 180.11, lebih rendah dibandingkan dengan Round Robin.
Ini menunjukkan bahwa algoritma ini mungkin lebih cocok untuk skenario dengan koneksi yang lebih stabil dan konsisten, tetapi kurang efisien di bawah beban tinggi dengan variabilitas yang tinggi.
3. IP Hash :<br>
IP Hash menunjukkan performa yang sangat baik dengan tidak ada permintaan yang gagal dan waktu per permintaan yang lebih rendah dibandingkan dengan Round Robin dan Least Connection. IP Hash mencapai RPS 198.7, yang lebih tinggi dari Least Connection dan Round Robin.
Tidak ada permintaan yang gagal, menunjukkan stabilitas dan efisiensi yang sangat baik dalam menangani beban tinggi.
4. Generic Hash :<br>
Generic Hash memiliki performa terbaik di antara semua algoritma yang diuji. Tidak ada permintaan yang gagal dan waktu per permintaan paling rendah. Generic Hash juga memiliki RPS tertinggi di antara semua algoritma dengan 207.9.
Ini menunjukkan bahwa algoritma ini sangat efisien dan dapat mengelola beban dengan sangat baik, memberikan latensi yang lebih rendah dan throughput yang lebih tinggi.
Generic Hash memiliki RPS tertinggi di antara semua algoritma dengan 207.9.

**Kesimpulan**<br>
Untuk skenario dengan beban kerja yang tinggi, Generic Hash adalah pilihan terbaik diikuti oleh IP Hash. Round Robin dan Least Connection kurang cocok untuk skenario ini karena tingkat kegagalan yang tinggi meskipun RPS mereka cukup tinggi.





  

