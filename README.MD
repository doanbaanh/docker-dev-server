# Get started
```
git clone https://github.com/doanbaanh/web.git
cd web
make build
make up
```

# Projects
```
/services/project1/...
/services/project2/...
```

# Available 'make' commands
```
help                 Show this help

build                Build platform
up                   Start platform
down                 Stop platform
restart              Restart platform
reload               Reload NGINX configuration

sh <container_name>  Attach to container
clean                Clean logs

backup               Dump databases
restore              Restore databases from dump
```

# Projects config

### /services/<project_name>/nginx.conf
```
server {
    listen 80;
    server_name example.localhost;
    root /var/www/<project_name>/api/public;

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
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

### /services/<project_name>/supervisord.conf
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

# Extend docker-compose (ex. for node)

### /docker-compose.extends.yml:
```
version: '2.4'

services:

  frontend-nodejs:
    extends:
      file: ./services/<project_name>/docker-compose.yml
      service: frontend-nodejs
```
