---
title: "Самохостинг (часть 5) - логи"
date: 2025-03-02
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1549605659-32d82da3a059?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDR8fGxpbnV4fGVufDB8fHx8MTc0MDk4MTk3Nnww&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Часто при развертывании нового сервиса есть сложность с чем-либо и нужно посмотреть что же идет не так. Можно всегда зайти на сервер по ssh и посмотреть логи, но иногда сильно удобнее их смотреть через веб-интерфейс. И вот тут нам на помощь приходит Dozzle.


Что такое Dozzle?

Dozzle — это open-source проект,"
---

Часто при развертывании нового сервиса есть сложность с чем-либо и нужно посмотреть что же идет не так. Можно всегда зайти на сервер по ssh и посмотреть логи, но иногда сильно удобнее их смотреть через веб-интерфейс. И вот тут нам на помощь приходит Dozzle.

## Что такое Dozzle?

**Dozzle** — это open-source проект, спонсируемый Docker OSS. Это веб-приложение, предназначенное для упрощения мониторинга и отладки контейнеров. Dozzle предлагает потоковую передачу логов в реальном времени, фильтрацию и поиск через интуитивно понятный интерфейс.

С помощью Dozzle пользователи могут быстро получать доступ к логам, генерируемым их Docker-контейнерами. Это делает его незаменимым инструментом для отладки и устранения неполадок в Docker-среде. По умолчанию Dozzle поддерживает логи в формате JSON с интеллектуальной цветовой разметкой, что упрощает чтение и анализ данных.

## Основные возможности Dozzle

- Потоковая передача логов в реальном времени: Dozzle позволяет отслеживать логи контейнеров в режиме реального времени, что особенно полезно при отладке работающих приложений.
- Фильтрация и поиск: Инструмент предоставляет возможность фильтровать логи по контейнерам и искать конкретные сообщения, что значительно ускоряет процесс анализа.
- Цветовая разметка: Логи в формате JSON автоматически выделяются цветами, что делает их более читаемыми.
- Простота установки и настройки: Dozzle легко развернуть с помощью Docker, а его минималистичный интерфейс не требует сложной настройки.
- Поддержка аутентификации: Dozzle поддерживает простую аутентификацию, что позволяет защитить доступ к логам.

## Как установить Dozzle?

Dozzle можно легко развернуть с помощью Docker Compose. Добавляем в наш *docker-compose.yaml* следующий сервис:

```yaml
  dozzle:
    image: amir20/dozzle:latest
    container_name: dozzle
    environment:
      - DOZZLE_AUTH_PROVIDER=simple
      - DOZZLE_NO_ANALYTICS=true
      - DOZZLE_AUTH_TTL=48h
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/docker/dozzle/data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.logs-opt.rule=Host(`logs.home.example.com`)"
      - "traefik.http.routers.logs-opt.entrypoints=https"
      - "traefik.http.routers.logs-opt.tls.certresolver=myresolver"
      - "traefik.http.services.logs-opt.loadbalancer.server.port=8080"
      - "traefik.http.services.logs-opt.loadbalancer.server.scheme=http"

```

Запускаем с помощью уже изученной команды:

```bash
docker compose up -d
```

После запуска контейнера Dozzle будет доступен через веб-интерфейс, где вы сможете просматривать логи всех ваших контейнеров.