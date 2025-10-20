---
title: "Самохостинг (часть 9) - Arr stack + медиатека"
date: 2025-04-07
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "/images/2025/media.jpeg"
description: "В этой статье я расскажу, как настроить полноценную систему автоматического скачивания и организации медиаконтента с помощью Sonarr (для сериалов), Radarr (для фильмов), Lidarr (для музыки), Jackett (для поиска по трекерам) и qBittorrent (для загрузки торрентов). Эта экосистема интегрируется с Plex, о котором у нас уже есть отдельная статья.


Что мы"
---

В этой статье я расскажу, как настроить полноценную систему автоматического скачивания и организации медиаконтента с помощью Sonarr (для сериалов), Radarr (для фильмов), Lidarr (для музыки), Jackett (для поиска по трекерам) и qBittorrent (для загрузки торрентов). Эта экосистема интегрируется с Plex, о котором у нас уже есть [отдельная статья](https://geeknest.ru/samokhostingh-chast-6-plex-media-server/).

## Что мы получим в итоге?

Представьте: вы указываете сериал, который хотите посмотреть, и система автоматически находит его, скачивает новые серии по мере выхода, сортирует их по папкам с правильными названиями и добавляет в вашу медиатеку Plex. То же самое и с фильмами и музыкой. Звучит здорово, не так ли?

## Необходимые компоненты

Для начала давайте разберёмся с ролью каждого компонента в нашей системе:

- Sonarr — отслеживает и скачивает сериалы
- Radarr — отслеживает и скачивает фильмы
- Lidarr — отслеживает и скачивает музыку
- Jackett — «переводчик» между нашими сервисами и торрент-трекерами
- qBittorrent — торрент-клиент для скачивания файлов

## Docker Compose для развертывания

Ниже приведён кусок docker-compose файла для настройки всей нашей экосистемы:

```yaml
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
      - WEBUI_PORT=8000
      - TORRENTING_PORT=54545
    volumes:
      - /opt/docker/qbittorrent/appdata:/config
      - /opt/downloads:/downloads
    ports:
      - 8000:8000
      - 54545:54545
      - 54545:54545/udp
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.torrents.rule=Host(`torrents.home.example.com`)"
      - "traefik.http.routers.torrents.entrypoints=https"
      - "traefik.http.routers.torrents.tls.certresolver=myresolver"
      - "traefik.http.services.qbittorrent-opt.loadbalancer.server.port=8000"
      - "traefik.http.routers.torrents.middlewares=myauth"
    restart: unless-stopped

  sonarr:
    image: linuxserver/sonarr
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
    volumes:
      - /opt/docker/sonarr:/config
      - /opt/media/shows:/shows
      - /opt/downloads:/downloads
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sonarr-opt.rule=Host(`sonarr.home.example.com`)"
      - "traefik.http.routers.sonarr-opt.entrypoints=https"
      - "traefik.http.routers.sonarr-opt.tls.certresolver=myresolver"
    restart: unless-stopped

  radarr:
    image: linuxserver/radarr
    container_name: radarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
    volumes:
      - /opt/docker/radarr:/config
      - /opt/media/movies:/movies
      - /opt/downloads:/downloads
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.radarr-opt.rule=Host(`radarr.home.example.com`)"
      - "traefik.http.routers.radarr-opt.entrypoints=https"
      - "traefik.http.routers.radarr-opt.tls.certresolver=myresolver"
    restart: unless-stopped

  lidarr:
    image: lscr.io/linuxserver/lidarr:latest
    container_name: lidarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Moscow
    volumes:
      - /opt/docker/lidarr:/config
      - /opt/media/music:/music
      - /opt/downloads:/downloads
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.lidarr-opt.rule=Host(`lidarr.home.example.com`)"
      - "traefik.http.routers.lidarr-opt.entrypoints=https"
      - "traefik.http.routers.lidarr-opt.tls.certresolver=myresolver"
    restart: unless-stopped

  jackett:
    image: linuxserver/jackett
    container_name: jackett
    volumes:
      - /opt/docker/jackett:/config
    ports:
      - 9117:9117
    restart: unless-stopped

```

Для сервиса Traefik в раздел *labels* добавьте вот такую строку:

```yaml
- "traefik.http.middlewares.myauth.basicauth.users=user:hash"
```

- "user" нужно заменить на имя вашего пользователя
- "hash" нужно заменить на хэш пароля

Получить хэш пароля можно с помощью команды:

```bash
openssl passwd -apr1 123456 | sed 's/\$/\$\$/g'
```

где "123456" - ваш пароль. Т.е. в результате у вас должна получиться похожая строка:

```yaml
- "traefik.http.middlewares.myauth.basicauth.users=yourusername:$$apr1$$xNSoKuLr$$XJUHroFfHGxVAcGBNlifv/"
```

## Структура каталогов

Прежде чем запустить контейнеры, убедитесь, что у вас есть соответствующая структура каталогов:

```bash
mkdir -p /opt/docker/{qbittorrent/appdata,sonarr,radarr,lidarr,jackett}
mkdir -p /opt/downloads
mkdir -p /opt/media/{shows,movies,music}

```

Теперь давайте разберемся, как настроить каждый сервис.

## Настройка qBittorrent

После запуска контейнеров перейдите по адресу `https://torrents.home.example.com` (или `http://ваш_ip:8000`), чтобы получить доступ к веб-интерфейсу qBittorrent.

1. Выполните вход с логином `admin` и паролем `adminadmin` (стандартные учетные данные).
1. Перейдите в «Настройки» → «Веб-интерфейс» и измените учетные данные.
1. В настройках «Загрузки» укажите папку `/downloads` для сохранения торрентов.
1. Настройте автоматическую категоризацию:
- Создайте категории: `tv`, `movies` и `music`
- Для каждой категории укажите путь сохранения:`/downloads/tv`
- `/downloads/movies`
- `/downloads/music`

## Настройка Jackett

Jackett работает как прокси между нашими *arr сервисами и различными торрент-трекерами.

1. Откройте веб-интерфейс Jackett по адресу `http://ваш_ip:9117`.
1. Добавьте интересующие вас трекеры, нажав «Add Indexer».
1. Для каждого трекера введите необходимые учетные данные (если требуется).
1. Запишите API Key, отображаемый в верхней части страницы — он понадобится при настройке Sonarr, Radarr и Lidarr.

## Настройка Sonarr

Sonarr управляет вашей коллекцией сериалов. Настройка:

1. Откройте веб-интерфейс Sonarr по адресу `https://sonarr.home.example.com`.
1. Перейдите в «Settings» → «Media Management»:
- Включите «Rename Episodes»
- Настройте именование файлов под ваши предпочтения
- Укажите «Root Folders» как `/shows`
1. Добавьте qBittorrent в «Settings» → «Download Clients»:
- Name: qBittorrent
- Host: qbittorrent (это имя контейнера в Docker)
- Port: 8000
- Username/Password: те, что вы настроили в qBittorrent
- Category: tv (должна соответствовать созданной в qBittorrent)
1. Добавьте Jackett как источник в «Settings» → «Indexers»:
- Нажмите «+» и выберите «Torznab»
- Name: Имя вашего трекера
- URL: API-ссылка из Jackett (обычно что-то вроде `http://jackett:9117/api/v2.0/indexers/название_трекера/results/torznab/`)
- API Key: Ключ API из Jackett
- Отметьте категории для поиска (например, TV, HDTV)

## Настройка Radarr

Radarr аналогичен Sonarr, но для фильмов. Настройка очень похожа:

1. Откройте веб-интерфейс по адресу `https://radarr.home.example.com`.
1. В «Settings» → «Media Management» настройте именование файлов и укажите «Root Folders» как `/movies`.
1. Добавьте qBittorrent в «Settings» → «Download Clients», но используйте категорию `movies`.
1. Добавьте Jackett как источник так же, как в Sonarr, но отметьте категории, относящиеся к фильмам.

## Настройка Lidarr

Lidarr занимается музыкой:

1. Откройте веб-интерфейс по адресу `https://lidarr.home.example.com`.
1. В «Settings» → «Media Management» настройте именование файлов и укажите «Root Folders» как `/music`.
1. Добавьте qBittorrent в «Settings» → «Download Clients», используя категорию `music`.
1. Добавьте Jackett как источник, отметив категории, относящиеся к музыке.

## Интеграция с Plex

Теперь нам нужно настроить интеграцию нашей системы скачивания с Plex. Предполагая, что Plex у вас уже установлен и настроен (согласно вашей предыдущей статье), выполните следующие шаги:

1. В Plex перейдите в «Settings» → «Library».
1. Добавьте новые библиотеки соответствующих типов:
- ТВ-шоу: укажите путь `/media/shows`
- Фильмы: укажите путь `/media/movies`
- Музыка: укажите путь `/media/music`
1. Включите опцию «Scan my library automatically».
1. В каждом из сервисов (Sonarr, Radarr, Lidarr) настройте уведомления Plex:
- Перейдите в «Settings» → «Connect»
- Добавьте соединение типа «Plex Media Server»
- Host: plex (имя контейнера или IP-адрес)
- Port: 32400
- Auth Token: вы можете получить его из настроек Plex

Эта настройка обеспечит автоматическое обновление библиотеки Plex при добавлении нового контента.

## Рабочий процесс системы

Давайте рассмотрим, как работает наша система на примере добавления нового сериала:

1. В Sonarr вы добавляете сериал, который хотите смотреть.
1. Sonarr обращается к Jackett для поиска торрентов этого сериала.
1. Найденные торренты отправляются в qBittorrent для скачивания в категорию `tv`.
1. Когда загрузка завершена, Sonarr обрабатывает файлы: переименовывает и перемещает их в папку `/shows`.
1. Plex автоматически обнаруживает новые файлы и добавляет их в вашу библиотеку.

Таким образом, как только появляется новая серия, она автоматически скачивается, обрабатывается и становится доступной для просмотра в Plex.

## Заключение

Создание автоматизированной системы для управления медиаконтентом требует некоторого времени для настройки, но значительно упрощает процесс поддержания актуальной медиатеки. Вместо ручного поиска, скачивания и организации файлов вы можете просто добавить желаемый контент в соответствующий сервис, и система сделает всё остальное.

Эта экосистема особенно полезна для тех, кто следит за множеством сериалов одновременно или хочет автоматически получать новые релизы от любимых исполнителей. В сочетании с Plex вы получаете полноценный медиацентр с автоматическим пополнением.

Учтите, что API от radarr/sonarr/etc могут быть не доступны из некоторых регионов мира. Поэтому нужно применить хак с [динамическим роутингом](https://geeknest.ru/dinamichieskii-routingh-na-keenetic/).

Надеюсь, эта статья помогла вам настроить собственную систему автоматизации медиаконтента. Если у вас возникли вопросы или сложности, оставляйте комментарии ниже!
