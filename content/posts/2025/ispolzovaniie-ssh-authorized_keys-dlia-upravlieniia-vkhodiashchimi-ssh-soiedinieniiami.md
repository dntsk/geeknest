---
title: "Использование ~/.ssh/authorized_keys для управления входящими SSH-соединениями"
date: 2025-05-05
author: "Silver Ghost"
tags: ["Перевод"]
image: "https://images.unsplash.com/photo-1562770584-eaf50b017307?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDh8fGtleXxlbnwwfHx8fDE3NDUzMDc1NDh8MA&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Файл ~/.ssh/authorized_keys позволяет настроить команды, которые будут выполняться при входящих SSH-соединениях. Это полезный инструмент для управления доступом и обеспечения безопасности, особенно при работе с резервным копированием данных.


Настройка резервного копирования с использованием authorized_keys

В данном примере рассматривается использование authorized_keys для настройки резервного копирования базы данных Bacula"
---

Файл `~/.ssh/authorized_keys` позволяет настроить команды, которые будут выполняться при входящих SSH-соединениях. Это полезный инструмент для управления доступом и обеспечения безопасности, особенно при работе с резервным копированием данных.

## Настройка резервного копирования с использованием `authorized_keys`

В данном примере рассматривается использование `authorized_keys` для настройки резервного копирования базы данных Bacula и её конфигурации с помощью rsync. Резервные копии передаются на несколько хостов, и для управления этим процессом используются специальные настройки в файле `authorized_keys`.

### Пример настройки

Ниже приведены строки из файла `/home/rsyncer/.ssh/authorized_keys` на хосте `dbclone`, который собирает резервные копии баз данных с различных хостов:

`from="x8dtu.example.org,10.1.1.1",command="/usr/local/sbin/rrsync -ro /usr/home/rsyncer/backups/bacula-database/postgresql/" ssh-ed25519 AAAAC3thisisalsonotmyrealpublickeybcxpFeUMAC2LOitdpRb9l0RoW7vt5hnzwt [[email protected]](/cdn-cgi/l/email-protection)`Эта строка означает:

- При входящем SSH-соединении с клиента `x8dtu.example.org` или `10.1.1.1` выполняется команда `/usr/local/sbin/rrsync -ro /usr/home/rsyncer/backups/bacula-database/postgresql/`.
- Клиент должен использовать указанный SSH-ключ.
- Комментарий `[email protected]` не влияет на выполнение.

### Ограничение доступа

Программа `rrsync` позволяет ограничить доступ к определённой директории и сделать её доступной только для чтения. Это полезно для защиты важных данных, таких как резервные копии баз данных.

### Решение проблемы с обратным копированием

Для копирования данных в обратном направлении, с `x8dtu` на `dbclone`, был разработан скрипт, который инициирует rsync-сессию на `dbclone` и копирует данные с `x8dtu`.

Пример скрипта:

`#!/bin/sh
BACKUPDIR=${HOME}/backups/x8dtu-pg01/database-backup
IDENTITY_FILE_RSYNC=${HOME}/.ssh/id_ed25519
SERVER_TO_RSYNC=x8dtu.example.org

cd ${BACKUPDIR}
/usr/local/bin/rsync -e "/usr/bin/ssh -i ${IDENTITY_FILE_RSYNC}" --recursive -av --stats --progress --exclude 'archive' ${SERVER_TO_RSYNC}:/ ${BACKUPDIR}`
### Добавление нового ключа
Для выполнения различных задач требуется использовать разные SSH-ключи. В данном случае был создан новый ключ и добавлен в `authorized_keys`:

`from="x8dtu.startpoint.vpn.unixathome.org,10.8.1.100",command="/home/rsyncer/bin/rsync-backup-from-x8dtu.sh" ssh-ed25519 AAAAC3thisisthesecondsshkeypKBYib6rCHZ+zK5Q3LvJFukdFzT+Q92GUtej6SLW8 [[email protected]](/cdn-cgi/l/email-protection)`Это позволяет выполнять разные команды в зависимости от используемого SSH-ключа и источника соединения.

## Заключение

Использование `~/.ssh/authorized_keys` для управления входящими SSH-соединениями позволяет гибко настраивать доступ и обеспечивать безопасность при резервном копировании данных. Этот подход помогает защитить важные системы и данные от несанкционированного доступа.

[Оригинал статьи](https://dan.langille.org/2025/04/17/using-ssh-authorized-keys-to-decide-what-the-incoming-connection-can-do/?ref=geeknest.ru).