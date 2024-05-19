# Irulan

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

# Stilgar

echo '
upstream worker { # (round-robin(default), least_conn, ip_hash, hash $request_uri consistent)
#    hash $request_uri consistent;
    least_conn;
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

## Paul

ab -n 1000 -c 10 http://harkonen.it29.com