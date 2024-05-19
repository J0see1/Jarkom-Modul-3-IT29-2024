# Stilgar

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