---
title: "Утилитарные полезности"
date: 2025-03-17
author: "Silver Ghost"
tags: ["Утилиты"]
image: "/images/2025/tools.jpg"
description: "DiskStation Manager в Docker

GitHub - vdsm/virtual-dsm: Virtual DSM in a Docker container.Virtual DSM in a Docker container. Contribute to vdsm/virtual-dsm development by creating an account on GitHub.GitHubvdsm

DiskStation Manager (DSM) — это проприетарная операционная система, разработанная компанией Synology для своих устройств сетевого хранения (NAS). DSM предоставляет"
---

## DiskStation Manager в Docker
[GitHub - vdsm/virtual-dsm: Virtual DSM in a Docker container.Virtual DSM in a Docker container. Contribute to vdsm/virtual-dsm development by creating an account on GitHub.![](https://geeknest.ru/content/images/icon/pinned-octocat-093da3e6fa40-11.svg)GitHubvdsm![](https://geeknest.ru/content/images/thumbnail/e5926123-a5a8-49e1-be9f-4b0afc275136)](https://github.com/vdsm/virtual-dsm?ref=geeknest.ru)
DiskStation Manager (DSM) — это проприетарная операционная система, разработанная компанией Synology для своих устройств сетевого хранения (NAS). DSM предоставляет пользователям удобный интерфейс для управления данными, приложениями и устройствами, обеспечивая высокую производительность и надежность. Система поддерживает широкий спектр функций, включая файловое хранение, резервное копирование, совместное использование файлов, мультимедийные сервисы и многие другие. DSM также предоставляет мощные инструменты для администрирования и безопасности, такие как управление пользователями и группами, настройка прав доступа и мониторинг системы. Благодаря своей гибкости и расширяемости, DSM позволяет пользователям адаптировать устройства Synology под свои конкретные потребности, будь то домашние или корпоративные задачи.

В общем, если вам зачем-то нужен DSM без Synology NAS, то это вариант запустить его в Docker'e, да еще и с KVM.

# **t-rec: Terminal Recorder**
[GitHub - sassman/t-rec-rs: Blazingly fast terminal recorder that generates animated gif images for the web written in rustBlazingly fast terminal recorder that generates animated gif images for the web written in rust - sassman/t-rec-rs![](https://geeknest.ru/content/images/icon/pinned-octocat-093da3e6fa40-12.svg)GitHubsassman![](https://opengraph.githubassets.com/3b3052691df2ec064c5b4635288801bdb0e53f83b09a0298fa788912816554b1/sassman/t-rec-rs)](https://github.com/sassman/t-rec-rs?ref=geeknest.ru)
Blazingly fast terminal recorder — это утилита на Rust, которая записывает ваш терминал и создает анимированные GIF или MP4 видео для веба. Она делает скриншоты с частотой 4 кадра в секунду и генерирует высококачественные, компактные анимации. Встроенная оптимизация простаивающих кадров и эффекты декорирования границ, такие как тень, делают презентации плавными и визуально привлекательными.

Утилита работает на MacOS, Linux и NetBSD, использует нативные API и функционирует полностью оффлайн, без необходимости в облачных сервисах. Она легко справляется с любыми размерами терминалов, шрифтами, цветами, программами на основе curses и escape-последовательностями.

Простота использования — одна команда для запуска всех функций, а также возможность записи любого окна, например, браузера или IDE.

# mdq: jq for Markdown
[GitHub - yshavit/mdq at console.devlike jq but for Markdown: find specific elements in a md doc - GitHub - yshavit/mdq at console.dev![](https://geeknest.ru/content/images/icon/pinned-octocat-093da3e6fa40-13.svg)GitHubyshavit![](https://geeknest.ru/content/images/thumbnail/mdq)](https://github.com/yshavit/mdq?ref=console.dev)
mdq — это утилита, которая делает для Markdown то, что jq делает для JSON: предоставляет простой способ выделять конкретные части документа. Например, GitHub PRs представляют собой Markdown-документы, и некоторые организации используют шаблоны с чек-листами для всех рецензентов. Обычно для проверки выполнения этих чек-листов требуется писать сложные и неудобные для отладки регулярные выражения. Вместо этого, с помощью mdq можно легко получить все незавершенные задачи, используя простую команду:

```sh
mdq '- [ ]'
```

mdq доступна под лицензиями Apache 2.0 или MIT, на ваш выбор.

# SSL Track
[GitHub - zimbres/SSLTrack: SSL certificate expiry monitoringSSL certificate expiry monitoring. Contribute to zimbres/SSLTrack development by creating an account on GitHub.![](https://geeknest.ru/content/images/icon/pinned-octocat-093da3e6fa40-14.svg)GitHubzimbres![](https://geeknest.ru/content/images/thumbnail/SSLTrack)](https://github.com/zimbres/SSLTrack?ref=geeknest.ru)
SSL Track — это инструмент, который помогает обеспечить непрерывную безопасность и надежность вашего веб-сайта, следя за сроком действия SSL-сертификатов.
