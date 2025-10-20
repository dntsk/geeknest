---
title: "Переключение языков в MacOS по CapsLock"
date: 2023-02-08
author: "Silver Ghost"
tags: ["Разное"]
image: "https://images.unsplash.com/photo-1715448800840-33971a2aab9a?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDF8fGNhcHMlMjBsb2NrfGVufDB8fHx8MTczOTgwOTAyMXww&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Меня стала жутко бесить задержка при переключении языков в MacOS. Иногда оно срабатывает нормально, а иногда первая буква остается английской, а только потом идет переключение.

Когда ты набираешь текст быстро и переключаешься постоянно - выходить полная дичь и времени на правки уходит какое-то невероятное количество.

Пришлось разбираться, как же мне"
---

Меня стала жутко бесить задержка при переключении языков в MacOS. Иногда оно срабатывает нормально, а иногда первая буква остается английской, а только потом идет переключение.

Когда ты набираешь текст быстро и переключаешься постоянно - выходить полная дичь и времени на правки уходит какое-то невероятное количество.

Пришлось разбираться, как же мне избавиться от этой задержки.

Чтоб все работало быстро и как ожидается нужно поставить приложение `karabiner-elements`. Эта штука позволяет переназначать действия клавиш.

Ставим тем способом, какой вам удобнее. Дальше запускаем его и создаем нужный конфиг.

`~/.config/karabiner/assets/complex_modifications/change_language.json`

```json
{
  "title": "Caps Lock => switch input source - English <-> Russian",
  "rules": [
    {
      "description": "Caps Lock => switch input source - English <-> Russian",
      "manipulators": [
        {
          "type": "basic",
          "conditions": [
            {
              "type": "variable_if",
              "name": "input_source switched",
              "value": 1
            }
          ],
          "from": {
            "key_code": "caps_lock"
          },
          "to": [
            {
              "select_input_source": {
                "language": "^en$"
              }
            },
            {
              "set_variable": {
                "name": "input_source switched",
                "value": 0
              }
            }
          ]
        },
        {
          "type": "basic",
          "from": {
            "key_code": "caps_lock"
          },
          "to": [
            {
              "select_input_source": {
                "language": "^ru$"
              }
            },
            {
              "set_variable": {
                "name": "input_source switched",
                "value": 1
              }
            }
          ]
        }
      ]
    }
  ]
}

```

Дальше открываем Karabiner, заходим в `Complex modification` -> `Add rule` и активируем нашу переключалку языка.

Теперь по нажатия на CapsLock язык мгновенно переключается на противоположный.
