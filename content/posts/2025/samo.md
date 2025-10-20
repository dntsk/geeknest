---
title: "Самохостниг (часть 10) - AudiobookShelf"
date: 2025-04-14
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://geeknest.ru/content/images/2025/03/Audiobookshelf_Logo.svg"
description: "AudiobookShelf - это бесплатный сервер аудиокниг и подкастов с открытым исходным кодом. Он позволяет вам организовать вашу коллекцию аудиокниг и подкастов, следить за прогрессом прослушивания и синхронизировать его между устройствами.

В этой статье мы рассмотрим, как установить AudiobookShelf с помощью Docker Compose и настроить его работу через Traefik.


Предварительные требования"
---

AudiobookShelf - это бесплатный сервер аудиокниг и подкастов с открытым исходным кодом. Он позволяет вам организовать вашу коллекцию аудиокниг и подкастов, следить за прогрессом прослушивания и синхронизировать его между устройствами.

В этой статье мы рассмотрим, как установить AudiobookShelf с помощью Docker Compose и настроить его работу через Traefik.

## Предварительные требования

- Docker и Docker Compose установлены на вашем сервере
- Traefik уже настроен

## Шаг 1: Добавление сервиса в docker-compose.yaml

Добавьте следующую конфигурацию в существующий *docker-compose.yaml*:

```yaml
audiobookshelf:
  <<: *defaults
  image: ghcr.io/advplyr/audiobookshelf:latest
  container_name: abooks
  volumes:
    - /opt/media/audiobooks:/audiobooks
    - /opt/media/podcasts:/podcasts
    - /opt/docker/audiobookshelf/config:/config
    - /opt/docker/audiobookshelf/metadata:/metadata
  environment:
    - TZ=Europe/Moscow
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.abooks-opt.rule=Host(`abooks.home.example.com`)"
    - "traefik.http.routers.abooks-opt.entrypoints=https"
    - "traefik.http.routers.abooks-opt.tls.certresolver=myresolver"

```

## Шаг 2: Создание необходимых директорий

Перед запуском контейнера убедитесь, что все необходимые директории существуют:

```bash
mkdir -p /opt/media/audiobooks
mkdir -p /opt/media/podcasts
mkdir -p /opt/docker/audiobookshelf/config
mkdir -p /opt/docker/audiobookshelf/metadata

```

## Шаг 3: Конфигурация томов

В файле docker-compose.yaml мы указали четыре тома:

- `/opt/media/audiobooks:/audiobooks` - директория для хранения ваших аудиокниг
- `/opt/media/podcasts:/podcasts` - директория для хранения подкастов
- `/opt/docker/audiobookshelf/config:/config` - директория для хранения конфигурации AudiobookShelf
- `/opt/docker/audiobookshelf/metadata:/metadata` - директория для хранения метаданных

## Шаг 4: Настройка Traefik

В файле *docker-compose.yaml* уже настроена интеграция с Traefik:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.abooks-opt.rule=Host(`abooks.home.example.com`)"
  - "traefik.http.routers.abooks-opt.entrypoints=https"
  - "traefik.http.routers.abooks-opt.tls.certresolver=myresolver"

```

Обратите внимание, что домен установлен в `abooks.home.example.com`. Поменяйте его на тот, что вам нужен.

## Шаг 5: Запуск AudiobookShelf

Запускаем уже выученную нами команду:

```bash
docker-compose up -d

```

## Шаг 6: Первоначальная настройка

После запуска контейнера перейдите по адресу `https://abooks.home.example.com` (или вашему настроенному домену). При первом запуске вам будет предложено создать учетную запись администратора.

## Настройка библиотек

После входа в систему вы можете настроить библиотеки аудиокниг и подкастов:

1. Перейдите в раздел "Библиотеки" в меню слева
1. Нажмите "Добавить библиотеку"
1. Укажите имя библиотеки и тип (аудиокниги или подкасты)
1. Для аудиокниг выберите путь `/audiobooks`
1. Для подкастов выберите путь `/podcasts`
1. Настройте дополнительные параметры, если необходимо

## Мобильные и десктопные клиенты

AudiobookShelf предлагает несколько вариантов для прослушивания вашей коллекции на различных устройствах:

### Мобильные приложения

1. Официальное приложение AudiobookShelf
- Доступно для Android в Google Play Store
- Версия для iOS доступна через TestFlight
- Функции: синхронизация прогресса, загрузка для офлайн-прослушивания, поддержка таймера сна, настраиваемая скорость воспроизведения
1. Другие клиенты

Список клиентов доступен на [официальном сайта AudiobookShelf](https://www.audiobookshelf.org/faq/app/?ref=geeknest.ru).

### Десктопные клиенты

1. Веб-интерфейс
- Доступен через любой современный браузер по адресу вашего сервера
- Полный функционал, включая управление библиотекой и воспроизведение
1. Electron приложение
- Десктопное приложение на основе официального веб-интерфейса
- Доступно для Windows, macOS и Linux
- Можно скачать с GitHub репозитория

### Интеграция с Plex

Данные с AudiobookShelf можно интегрировать с медиасерверами Plex или Jellyfin. Просто добавьте каталог с книгами в медиатеку.

### Настройка клиентов

Для подключения клиента к вашему серверу:

1. Откройте приложение и перейдите в настройки
1. Выберите "Добавить сервер" или аналогичную опцию
1. Введите полный URL вашего сервера (например, `https://abooks.home.example.com`)
1. Введите учетные данные, созданные при первоначальной настройке
1. После подключения ваша библиотека будет синхронизирована с приложением

Большинство клиентов поддерживают продвинутые функции, такие как закладки, настройка скорости воспроизведения и таймер сна. Эти настройки обычно доступны в интерфейсе приложения во время воспроизведения.

## Заключение

Теперь вы успешно установили и настроили AudiobookShelf с использованием Docker Compose и Traefik. Вы можете наслаждаться вашей коллекцией аудиокниг и подкастов, отслеживать прогресс прослушивания и использовать различные клиенты для синхронизации с вашим сервером.

Если у вас возникнут проблемы, проверьте логи контейнера:

```bash
docker logs abooks

```

Дополнительную информацию о возможностях и настройках AudiobookShelf вы можете найти в [официальной документации](https://www.audiobookshelf.org/docs/?ref=geeknest.ru).
