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

# Mochiam

rm /var/lib/dhcp/dhcpd.leases

echo 'host Paul {
    hardware ethernet f2:6b:14:60:d7:55;
    fixed-address 10.78.2.203;
}' >> /etc/dhcp/dhcpd.conf

service isc-dhcp-server restart

# Fixed Client (Paul)

echo -e "auto eth0
iface eth0 inet dhcp
hwaddress ether f2:6b:14:60:d7:55
" > /etc/network/interfaces