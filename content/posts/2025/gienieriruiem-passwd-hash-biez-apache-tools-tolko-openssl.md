---
title: "Генерируем passwd hash без Apache tools (только openssl)"
date: 2025-03-27
author: "Silver Ghost"
tags: ["Разное"]
image: "https://images.unsplash.com/photo-1634224143538-ce0221abf732?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDR8fHBhc3N3b3JkfGVufDB8fHx8MTc0MjgxMjYxMXww&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Иногда нужно сгенерировать хеш пароля для файлов .htpasswd, но под рукой нет Apache tools (htpasswd). Решение простое - используем openssl, который есть и в MacOS, и в Linux.


Генерация хеша для htpasswd

С солью (рекомендуется):

openssl passwd -1 -salt &quot;случайная_соль&quot; ваш_пароль


SHA256 (более безопасный вариант):

openssl passwd -5"
---

Иногда нужно сгенерировать хеш пароля для файлов `.htpasswd`, но под рукой нет Apache tools (`htpasswd`). Решение простое - используем `openssl`, который есть и в MacOS, и в Linux.

## Генерация хеша для htpasswd

**С солью** (рекомендуется):

```bash
openssl passwd -1 -salt "случайная_соль" ваш_пароль

```

**SHA256** (более безопасный вариант):

```bash
openssl passwd -5 ваш_пароль

```

**SHA1** (формат Apache):

```bash
openssl passwd -1 ваш_пароль

```

## Пример для MacOS/Linux

```bash
$ openssl passwd -1 mysecretpassword
$1$X.YwE4vB$JZ5D6qL9nUzQhOaTkP7rV0

```

Полученный хеш можно сразу использовать в `.htpasswd`:

`username:$1$X.YwE4vB$JZ5D6qL9nUzQhOaTkP7rV0
`
## Важно

- В MacOS и Linux команды идентичны
- `-1` = MD5 (стандарт для htpasswd)
- `-5` = SHA256 (более безопасный)
- Всегда используйте соль для безопасности
Теперь вы можете создавать хеши паролей без установки дополнительных пакетов!
