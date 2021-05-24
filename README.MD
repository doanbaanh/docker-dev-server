# Get started
```
git clone https://github.com/doanbaanh/web.git
cd web
make init
make build
make up
```

# Projects
```
/workspace/project1/...
/workspace/project2/...
```

# Available 'make' commands
```
Available commands:
  help               Show this help
  init               Init project environment
  build              Build platform
  up                 Run platform
  down               Stop platform
  restart            Restart platform
  reload             Reload NGINX configuration and worker
  sh                 Attach to container
  clean              Clean logs
  node-up            Run nodejs container
  node-down          Stop nodejs container
  cypress-up         Run cypress container
  cypress-down       Stop cypress container
  ftp-up             Run FTP server
  ftp-down           Stop FTP server
  backup             Dump databases
  restore            Restore databases from dump
```

# Projects config

### /workspace/<project_name>/nginx.conf
```
server {
    listen 80;
    server_name example.localhost;
    root /var/www/<project_name>/public;

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php-fpm;
        fastcgi_index index.php;
        fastcgi_read_timeout 1000;
        fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### /workspace/<project_name>/supervisord.conf
```
[program:<project_name>-scheduler]
process_name=%(program_name)s_%(process_num)02d
command=/bin/sh -c "while [ true ]; do (php /var/www/<project_name>/artisan schedule:run --verbose --no-interaction &); sleep 60; done"
autorestart=true
stopasgroup=true
killasgroup=true
numprocs=1
redirect_stderr=true

[program:<project_name>-queue-default]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/<project_name>/artisan queue:work --sleep=3 --tries=3 --daemon
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
numprocs=1
redirect_stderr=true
```
### /workspace/<project_name>/docker-compose.yml
```
version: '2.4'

services:

  example-front:
    image: node:12-alpine
    container_name: example-front
    restart: always
    logging:
      driver: none
    volumes_from:
      - web
    working_dir: /var/www/example-front
    links:
      - web:front.example.localhost

```
