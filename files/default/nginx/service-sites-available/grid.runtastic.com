###################################
############## HTTP ##############
###################################

server {
  listen          0.0.0.0:80;
  server_name     grid.runtastic.com;
  #access_log /var/log/nginx/grid.runtastic.com-access.log;
  access_log off;
  error_log /var/log/nginx/grid.runtastic.com-error.log;
  keepalive_timeout    600;
        
  location / {
    proxy_pass http://10.100.4.131:9000;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header x-forwarded-for $remote_addr;
  }
  
  location /faye {
    proxy_pass http://10.100.4.131:9292;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header x-forwarded-for $remote_addr;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
  }
}

