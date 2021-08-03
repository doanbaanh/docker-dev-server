# Get started
```
git clone https://github.com/doanbaanh/docker-dev-server.git
docker network create docker-dev-server
cd doanbaanh/docker-dev-server
cp docker-compose.yml.example docker-compose.yml
make build
make up
```

# Projects
```
/workspace/project1/repository1/...
/workspace/project2/repository1/...
/workspace/project2/repository2/...
/workspace/<project_name>/<repository_name>/...
```

# Available 'make' commands
```
Available commands:
  help               Show this help
  build              Build development server
  up                 Run development server
  down               Stop development server
  restart            Restart development server
  restart-workers    Restart PHP workers
  reload             Reload NGINX configuration and worker
  sh                 Attach to container
  clean              Clean logs
  dump               Dump databases
  restore            Restore databases from dump
```

# Projects config

## NGINX
### /workspace/<project_name>/web.conf
```
server {
    listen 80;
    server_name example.localhost;
    root /var/www/<project_name>/<repository_name>/public;

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php8:9000;
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

## PHP Worker
### /workspace/<project_name>/php8-worker.conf (php5-worker.conf/php7-worker.conf)
```
[program:<project_name>-scheduler]
process_name=%(program_name)s_%(process_num)02d
command=/bin/sh -c "while [ true ]; do (php /var/www/<project_name>/<repository_name>/artisan schedule:run --verbose --no-interaction &); sleep 60; done"
autorestart=true
stopasgroup=true
killasgroup=true
numprocs=1
redirect_stderr=true

[program:<project_name>-queue-default]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/<project_name>/<repository_name>/artisan queue:work --sleep=3 --tries=3 --daemon
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
numprocs=1
redirect_stderr=true
```

## PM2
### Copy PM2 configuration
```
cp ./workspace/ecosystem.config.js.example ./workspace/ecosystem.config.js
```
### /workspace/ecosystem.config.js
```
module.exports = {
  apps: [
    {
      name: "node",
      port: 3001,
      cwd: "/var/www/<project_name>/<repository_name>",
      script: "yarn && yarn dev --hostname node --port 3001",
    },
  ],
}
```