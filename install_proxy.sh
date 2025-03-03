#!/bin/bash

set -e

# Установка зависимостей
apt update && apt install -y git build-essential gcc make ufw curl

# Клонирование репозитория 3proxy
cd /opt
if [ ! -d "/opt/3proxy" ]; then
  git clone https://github.com/z3APA3A/3proxy.git
fi
cd 3proxy
make -f Makefile.Linux

# Копирование бинарника и создание директорий
mkdir -p /usr/local/3proxy/bin /usr/local/3proxy/logs /usr/local/3proxy/stat
cp /opt/3proxy/bin/3proxy /usr/local/3proxy/bin/

# Создание конфигурации 3proxy
cat > /usr/local/3proxy/3proxy.cfg <<EOL
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
users admin:CL:M{q47Yv3N,56%Prox
auth strong
allow admin
proxy -p3128 -i0.0.0.0 -e0.0.0.0
flush
EOL

# Создание systemd сервиса
cat > /etc/systemd/system/3proxy.service <<EOL
[Unit]
Description=3proxy HTTP Proxy Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/3proxy/bin/3proxy /usr/local/3proxy/3proxy.cfg
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Перезапуск systemd и запуск сервиса
systemctl daemon-reload
systemctl enable 3proxy
systemctl start 3proxy

# Открытие порта
ufw allow 3128/tcp
ufw --force enable

# Информация для подключения
echo "=============================="
echo "HTTP Proxy запущен на порту 3128"
echo "Логин: admin"
echo "Пароль: M{q47Yv3N,56%Prox"
echo "IP сервера: $(curl -s ifconfig.me)"
echo "=============================="
