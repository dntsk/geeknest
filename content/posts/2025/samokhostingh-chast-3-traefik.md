---
title: "Самохостинг (часть 3) - Traefik"
date: 2025-02-23
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1636013912260-a176d5e08408?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDJ8fHJldmVyc2V8ZW58MHx8fHwxNzM5OTUyMzkxfDA&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Продолжаем разговор о домашнем сервере. На данный момент мы имеем динамический роутинг для доступа к тем ресурсам, которые нам нужны. Но иногда мы хотим выставить наружу и наши сервисы, чтоб иметь к ним доступ не только из дома. И, как часто бывает, таких сервисов у нас не один. Для этого"
---

Продолжаем разговор о домашнем сервере. На данный момент мы имеем динамический роутинг для доступа к тем ресурсам, которые нам нужны. Но иногда мы хотим выставить наружу и наши сервисы, чтоб иметь к ним доступ не только из дома. И, как часто бывает, таких сервисов у нас не один. Для этого нам и нужен какой-либо реверсивный прокси. Я давно использую Traefik, чего и вам рекомендую.

Traefik — это современный обратный прокси-сервер и балансировщик нагрузки, который автоматически конфигурируется при изменении инфраструктуры. Он идеально подходит для микросервисных архитектур и контейнеризированных сред, таких как Docker и Kubernetes. Основные функции Traefik включают:

- Автоматическое обнаружение сервисов: Traefik автоматически обнаруживает новые сервисы и настраивает маршрутизацию для них.
- Поддержка множества бэкендов: Traefik поддерживает Docker, Kubernetes, Swarm и другие платформы.
- Интеграция с Let's Encrypt: Traefik может автоматически генерировать и обновлять SSL-сертификаты через Let's Encrypt.
- Простая настройка через метаданные (labels): Конфигурация сервисов осуществляется через метки в Docker Compose или Kubernetes.
- Встроенная панель управления: Traefik предоставляет удобный веб-интерфейс для мониторинга и управления.

## Разворачивание Traefik с помощью Docker Compose

Для запуска Traefik мы будем использовать Docker Compose. 

Перед запуском Traefik установите [*docker* и его плагин *compose*](https://docs.docker.com/engine/install/?ref=geeknest.ru) и выполните следующие подготовительные шаги:

1. Создайте файл `acme.json` для хранения сертификатов Let's Encrypt:

```bash
mkdir -p /opt/docker/traefik
touch /opt/docker/traefik/acme.json
chmod 600 /opt/docker/traefik/acme.json
```

1. Убедитесь, что файл `acme.json` находится в той же директории, где вы запускаете `docker-compose`.

Ниже приведен пример конфигурационного файла `docker-compose.yml`:

```yaml
x-defaults: &defaults
  restart: always
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "5"

services:
  traefik:
    <<: *defaults
    image: traefik:v2.10
    container_name: "traefik"
    command:
      - "--api.insecure=true"
      - "--providers.docker"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.http.address=:80"
      - "--entrypoints.https.address=:443"
      - "--serverstransport.insecureskipverify=true"
      - "--certificatesresolvers.myresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=http"
      - "--certificatesresolvers.myresolver.acme.email=your-email@example.com"
      - "--certificatesresolvers.myresolver.acme.storage=/acme.json"
      - "--entrypoints.http.http.redirections.entryPoint.to=https"
      - "--entrypoints.http.http.redirections.entryPoint.scheme=https"
      - "--entrypoints.http.http.redirections.entrypoint.permanent=true"
    labels:
      - "com.centurylinklabs.watchtower.enable=true"
      - "traefik.enable=true"
      - "traefik.http.middlewares.httpsheader.headers.customrequestheaders.X-Forwarded-Proto=https"
    ports:
      - "80:80"
      - "443:443"
      - "127.0.0.1:8088:8080" # Доступ к API только с localhost
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/docker/traefik/acme.json:/acme.json
      - /etc/resolv.conf:/etc/resolv.conf

```

### Ключевые моменты конфигурации:

- `--providers.docker.exposedbydefault=false`: Отключает автоматическую маршрутизацию всех контейнеров. Это позволяет явно указывать, какие сервисы должны быть проксированы.
- Редирект HTTP → HTTPS: Все запросы по HTTP автоматически перенаправляются на HTTPS.
- Let's Encrypt: Используется для автоматической генерации SSL-сертификатов.
- Защита API: Доступ к API Traefik ограничен только локальным хостом.

## Настройка проксируемых сервисов через labels

Чтобы добавить новый сервис за Traefik, достаточно запустить контейнер с правильными метками. Рассмотрим пример настройки простого echo-сервера:

```yaml
services:
  example_service:
    image: containous/whoami
    container_name: "example_service"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.example.rule=Host(`example.yourdomain.com`)"
      - "traefik.http.routers.example.entrypoints=https"
      - "traefik.http.routers.example.tls.certresolver=myresolver"

```

### Что мы указали в метках:

- `traefik.http.routers.example.rule`: Правило маршрутизации по хосту. В данном случае сервис будет доступен по адресу `example.yourdomain.com`.
- `traefik.http.routers.example.entrypoints`: Указывает, что сервис должен использовать HTTPS.
- `traefik.http.routers.example.tls.certresolver`: Указывает решатель сертификатов, который будет использоваться для получения SSL-сертификата.

После запуска этого контейнера, он автоматически станет доступен по адресу `https://example.yourdomain.com`.

Запускаем сервисы:

```bash
docker compose up -d
```

## Дополнительные рекомендации

- DNS-записи: Убедитесь, что DNS-записи вашего домена указывают на сервер с Traefik.
- Защита файла `acme.json`: Убедитесь, что файл `acme.json`, в котором хранятся SSL-сертификаты, защищен правильными правами доступа. Выполните команду `chmod 600 acme.json`.
- Дополнительные middleware: При необходимости добавьте дополнительные middleware для защиты от DDoS-атак или других угроз. Например, можно использовать middleware для ограничения скорости запросов или для добавления базовой аутентификации.

## Расширение функциональности Traefik

Traefik поддерживает множество плагинов и дополнительных настроек, которые могут быть полезны в зависимости от ваших потребностей. Например:

- Плагины для аутентификации: Traefik поддерживает OAuth, Basic Auth и другие методы аутентификации.
- Мониторинг и логирование: Traefik интегрируется с Prometheus, Grafana и другими инструментами для мониторинга и анализа трафика.
- Балансировка нагрузки: Traefik поддерживает различные алгоритмы балансировки нагрузки, такие как Round Robin, Weighted и другие.

Traefik — это мощный и гибкий инструмент для организации обратного проксирования и балансировки нагрузки в современных микросервисных архитектурах. Благодаря автоматической конфигурации и интеграции с Docker, Kubernetes и Let's Encrypt, Traefik значительно упрощает управление инфраструктурой.