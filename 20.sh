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