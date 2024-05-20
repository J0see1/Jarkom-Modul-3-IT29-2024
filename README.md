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
```
ab -n 500 -c 50 http://harkonen.it29.com/
```

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
Berdasarkan report pada Apache Benchmark, berikut adalah analisis untuk setiap algoritma :<br>

1. Round Robin : <br>
Algoritma Round Robin tidak perform dengan baik dalam tes ini, dengan 333 dari 500 permintaan gagal. Ini menunjukkan bahwa algoritma ini mungkin tidak mengelola distribusi beban dengan efisien di bawah kondisi uji ini. Waktu per permintaan cukup tinggi, menunjukkan potensi latensi yang signifikan. RPS yang dihasilkan oleh Round Robin adalah 192.56, yang cukup tinggi, tetapi gagal menangani beban dengan baik dengan 333 permintaan gagal.Meskipun RPS tinggi, tingkat kegagalan yang tinggi menunjukkan masalah dalam distribusi beban atau penanganan permintaan di bawah beban puncak.

3. Least Connection : <br>
Least Connection memiliki performa yang sedikit lebih buruk daripada Round Robin, dengan sedikit lebih banyak waktu yang dibutuhkan untuk menyelesaikan permintaan tetapi lebih sedikit permintaan yang gagal. RPS untuk Least Connection adalah 180.11, lebih rendah dibandingkan dengan Round Robin.
Ini menunjukkan bahwa algoritma ini mungkin lebih cocok untuk skenario dengan koneksi yang lebih stabil dan konsisten, tetapi kurang efisien di bawah beban tinggi dengan variabilitas yang tinggi.

5. IP Hash :<br>
IP Hash menunjukkan performa yang sangat baik dengan tidak ada permintaan yang gagal dan waktu per permintaan yang lebih rendah dibandingkan dengan Round Robin dan Least Connection. IP Hash mencapai RPS 198.7, yang lebih tinggi dari Least Connection dan Round Robin. Tidak ada permintaan yang gagal, menunjukkan stabilitas dan efisiensi yang sangat baik dalam menangani beban tinggi.

7. Generic Hash :<br>
Generic Hash memiliki performa terbaik di antara semua algoritma yang diuji. Tidak ada permintaan yang gagal dan waktu per permintaan paling rendah. Generic Hash juga memiliki RPS tertinggi di antara semua algoritma dengan 207.9.
Ini menunjukkan bahwa algoritma ini sangat efisien dan dapat mengelola beban dengan sangat baik, memberikan latensi yang lebih rendah dan throughput yang lebih tinggi.
Generic Hash memiliki RPS tertinggi di antara semua algoritma dengan 207.9.

**Kesimpulan**<br>
Untuk skenario dengan beban kerja yang tinggi, Generic Hash adalah pilihan terbaik diikuti oleh IP Hash. Round Robin dan Least Connection kurang cocok untuk skenario ini karena tingkat kegagalan yang tinggi meskipun RPS mereka cukup tinggi.

# Soal 9
Dengan menggunakan algoritma Least-Connection, lakukan testing dengan menggunakan 3 worker, 2 worker, dan 1 worker sebanyak 1000 request dengan 10 request/second, kemudian tambahkan grafiknya pada peta.

Langkah pertama yaitu mengubah ip address dari domain dan diarahkan ke ip address Load Balancer.
```
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
@       IN      A       10.78.4.2" > /etc/bind/jarkom/harkonen.it29.com

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
@       IN      A       10.78.4.2" > /etc/bind/jarkom/atreides.it29.com

service bind9 restart
```

Berikutnya kita akan melakukan penyesuain sedikit di Load Balancer Stilgar dengan menambahkan metode Least-Connection di konfigurasi LB, dan menyesuaikan jumlah worker sesuai test case yang akan dilakukan.

```
echo '
upstream worker { # (round-robin(default), least_conn, ip_hash, hash $request_uri consistent)
#    hash $request_uri consistent;
    least_conn; # masukan line ini atau tinggal uncomment saja
#    ip_hash;
    server 10.78.1.3; # kurangin aja workernya buat test case
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

service nginx restart
```
Terakhir, pada client kita akan melakukan apache benchmark dengan command sebagai berikut:

```
ab -n 1000 -c 10 http://harkonen.it29.com
```

Di mana kita akan mengirimkan 1000 request dan akan diproses sejumlah 10 request per batch. Berikut hasil-hasilnya:

## Test Case 1 (3 Worker)

![WhatsApp Image 2024-05-18 at 22 49 35_c08f440b](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/64795899-cfe1-4d0e-a553-c05f3eca122e)

## Test Case 2 (2 Worker)

![WhatsApp Image 2024-05-18 at 22 50 19_2af6a386](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/aa8b78ec-9b8e-47be-8e61-5076d05f7e13)

## Test Case 3 (1 Worker)

![WhatsApp Image 2024-05-18 at 22 50 53_4912ff7f](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/5ee05aed-5238-4e90-80ce-db4b482d293e)

## Kesimpulan
Melihat hasil benchmark tadi jumlah worker mempengaruhi jumlah request yang gagal diterima, semakin banyak worker semakin banyak request yang gagal dapat dilihat pada test case 3 ketika worker yang diset hanya 1 jumlah request yang gagal diterima bernilai 0. Sedangkan untuk RPS atau Request per Second, semakin banyak jumlah worker semakin cepat request diterima karena banyak worker yang mengolah request-request yang masuk.

# Soal 10
Selanjutnya coba tambahkan keamanan dengan konfigurasi autentikasi di LB dengan dengan kombinasi username: “secmart” dan password: “kcksyyy”, dengan yyy merupakan kode kelompok. Terakhir simpan file “htpasswd” nya di /etc/nginx/supersecret/

Kita akan membuat directory baru dan kemudian menyimpan konfigurasi htpasswd di dalam directory tersebut. Berikut script yang digunakan pada node Load Balancer Stilgar:

```
mkdir /etc/nginx/supersecret
htpasswd -cb /etc/nginx/supersecret/htpasswd secmart kcksit29

cp /etc/nginx/sites-available/default /etc/nginx/sites-available/lb_php

echo '
upstream worker { # (round-robin(default), least_conn, ip_hash, hash $request_uri consistent)
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

        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/supersecret/htpasswd;
    }
} ' > /etc/nginx/sites-available/lb_php

ln -sf /etc/nginx/sites-available/lb_php /etc/nginx/sites-enabled/

if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

service nginx restart
```

Saya menggunakan option -cb pada htpasswd untuk langsung set username beserta passwordnya tanpa harus melakukan input password. Kemudian saya melakukan konfigurasi pada file load balancer, dengan menambahkan line auth_basic di location saya bisa membuat proses autentikasi simpel di web-server tersebut. Berikut hasilnya ketika ditest menggunakan lynx:

![WhatsApp Image 2024-05-18 at 23 23 12_8c29195e](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/0ce526e1-4e06-403e-8a31-e54d4acf232d)
![WhatsApp Image 2024-05-18 at 23 25 10_5bfdd64f](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/e50d6f31-c4e2-4bda-a22c-2317b328bfaf)
![WhatsApp Image 2024-05-18 at 23 24 42_d316a953](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/47835039-d8fb-4eaf-ba7b-1eff590acfda)

# Soal 11
Lalu buat untuk setiap request yang mengandung /dune akan di proxy passing menuju halaman https://www.dunemovie.com.au/.

Untuk nomer ini tambahkan line location baru dengan endpoint dune, dan pada atributnya isikan data yang sesuai dengan laman yang mau dituju. Berikut scriptnya di Load Balancer Stilgar:

```
# Irulan

echo '
upstream worker { # (round-robin(default), least_conn, ip_hash, hash $request_uri consistent)
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

#        auth_basic "Restricted Content";
#        auth_basic_user_file /etc/nginx/supersecret/htpasswd;
    }

        location ~ /dune {
                proxy_pass https://www.webtoons.com;
                proxy_set_header Host www.webtoons.com;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
        }

} ' > /etc/nginx/sites-available/lb_php

ln -sf /etc/nginx/sites-available/lb_php /etc/nginx/sites-enabled/

if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

service nginx restart
```

Karena pada saat saya mencoba tampaknya website yang ingin di test sedang down, saya mengganti website tersebut dengan webtoon. Berikut hasilnya ketika ditest menggunakan lynx:

![WhatsApp Image 2024-05-18 at 23 35 04_8c58e120](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/5ad76c1f-70aa-4dfe-b240-1110bddaa0b3)

# Soal 12

Selanjutnya LB ini hanya boleh diakses oleh client dengan IP [Prefix IP].1.37, [Prefix IP].1.67, [Prefix IP].2.203, dan [Prefix IP].2.207.

Pertama tambahkan konfigurasi di bawah pada Mochiam untuk fixed client yang akan digunakan. Di sini saya menggunakan Paul, dan pada MAC ADDRESS di bawah saya mengisinya dengan MAC ADDRESS yang terhubung dengan DHCP Relay yaitu eth0. Kemudian pilih IP fix yang mau di set untuk Paul.

```
rm /var/lib/dhcp/dhcpd.leases

echo 'host Paul {
    hardware ethernet f2:6b:14:60:d7:55;
    fixed-address 10.78.2.203;
}' >> /etc/dhcp/dhcpd.conf

service isc-dhcp-server restart

```

Kedua tambahkan konfigurasi node pada Paul sebagai berikut:

```
echo -e "auto eth0
iface eth0 inet dhcp
hwaddress ether f2:6b:14:60:d7:55
" > /etc/network/interfaces
```

Berikut hasil ip a pada Paul sebelum dikonfigurasi:
![WhatsApp Image 2024-05-18 at 23 55 30_955ed247](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/d3b0124f-942a-442d-bea8-cd6b3486dbfa)

Berikut hasil ip a pada Paul ketika sudah dikonfigurasi:
![WhatsApp Image 2024-05-19 at 00 58 30_ff4d5b4a](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/779005d7-d96f-41ba-ad49-3e9e93c4de8d)

Jika sudah untuk melakukan limit access pada Load Balancer, tambahkan konfigurasi pada Load Balancer sebagai berikut:

```
echo '
upstream worker { # (round-robin(default), least_conn, ip_hash, hash $request_uri consistent)
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

    location / { # ini ygy yang ditambahin
        allow 10.78.1.37;
        allow 10.78.1.67;
        allow 10.78.2.203;
        allow 10.78.2.207;
        deny all;
    proxy_pass http://worker;
#        auth_basic "Restricted Content";
#        auth_basic_user_file /etc/nginx/supersecret/htpasswd;
    }

        location ~ /dune {
                proxy_pass https://www.webtoons.com;
                proxy_set_header Host www.webtoons.com;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
        }

} ' > /etc/nginx/sites-available/lb_php

ln -sf /etc/nginx/sites-available/lb_php /etc/nginx/sites-enabled/

if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

service nginx restart
```
Di mana pada location kita hanya akan allow access untuk ip ip tertentu saja dan melakukan deny pada ip lain.

Berikut hasilnya jika diakses oleh ip yang diperbolehkan:
![WhatsApp Image 2024-05-19 at 00 58 01_d1e687f0](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/c0153a9f-7bd2-43b1-b675-476f05246312)

Berikut hasilnya jika diakses oleh ip yang tidak diperbolehkan:
![WhatsApp Image 2024-05-19 at 00 58 59_a15d1aaa](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/1e9a7262-0a80-408f-8064-d2190fc71654)

# Soal 13 
Semua data yang diperlukan, diatur pada Chani dan harus dapat diakses oleh Leto, Duncan, dan Jessica.

Setup database server, Chani:
```
apt-get update
apt-get install mariadb-server -y
service mysql start

mysql -e "CREATE USER 'it29'@'%' IDENTIFIED BY 'passwordit29';"
mysql -e "CREATE USER 'it29'@'atreides.it29.com' IDENTIFIED BY 'passwordit29';"
mysql -e "CREATE DATABASE DBIT29;"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'it29'@'%';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'it29'@'atreides.it29.com';"
mysql -e "FLUSH PRIVILEGES;"

mysql="[mysqld]
skip-networking=0
skip-bind-address
"
echo "$mysql" > /etc/mysql/my.cnf

echo -e '[server]

[mysqld]

user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
socket                  = /run/mysqld/mysqld.sock
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql

bind-address            = 0.0.0.0

query_cache_size        = 16M

log_error = /var/log/mysql/error.log

expire_logs_days        = 10

character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci

[embedded]

[mariadb]

[mariadb-10.3]' > /etc/mysql/mariadb.conf.d/50-server.cnf

service mysql restart
```

setup worker laravel:

```
apt-get update
apt-get install mariadb-client -y
```

Hasilnya :
![WhatsApp Image 2024-05-19 at 01 40 51_607a599f](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/743c354f-163a-4c10-b3ed-b9bc97963ff4)

# Soal 14
Leto, Duncan, dan Jessica memiliki atreides Channel sesuai dengan quest guide berikut. Jangan lupa melakukan instalasi PHP8.0 dan Composer

Setup di setiap worker laravel dengan menyesuaikan port yang diinginkan:

```
# Leto 8001
# Duncan 8002
# Jessica 8003

apt-get update
apt-get install lynx -y
apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php$

apt-get update
apt-get install php8.0-mbstring php8.0-xml php8.0-cli php8.0-common php8.0-intl php8.0-opcache php8.0-readline php8.0-mysql php8.0-fpm php8.0-curl unzip wg$apt-get install nginx -y
wget https://getcomposer.org/download/2.0.13/composer.phar
chmod +x composer.phar
mv composer.phar /usr/bin/composer

apt-get install git -y
git clone https://github.com/martuafernando/laravel-praktikum-jarkom /var/www/laravel-praktikum-jarkom
composer update
composer install

echo 'APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=10.78.4.3
DB_PORT=3306
DB_DATABASE=DBIT29
DB_USERNAME=it29
DB_PASSWORD=passwordit29

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
' > /var/www/laravel-praktikum-jarkom/.env

service nginx start
cd /var/www/laravel-praktikum-jarkom
composer update
composer install
service nginx start
php artisan migrate:fresh
php artisan db:seed --class=AiringsTableSeeder
php artisan key:generate
php artisan config:cache
php artisan migrate
php artisan db:seed
php artisan storage:link
php artisan jwt:secret
php artisan config:clear
chown -R www-data.www-data /var/www/laravel-praktikum-jarkom/storage

echo 'server {

    listen 8001;
    # sesuain port sama worker worker

    root /var/www/laravel-praktikum-jarkom/public;

    index index.php index.html index.htm;
    server_name _;
    
    location / {
            try_files $uri $uri/ /index.php?$query_string;
    }

    # pass PHP scripts to FastCGI server
    location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
    }

location ~ /\.ht {
            deny all;
    }

    error_log /var/log/nginx/fff_error.log;
    access_log /var/log/nginx/fff_access.log;
}
' > /etc/nginx/sites-available/laravel-worker

ln -s /etc/nginx/sites-available/laravel-worker /etc/nginx/sites-enabled/
chown -R www-data.www-data /var/www/laravel-praktikum-jarkom/storage
service php8.0-fpm start
service nginx restart
```

Berikut hasilnya ditest menggunakan lynx:
![WhatsApp Image 2024-05-19 at 02 06 42_e85f37f7](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/a1ec293d-9cf9-47bd-bc18-4e4818ba11ee)

# Soal 15
atreides Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada peta.
POST /auth/register

Buat file json baru untuk memasukan kredential yang akan dipost

```
{
username: "it29",
password: "it29ni"
}
```

Pada client lakukan test benchmark sebagai berikut:

```
ab -n 100 -c 10 -p register.json -T application/json http://10.78.2.3:8001/api/auth/register
```

Berikut hasilnya:

![WhatsApp Image 2024-05-19 at 02 46 14_07f2cfde](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/604f9d04-a0b0-47b8-93bc-457d5b8e5407)

Dapat dilihat kalau ada 99 request yang gagal. Hal tersebut karena kredential yang dipost sama dan dari databasenya sendiri menolak kredential yang sama dalam hal pembuatan user.

# Soal 16
atreides Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada peta.
POST /auth/login

Gunakan file register sebelumnya dan tinggal ubah endpoint yang diuji menjadi /auth/login

```
ab -n 100 -c 10 -p register.json -T application/json http://10.78.2.3:8001/api/auth/login
```

Berikut hasilnya:
![WhatsApp Image 2024-05-19 at 02 39 35_a57ce3f1](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/9269064e-e1ec-4359-b95e-cae1c5d93d1a)

# Soal 17 
atreides Channel memiliki beberapa endpoint yang harus ditesting sebanyak 100 request dengan 10 request/second. Tambahkan response dan hasil testing pada peta.
GET /me

Buat script sebagai berikut untuk mengambil token auth berdasarkan username yang sudah dimasukan:

```
curl -X POST -H "Content-Type: application/json" -d @register.json http://10.78.2.3:8001/api/auth/login > login_output.txt
token=$(cat login_output.txt | jq -r '.token')
```

Kemudian lakukan GET berdasarkan hasil dari token tadi:

```
ab -n 100 -c 10 -H "Authorization: Bearer $token" http://10.78.2.3:8001/api/me
```

Berikut hasilnya:
![WhatsApp Image 2024-05-19 at 02 49 11_26825787](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/8a90b300-4863-47d9-aab2-a0379defe40a)

# Soal 18
Untuk memastikan ketiganya bekerja sama secara adil untuk mengatur atreides Channel maka implementasikan Proxy Bind pada Stilgar untuk mengaitkan IP dari Leto, Duncan, dan Jessica.

pada Load Balancer Stilgar tambahkan konfigurasi untuk laravel worker sebagai berikut:

```
echo 'upstream worker-laravel { #(round-robin(default), ip_hash, least_conn, hash $request_uri consistent)
    server 10.78.2.3:8001;
    server 10.78.2.4:8002;
    server 10.78.2.5:8003;
}

server {
    listen 80;
    server_name atreides.it29.com;

    location / {
        proxy_pass http://worker-laravel;
    }
}
' > /etc/nginx/sites-available/lb-laravel

rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/lb-laravel /etc/nginx/sites-enabled/

service nginx restart
```

Ketika ditest dengan metode register:
![WhatsApp Image 2024-05-19 at 12 44 23_bad92e95](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/fd643da4-70f5-443f-8861-4f5a6e50c220)

access log dari Leto
![WhatsApp Image 2024-05-19 at 12 44 41_bf970cff](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/c6800286-4fe5-4dae-9ed2-3308b81f4561)

access log dari Duncan
![WhatsApp Image 2024-05-19 at 12 44 56_dc0cd6fb](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/756305f7-7451-4568-9064-2494ce1a494f)

access log dari Jessica
![WhatsApp Image 2024-05-19 at 12 45 11_b12fa463](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/8a8eef72-3ab8-4acf-b577-666d97b57502)

# Soal 19
Untuk meningkatkan performa dari Worker, coba implementasikan PHP-FPM pada Leto, Duncan, dan Jessica. Untuk testing kinerja naikkan 
- pm.max_children
- pm.start_servers
- pm.min_spare_servers
- pm.max_spare_servers
sebanyak tiga percobaan dan lakukan testing sebanyak 100 request dengan 10 request/second kemudian berikan hasil analisisnya pada PDF.

lakukan konfigurasi php-fpm pada tiap laravel worker:

```
echo '[www]
user = www-data
group = www-data
listen = /run/php/php8.0-fpm.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off

; Choose how the process manager will control the number of child processes.

pm = dynamic
pm.max_children = 10 # aturen dewe
pm.start_servers = 5 # aturen dewe
pm.min_spare_servers = 3 # aturen dewe
pm.max_spare_servers = 8' > /etc/php/8.0/fpm/pool.d/www.conf

service php8.0-fpm restart
```

Untuk konfigurasi pm.max_children dll silahkan diatur sendiri.

berikut hasil test casenya:

Test Case 1:
![WhatsApp Image 2024-05-19 at 12 52 04_ec670686](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/cae01af1-6e29-4c37-9249-05538bd33cbd)

Test Case 2:
![WhatsApp Image 2024-05-19 at 12 54 05_62b57044](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/e515ad15-864b-4326-be5a-d800498dc4ac)

Test Case 3:
![WhatsApp Image 2024-05-19 at 12 55 52_c22dfd41](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/54008553-fcf7-4d26-b0fa-aa3b2615d9e3)

Dari ketiga test case yang didapat, penggunaan php-fpm tidak terlalu berpengaruh di bagian rps, malahan semakin besar nilai atribut yang di konfigurasi tadi semakin lama request diproses.

# Soal 20
Nampaknya hanya menggunakan PHP-FPM tidak cukup untuk meningkatkan performa dari worker maka implementasikan Least-Conn pada Stilgar. Untuk testing kinerja dari worker tersebut dilakukan sebanyak 100 request dengan 10 request/second.

Konfigurasiin aja di Stilgar untuk load balancer pakai metode Least Connection, berikut scriptnya:

```
echo -e "upstream worker-laravel {
    least_conn;
    server 10.78.2.3:8001;
    server 10.78.2.4:8002;
    server 10.78.2.5:8003;
}

server {
    listen 80;
    server_name atreides.it29.com;

    location / {
        proxy_pass http://worker-laravel;
    }
}" > /etc/nginx/sites-available/lb-laravel

service nginx restart
```

Berikut Hasilnya:
![WhatsApp Image 2024-05-19 at 13 01 27_44fcd368](https://github.com/J0see1/Jarkom-Modul-3-IT29-2024/assets/134209563/142c0d50-29f3-4240-abca-451076b64af2)
