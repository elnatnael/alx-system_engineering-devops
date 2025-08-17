# Puppet manifest to install and configure Nginx with a 301 redirect

exec { 'apt-update':
  command => '/usr/bin/apt-get update',
}

package { 'nginx':
  ensure  => installed,
  require => Exec['apt-update'],
}

file { '/var/www/html/index.html':
  ensure  => file,
  content => 'Hello World!',
  require => Package['nginx'],
}

file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => "
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /redirect_me {
        return 301 https://www.youtube.com/watch?v=QH2-TGUlwu4;
    }
}
",
  require => Package['nginx'],
  notify  => Service['nginx'],
}

service { 'nginx':
  ensure    => running,
  enable    => true,
  require   => Package['nginx'],
  subscribe => File['/etc/nginx/sites-available/default'],
}