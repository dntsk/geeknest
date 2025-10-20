---
title: "Самохостинг (часть 4) - AdGuard"
date: 2025-02-25
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://geeknest.ru/content/images/2025/02/AdguardHome.webp"
description: "AdGuard Home: Что это и для чего?

AdGuard Home — это бесплатное программное обеспечение, которое работает как локальный DNS-сервер, фильтрующий рекламу и блокирующий вредоносные сайты. Его основные преимущества:

 * Блокировка рекламы на уровне всей сети, а не только на одном устройстве.
 * Защита от вредоносных сайтов , таких как фишинговые ресурсы или сайты с"
---

## AdGuard Home: Что это и для чего?

AdGuard Home — это бесплатное программное обеспечение, которое работает как локальный DNS-сервер, фильтрующий рекламу и блокирующий вредоносные сайты. Его основные преимущества:

- Блокировка рекламы на уровне всей сети, а не только на одном устройстве.
- Защита от вредоносных сайтов , таких как фишинговые ресурсы или сайты с вирусами.
- Семейная защита : возможность ограничить доступ к нежелательному контенту (например, для детей).
- Логирование запросов для анализа активности в сети.
- Простота использования : удобный веб-интерфейс для управления настройками.

AdGuard Home особенно полезен для домашних сетей, где несколько устройств подключены к одному Wi-Fi. Он позволяет централизованно контролировать трафик и повышать безопасность всех устройств в сети.

## Запускаем AdGuard Home в Docker

Для развертывания AdGuard Home будем добавлять в уже существующий файлик *docker-compose.yaml*, в котором у нас уже есть Traefik.

```yaml
  adguard-home:
    <<: *defaults
    image: adguard/adguardhome
    container_name: "adguard"
    volumes:
      - "/opt/docker/adguard/work:/opt/adguardhome/work"
      - "/opt/docker/adguard/confdir:/opt/adguardhome/conf"
    ports:
      - 53:53/udp
      - 53:53/tcp
      - 192.168.1.2:8002:80/tcp
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.adguard.rule=Host(`adguard.home.example.com`)"
      - "traefik.http.routers.adguard.entrypoints=https"
      - "traefik.http.routers.adguard.tls.certresolver=myresolver"
      - "traefik.http.services.adguard-opt.loadbalancer.server.port=80"
```

### Объяснение конфигурации:

1. `image: adguard/adguardhome`Используется официальный образ AdGuard Home из Docker Hub.
1. `volumes`
- `/opt/docker/adguard/work:/opt/adguardhome/work` — рабочая директория для хранения данных AdGuard Home.
- `/opt/docker/adguard/confdir:/opt/adguardhome/conf` — директория для конфигурационных файлов.
1. `ports`
- `53:53/udp` и `53:53/tcp` — стандартные порты для DNS-запросов.
- `192.168.1.2:8002:80/tcp` — порт для веб-интерфейса AdGuard Home. Замените `192.168.1.2` на IP вашего сервера.
1. `labels`Эти метки используются для интеграции с Traefik (прокси-сервер). Они обеспечивают HTTPS-защиту через Let's Encrypt и маршрутизацию запросов.

### Запуск AdGuard Home

1. Сохраните файл `docker-compose.yaml`.
1. Откройте терминал и выполните команду:

```bash
  docker-compose up -d
```

1. После запуска откройте браузер и перейдите по адресу `http://192.168.1.2:8002` (или используйте указанный вами IP-адрес).

На странице настройки укажите пароль администратора и настройте базовые параметры работы AdGuard Home.

## Интеграция с **DNS RouteSync Navigator**

Если вы запускали DNS RouteSync Navigator, то у вас AdGuard не запустится, т.к. 53 порт будет занят. Давайте заставим их работать в связке.

Для начала исправим конфигурацию DNS RouteSync Navigator'a. Для этого вам нужно перейти в его рабочий каталог и остановить его:

```bash
cd~/projects/DNS-RouteSync-Navigator
./start.sh
```

Теперь правим в *config.ini* IP адрес, который он будет слушать. Для этого в параметр *server_ip* пропиши адрес вашего сервера. В моем случае это будет *192.168.1.2*. В качестве *public_dns_1* и *public_dns_2* указываем *127.0.0.1* и *127.0.0.2* соответственно. И запускаем сервис назад.

```bash
./start.sh
```

Дальше исправляем конфиг AdGuard в *docker-compose.yaml*:

```yaml
  adguard-home:
    <<: *defaults
    image: adguard/adguardhome
    container_name: "adguard"
    volumes:
      - "/opt/docker/adguard/work:/opt/adguardhome/work"
      - "/opt/docker/adguard/confdir:/opt/adguardhome/conf"
    ports:
      - 127.0.0.1:53:53/udp
      - 127.0.0.1:53:53/tcp
      - 127.0.0.2:53:53/udp
      - 127.0.0.2:53:53/tcp
      - 192.168.1.2:8002:80/tcp
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.adguard.rule=Host(`adguard.home.exapmple.com`)"
      - "traefik.http.routers.adguard.entrypoints=https"
      - "traefik.http.routers.adguard.tls.certresolver=myresolver"
      - "traefik.http.services.adguard-opt.loadbalancer.server.port=80"
```

Поднимаем AdGuard:

```bash
docker compose up -d
```

Теперь DNS RouteSync Navigator будет использовать AdGuard в качестве апстрима, что позволит резать рекламу и немного поднять уровень защиты домашней сети. 

Кстати, в AdGuard можно настроить подмену адресов для доменных имен вашей сети, чтоб не ходить на ваш сервер через внешний канал. 

Заходим в "Фильтры" - "Перезапись DNS-запросов" и добавляем домены, которые вам нужны. Маски он тоже понимает. Т.е. можно просто отправить "*.home.example.com" на 192.168.1.2 и все поддомены "home.example.com" из дома будут ходить сразу на сервер. Удобно.