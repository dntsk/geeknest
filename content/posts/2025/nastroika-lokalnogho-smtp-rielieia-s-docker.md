---
title: "Настройка локального SMTP-релея с Docker"
date: 2025-07-14
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1683117927786-f146451082fb?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDN8fGVtYWlsfGVufDB8fHx8MTc1MjIyMDMyMnww&amp;ixlib&#x3D;rb-4.1.0&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "При разработке приложений или настройке домашнего сервера часто возникает необходимость отправлять электронные письма. Вместо настройки полноценного почтового сервера можно использовать SMTP-релей, который будет пересылать письма через внешний почтовый сервис. В этой статье рассмотрим, как настроить локальный SMTP-релей с помощью Docker.


Что такое SMTP-релей

SMTP-релей — это промежуточный почтовый сервер, который принимает"
---

При разработке приложений или настройке домашнего сервера часто возникает необходимость отправлять электронные письма. Вместо настройки полноценного почтового сервера можно использовать SMTP-релей, который будет пересылать письма через внешний почтовый сервис. В этой статье рассмотрим, как настроить локальный SMTP-релей с помощью Docker.

## Что такое SMTP-релей

SMTP-релей — это промежуточный почтовый сервер, который принимает письма от локальных приложений и пересылает их через внешний SMTP-сервер. Это удобно, когда нужно централизованно управлять отправкой писем или когда приложения не поддерживают аутентификацию SMTP.

## Преимущества использования SMTP-релея

- Централизованная настройка: все приложения отправляют письма через один релей
- Упрощенная конфигурация: приложениям не нужно знать данные внешнего SMTP-сервера
- Гибкость: легко сменить провайдера электронной почты
- Безопасность: учетные данные хранятся в одном месте

## Настройка с помощью Docker

Для настройки SMTP-релея будем использовать Docker-образ `juanluisbaptiste/postfix`. Этот образ содержит настроенный Postfix, который может работать как релей.

### Конфигурация Docker Compose

```yaml
  smtp:
    <<: *defaults
    image: juanluisbaptiste/postfix
    container_name: smtp
    environment:
      - SMTP_SERVER=smtp.mail.me.com
      - [[email protected]](/cdn-cgi/l/email-protection)
      - SMTP_PASSWORD=xxxxxxxxxxxxxxx
      - SERVER_HOSTNAME=home.example.com
```

**Важно**: порт 25 НЕ прокидывается наружу! Релей работает только внутри Docker-сети и доступен другим контейнерам по имени `smtp`.

### Описание переменных окружения

- SMTP_SERVER: адрес внешнего SMTP-сервера (в примере используется iCloud)
- SMTP_USERNAME: имя пользователя для аутентификации
- SMTP_PASSWORD: пароль или App-специфический пароль
- SERVER_HOSTNAME: имя хоста вашего сервера

### Настройка для различных провайдеров

#### Gmail

```yaml
environment:
  - SMTP_SERVER=smtp.gmail.com
  - [[email protected]](/cdn-cgi/l/email-protection)
  - SMTP_PASSWORD=your-app-password
  - SERVER_HOSTNAME=yourdomain.com
```

#### Yandex

```yaml
environment:
  - SMTP_SERVER=smtp.yandex.ru
  - [[email protected]](/cdn-cgi/l/email-protection)
  - SMTP_PASSWORD=your-password
  - SERVER_HOSTNAME=yourdomain.com
```

#### Mail.ru

```yaml
environment:
  - SMTP_SERVER=smtp.mail.ru
  - [[email protected]](/cdn-cgi/l/email-protection)
  - SMTP_PASSWORD=your-password
  - SERVER_HOSTNAME=yourdomain.com
```

## Запуск и проверка

1. Добавьте в ваш файл `docker-compose.yml` конфигурацию

Запустите контейнер:

```bash
docker-compose up -d
```

Просмотрите логи:

```bash
docker-compose logs smtp
```

Проверьте статус контейнера:

```bash
docker-compose ps
```

## Тестирование SMTP-релея

Для проверки работы релея из другого контейнера можно использовать:

```bash
# Запуск временного контейнера для тестирования
docker run --rm -it --network your-network-name alpine:latest sh

# Установка telnet внутри контейнера
apk add busybox-extras

# Подключение к релею
telnet smtp 25

# Отправка тестового письма
HELO localhost
MAIL FROM: [[email protected]](/cdn-cgi/l/email-protection)
RCPT TO: [[email protected]](/cdn-cgi/l/email-protection)
DATA
Subject: Test message
From: [[email protected]](/cdn-cgi/l/email-protection)
To: [[email protected]](/cdn-cgi/l/email-protection)

This is a test message.
.
QUIT
```

## Интеграция с другими контейнерами

Основное преимущество такой настройки — использование SMTP-релея другими контейнерами в рамках одной Docker-сети.

### Пример с веб-приложением

```yaml
  web-app:
    <<: *defaults
    image: nginx:alpine
    container_name: web-app
    environment:
      - SMTP_HOST=smtp
      - SMTP_PORT=25
    depends_on:
      - smtp

  smtp:
    <<: *defaults
    image: juanluisbaptiste/postfix
    container_name: smtp
    environment:
      - SMTP_SERVER=smtp.mail.me.com
      - [[email protected]](/cdn-cgi/l/email-protection)
      - SMTP_PASSWORD=xxxxxxxxxxxxxxx
      - SERVER_HOSTNAME=dntsk.dev
    
```

### Пример с Laravel приложением

```yaml
  laravel-app:
    <<: *defaults
    image: php:8.2-fpm
    container_name: laravel-app
    environment:
      - MAIL_MAILER=smtp
      - MAIL_HOST=smtp
      - MAIL_PORT=25
      - MAIL_ENCRYPTION=null
    depends_on:
      - smtp
```

### Пример с WordPress

```yaml
  wordpress:
    <<: *defaults
    image: wordpress:latest
    container_name: wordpress
    environment:
      - WORDPRESS_CONFIG_EXTRA=
        define('SMTP_HOST', 'smtp');
        define('SMTP_PORT', 25);
    depends_on:
      - smtp
```

В этих примерах приложения обращаются к SMTP-релею по имени контейнера `smtp` и порту `25` внутри Docker-сети.

## Безопасность

Такая конфигурация обеспечивает максимальную безопасность:

- Изоляция: SMTP-релей доступен только контейнерам внутри Docker-сети
- Отсутствие внешних портов: порт 25 не прокидывается на хост-систему
- Централизованная аутентификация: учетные данные хранятся только в релее

## Заключение

Настройка локального SMTP-релея с Docker — это безопасный и эффективный способ централизованно управлять отправкой электронных писем внутри контейнерной инфраструктуры. Ключевые преимущества такого подхода:

- Безопасность: релей изолирован внутри Docker-сети
- Простота интеграции: другие контейнеры подключаются по имени `smtp`
- Централизованное управление: все настройки внешнего SMTP в одном месте
- Гибкость: легко сменить провайдера без изменения конфигурации приложений

Такая архитектура идеально подходит для микросервисных приложений и контейнерных окружений, где требуется безопасная и надежная отправка электронных писем.