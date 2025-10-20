---
title: "Как расширить root раздел под LVM"
date: 2021-07-08
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1484662020986-75935d2ebc66?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDh8fERpc2t8ZW58MHx8fHwxNzM5ODA4MjgxfDA&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Для начала надо расширить сам раздел

growpart /dev/sda 3


Смотрим, что у нас получилось

fdisk -l


Если все прошло успешно, то увеличиваем место в физическом томе

pvresize /dev/sda3
pvdisplay


Дальше увеличиваем логический том

lvextend -l +100%FREE --resizefs /dev/ubuntu-vg/ubuntu-lv
vgdisplay


Иногда может понадобиться расширить файловую систему"
---

Для начала надо расширить сам раздел

`growpart /dev/sda 3
`Смотрим, что у нас получилось

`fdisk -l
`Если все прошло успешно, то увеличиваем место в физическом томе

`pvresize /dev/sda3
pvdisplay
`Дальше увеличиваем логический том

`lvextend -l +100%FREE --resizefs /dev/ubuntu-vg/ubuntu-lv
vgdisplay
`Иногда может понадобиться расширить файловую систему

`resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
`Проверяем свободное место
`df -h
`
