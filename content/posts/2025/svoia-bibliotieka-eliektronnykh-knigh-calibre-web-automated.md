---
title: "Своя библиотека электронных книг: Calibre-Web-Automated"
date: 2025-08-31
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1521920592574-49e0b121c964?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDE2fHxsaWJyYXJ5fGVufDB8fHx8MTc1NjQzMDczNXww&amp;ixlib&#x3D;rb-4.1.0&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Зачем?

Электронные книги разбросаны по разным устройствам и форматам:

 * накопилась куча книг в PDF, EPUB, MOBI, FB2
 * хочется читать с любого устройства без танцев с бубном
 * надоело вручную конвертировать форматы для Kindle
 * хочется красивые обложки и правильные метаданные на всех устройствах

Решение — Calibre-Web-Automated: веб-интерфейс Calibre-Web + мощь полноценного Calibre + куча автоматизаций"
---

## Зачем?

Электронные книги разбросаны по разным устройствам и форматам:

- накопилась куча книг в PDF, EPUB, MOBI, FB2
- хочется читать с любого устройства без танцев с бубном
- надоело вручную конвертировать форматы для Kindle
- хочется красивые обложки и правильные метаданные на всех устройствах

Решение — [Calibre-Web-Automated](https://github.com/crocodilestick/Calibre-Web-Automated?ref=geeknest.ru): веб-интерфейс Calibre-Web + мощь полноценного Calibre + куча автоматизаций в одном контейнере!

## Что ты получишь?

- Красивый веб-интерфейс для чтения и управления библиотекой
- Автоматическая конвертация в нужный формат (например, всё в EPUB)
- Отправка книг на Kindle с правильными обложками и метаданными
- Автоматическое применение обложек и метаданных к самим файлам
- Папка-инжест: кинул книгу → она автоматически добавилась в библиотеку
- Поддержка плагинов Calibre (включая DeDRM)

## Что уже готово

- Docker и Docker Compose установлены
- Traefik настроен (по этой инструкции)
- У тебя есть домен вида `books.home.example.com`

Создай папки для данных:

```bash
mkdir -p /opt/docker/books/{config,inbound,library}

```

## Docker Compose конфигурация

Добавляем в наш `docker-compose.yml`:

```yaml
  calibre-web-automated:
    <<: *defaults
    image: crocodilestick/calibre-web-automated:latest
    container_name: calibre-web-automated
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
    volumes:
      - /opt/docker/books/config:/config
      - /opt/docker/books/inbound:/cwa-book-ingest
      - /opt/docker/books/library:/calibre-library
      #- /path/to/your/gmail/credentials.json:/app/calibre-web/gmail.json # Для отправки на Kindle
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.books-opt.rule=Host(\`books.home.example.com\`)"
      - "traefik.http.routers.books-opt.entrypoints=https"
      - "traefik.http.routers.books-opt.tls.certresolver=myresolver"
      - "traefik.http.services.books-opt.loadbalancer.server.port=8083"
      - "traefik.http.services.books-opt.loadbalancer.server.scheme=http"

```

Запускаем:

```bash
docker compose up -d

```

Теперь интерфейс доступен по адресу: https://books.home.example.com

## Первичная настройка

### Первый вход

- Логин по умолчанию: `admin`
- Пароль: `admin123`
- Сразу смени пароль!

### Настройка автоматизаций

Зайди в **CWA Settings** в админ-панели:

- Auto-Import: включи автоматический импорт из папки `/cwa-book-ingest`
- Target Format: выбери целевой формат (например, EPUB)
- Auto-Convert: включи автоконвертацию
- Enforce Metadata: включи применение метаданных к файлам

### Настройка отправки на Kindle

- Зайди в настройки пользователя
- Добавь email своего Kindle
- Настрой SMTP для отправки (или используй Gmail с credentials.json)

## Главные фишки CWA

### Автоматическое добавление книг

Просто кинь книги в папку `/opt/docker/books/inbound`:

- Автоматически добавятся в библиотеку
- Конвертируются в нужный формат
- Получат метаданные и обложки
- Файлы удалятся из inbound после обработки

### Интеграция метаданных

В отличие от обычного Calibre-Web, где обложки меняются только в интерфейсе:

- Изменения применяются к самим файлам книг
- Kindle получит книгу с правильной обложкой
- Метаданные сохраняются в файле

### Массовое редактирование

- Выбери несколько книг в списке
- Редактируй серии, теги, авторов одним кликом
- Удаляй дубликаты пакетно

### Плагины Calibre

Поддерживаются плагины, включая DeDRM:

```yaml
volumes:
  - /path/to/calibre/plugins:/config/.config/calibre/plugins

```

## Результат

ВозможностьЕстьКрасивый веб-интерфейс для библиотеки✅Автоматический импорт и конвертация✅Отправка на Kindle с обложками✅Поддержка всех форматов книг✅Мобильные приложения✅OPDS для читалок✅Плагины Calibre (DeDRM)✅HTTPS через Traefik✅

## Полезные ссылки

- Calibre-Web-Automated: GitHub
- Wiki проекта: Документация
- Traefik для Docker: geeknest.ru/samokhostingh-chast-3-traefik
