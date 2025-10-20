---
title: "Самохостинг (часть 7) - iSponsorBlockTV"
date: 2025-03-24
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1521302200778-33500795e128?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDJ8fHlvdXR1YmUlMjB2aWRlb3xlbnwwfHx8fDE3NDEwODYwNjZ8MA&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "iSponsorBlockTV — это клиент SponsorBlock, предназначенный для устройств с поддержкой YouTube TV. Он позволяет пользователям пропускать рекламные сегменты и отключать или пропускать рекламу на YouTube при использовании смарт-телевизоров или других подключенных устройств. Инструмент можно запускать в локальной сети и он доступен в виде Docker-контейнера, что делает его подходящим для самостоятельного хостинга."
---

iSponsorBlockTV — это клиент SponsorBlock, предназначенный для устройств с поддержкой YouTube TV. Он позволяет пользователям пропускать рекламные сегменты и отключать или пропускать рекламу на YouTube при использовании смарт-телевизоров или других подключенных устройств. Инструмент можно запускать в локальной сети и он доступен в виде Docker-контейнера, что делает его подходящим для самостоятельного хостинга. Он воспроизводит функциональность расширения SponsorBlock для браузера, обеспечивая аналогичный опыт без рекламы на телевизорах.

## Разворачиваем в Docker

Как и раньше, мы продолжаем наполнять наш *docker-compose.yaml*. Добавляем в него вот такие строки:

```yaml
  iSponsorBlockTV:
    <<: *defaults
    image: ghcr.io/dmunozv04/isponsorblocktv:v2.2.1
    container_name: iSponsorBlockTV
    volumes:
      - /opt/docker/isponsorblocktv:/app/data
```

И запускаем с помощью уже известной нам команды:

```bash
docker compose up -d
```

## Подключаем первый телевизор

Теперь нам нужно подключить телевизор к приложению. Для этого нам нужно авторизовать наш инстанс iSponsorBlockTV и привязать его к устройству.

```bash
docker compose run -ti iSponsorBlockTV --setup-cli
```

На телевизоре в настройках Youtube находим код сопряжения и вводим его. Дальше настраиваем, что нам нужно пропускать и перезагружаем сервис после окончания настройки.

```bash
docker compose restart iSponsorBlockTV
```

Готово. Теперь нативная реклама будет сама перематываться, а реклама от корпорации зла будет с отключенным звуком и автоматическим пропусканием, когда кнопка "Skip" активируется. 😎

## Подключаем второй телевизор

Я не знаю почему, но у меня подключение второго телика штатными средствами не работает. Поэтому пришлось сделать руками.

Для начала делаем бекап конфига.

```bash
cp /opt/docker/isponsorblocktv/config.json{,.bak}
```

Теперь удаляем конфиг и настраиваем его как первый.

```bash
docker compose run -ti iSponsorBlockTV --setup-cli
```

Забираем токен и добавляем его в бекап.

```bash
cat /opt/docker/isponsorblocktv/config.json | grep screen_id
cp -f /opt/docker/isponsorblocktv/config.json.bak /opt/docker/isponsorblocktv/config.json
```

Полученный screen_id нужно добавить в конфиг, чтоб было две секции с устройствами. Это должно выглядеть примерно так:

```json
{
    "devices": [
        {
            "screen_id": "__________screen_id_1__________",
            "name": "YouTube on TV1"
        },
        {
            "screen_id": "__________screen_id_2__________",
            "name": "YouTube on TV2"
        }
    ],
    "apikey": "",
    "skip_categories": [
        "sponsor",
        "selfpromo",
        "exclusive_access",
        "interaction",
        "poi_highlight",
        "intro",
        "outro",
        "preview",
        "filler",
        "music_offtopic"
    ],
    "channel_whitelist": [],
    "skip_count_tracking": true,
    "mute_ads": true,
    "skip_ads": true
}
```

Перезапускаем iSponsorBlockTV и у нас на двух устройствах теперь проматывается реклама. 

Если вам нужно подключить больше устройств - то действуйте по той же схеме. Удачи.