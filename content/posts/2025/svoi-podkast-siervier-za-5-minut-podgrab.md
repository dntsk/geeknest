---
title: "🎧 Свой подкаст-сервер за 5 минут: Podgrab"
date: 2025-05-19
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDEzfHxwb2RjYXN0fGVufDB8fHx8MTc0NzEzNzA3Mnww&amp;ixlib&#x3D;rb-4.1.0&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "✨ Зачем?

Подкасты — отличный способ учиться, развлекаться и быть в курсе мира. Но что, если:

 * Хочется слушать подкасты офлайн
 * Хочется архивировать любимые шоу
 * Не устраивают сторонние сервисы, реклама и трекеры

Решение: Podgrab — простой подкаст-граббер, который автоматически скачивает новые выпуски с любого RSS. А в связке с Audiobookshelf ты получаешь полноценный медиасервер."
---

## ✨ Зачем?

Подкасты — отличный способ учиться, развлекаться и быть в курсе мира. Но что, если:

- Хочется слушать подкасты офлайн
- Хочется архивировать любимые шоу
- Не устраивают сторонние сервисы, реклама и трекеры

Решение: **Podgrab** — простой подкаст-граббер, который автоматически скачивает новые выпуски с любого RSS. А в связке с **Audiobookshelf** ты получаешь полноценный медиасервер.

---

## 🧰 Что нужно заранее

- ✅ Установленные Docker и Docker Compose
- ✅ Настроенный Traefik с HTTPS (см. инструкцию по установке)
- ✅ Домены в зоне `.home.example.com` или свои, с настройкой DNS
- ✅ Созданные папки:

```bash
mkdir -p /opt/docker/podgrab/config
mkdir -p /opt/media/podcasts

```

---

## ⚙️ Docker Compose: Podgrab

Дописываем в наш `docker-compose.yml` следующее содержимое:

```yaml
  podgrab:
    <<: *defaults
    image: akhilrex/podgrab
    container_name: podgrab
    environment:
      - CHECK_FREQUENCY=240          # Проверка фидов каждые 4 часа
      - PASSWORD=Passw0rd1245        # Включаем базовую авторизацию (юзер: podgrab)
    volumes:
      - /opt/docker/podgrab/config:/config
      - /opt/media/podcasts:/assets
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.podcasts-opt.rule=Host(`podcasts.home.example.com`)"
      - "traefik.http.routers.podcasts-opt.entrypoints=https"
      - "traefik.http.routers.podcasts-opt.tls.certresolver=myresolver"

```

Запускаем:

```bash
docker compose up -d

```

Интерфейс будет доступен по адресу:
🔗 [https://podcasts.home.example.com](https://podcasts.home.example.com/?ref=geeknest.ru)

Авторизация:

- Логин: `podgrab`
- Пароль: `Passw0rd1245`

---

## ➕ Добавление подкастов

1. В интерфейсе нажми Add Feed
1. Вставь RSS-ссылку подкаста (можно взять с ListenNotes, Podnews, сайтов шоу и т.д.)
1. Сохрани — Podgrab начнёт скачивать новые выпуски в `/opt/media/podcasts`

---

## 🔗 Интеграция с Audiobookshelf

Если хочешь удобно слушать подкасты через мобильный интерфейс, PWA, DLNA или просто с телефона — подключи папку `/opt/media/podcasts` к Audiobookshelf.

📘 Полная инструкция по установке и настройке Audiobookshelf (включая Traefik, библиотеки, обложки и метаданные) уже есть на [сайте](https://geeknest.ru/samo/).

---

## 📱 Удобный доступ

Схема работы:

- Podgrab загружает свежие эпизоды по расписанию
- Audiobookshelf индексирует их как обычную библиотеку
- Слушаешь где угодно: на телефоне, в браузере, на телевизоре

📦 Все данные у тебя: без трекеров, баннеров и риска потерять любимые выпуски.

---

## 🔐 Безопасность

Traefik даёт HTTPS и защищённый доступ к каждому сервису:

- SSL-сертификаты через Let's Encrypt
- Поддержка Basic Auth в Podgrab
- Возможность добавить авторизацию на уровне Traefik через middleware

---

✅ Результат

Ты получаешь:

ВозможностьЕсть ✅Автоматическая загрузка✅Хранение офлайн✅Удобный стриминг✅HTTPS-доступ✅Интеграция с медиасервером✅

И всё это — за 5 минут с Docker Compose.