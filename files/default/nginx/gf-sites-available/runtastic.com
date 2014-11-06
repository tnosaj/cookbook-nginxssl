#####################################
################# HTTP ##############
#####################################


server {
        listen          0.0.0.0:80;
	client_max_body_size 10M;
        server_name     *.runtastic.com;
        #access_log /var/log/nginx/ssl-access.log;
	access_log off;
        error_log /var/log/nginx/ssl-error.log;
        keepalive_timeout    60;

        location / {
            proxy_pass http://127.0.0.1:1337;
            proxy_set_header Host $host;
            proxy_set_header x-forwarded-for $remote_addr;
        }
    }
