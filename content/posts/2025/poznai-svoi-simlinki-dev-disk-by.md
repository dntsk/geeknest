---
title: "Познай свои симлинки /dev/disk/by-*"
date: 2025-10-20
author: "Silver Ghost"
tags: ["Перевод"]
image: "https://images.unsplash.com/photo-1597852074816-d933c7d2b988?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDY5fHxkaXNrfGVufDB8fHx8MTc2MDk1OTEwMXww&amp;ixlib&#x3D;rb-4.1.0&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Где создаются ссылки

Симлинки могут быть созданы:

 * во время форматирования файловой системы утилитой mkfs;
 * при загрузке системы (boot up).

---

## Где создаются ссылки

Симлинки могут быть созданы:

- во время форматирования файловой системы утилитой mkfs;
- при загрузке системы (boot up).

## Пример содержимого каталога /dev/disk

```
[root@host disk]# pwd
/dev/disk
[root@host disk]# ls -l
drwxr-xr-x. 2 root root 320 Apr  1 13:47 by-id
drwxr-xr-x. 2 root root  60 Mar 18 10:13 by-label
drwxr-xr-x. 2 root root  60 Mar 18 10:12 by-partlabel
drwxr-xr-x. 2 root root 100 Mar 18 10:12 by-partuuid
drwxr-xr-x. 2 root root 180 Apr  1 13:47 by-path
drwxr-xr-x. 2 root root 120 Jun 17 05:26 by-uuid
```

---

## Во время mkfs﻿
При создании файловой системы mkfs﻿ инициирует ряд событий — как событий ядра, так и событий udev﻿. Демон systemd-udevd﻿ реагирует на них в соответствии с правилами из каталога /usr/lib/udev/rules.d/﻿.

Ссылки by-uuid﻿ и by-label﻿ напрямую связаны с процессом mkfs﻿.
Когда mkfs﻿ записывает данные и закрывает файловый дескриптор устройства, inotify﻿ отправляет событие IN_CLOSE_WRITE﻿, которое перехватывается systemd-udevd﻿.
Демон временно отключает наблюдение (inotify﻿), выполняет сканирование blkid﻿, вновь включает наблюдатель и создаёт симлинки.

**Последовательность шагов:**

1. mkfs﻿ открывает устройство.
1. Создаёт файловую систему.
1. Закрывает его — возникает событие IN_CLOSE_WRITE﻿.
1. udev﻿ временно отключает inotify﻿, выполняет blkid scan﻿.
1. Записывает в kernfs﻿ “change” для генерации синтетического события ядра (KERNEL uevent﻿).
1. При обработке этого события systemd-udevd﻿ считывает UUID﻿ и метку, создаёт ссылки by-uuid﻿ и by-label﻿.

Пример KERNEL﻿ события:

`KERNEL[...] change /devices/.../block/sda/sda1 (block)
ACTION=change
DEVNAME=/dev/sda1
DEVTYPE=partition
SUBSYSTEM=block

`
---

## Во время загрузки системы﻿
На ранних этапах загрузки процесс /init﻿ из initramfs﻿ взаимодействует с контроллерами PCI﻿, SATA﻿, SCSI﻿, NVMe﻿ и т. д.
При обнаружении дисков ядро посылает события add﻿.

Пример события добавления устройства:

````
ACTION=add
DEVNAME=/dev/sdb
ID_SERIAL=SanDisk_Cruzer_Glide_4C530001220702114173
ID_VENDOR=SanDisk
ID_MODEL=Cruzer_Glide
ID_FS_TYPE=ext4
ID_FS_LABEL=MYUSB

```

Если диск содержит MBR﻿ или GPT﻿, создаются события add﻿ для каждого раздела.

Затем init﻿ запускает udevadm trigger﻿ для обработки всех событий.
systemd-udevd﻿ создаёт обычные устройства /dev/sda﻿, /dev/sda1﻿ и симлинки под /dev/disk/by-*﻿.

---

## Разновидности симлинков﻿

## by-uuid﻿ и by-label﻿

Создаются на основании UUID﻿ и метки файловой системы при наличии.

## by-path﻿

Формируются по физическому пути до устройства — через контроллер, шину и порт.
Пример:

`[root@host rules.d]# ls -l /dev/disk/by-path/
pci-0000:18:00.0-scsi-0:0:0:1      -> ../../sdb
pci-0000:18:00.0-scsi-0:0:0:1-part1 -> ../../sdb1
`
## by-id﻿
Отражают аппаратные идентификаторы диском (SCSI, WWN).
Создаются при сканировании устройства, а не из данных ФС.
Пример:

`lrwxrwxrwx. 1 root root  9 scsi-3605447b1be9845b4… -> ../../sdb
lrwxrwxrwx. 1 root root  9 wwn-0x605447b1be9845b4… -> ../../sdb
`
## by-partuuid﻿
Использует уникальный идентификатор раздела, хранящийся в таблице разделов (GUID для GPT, либо комбинация номера и ID диска для MBR).

## by-partlabel﻿

Создаётся из меток разделов, хранимых в таблице разделов; не зависит от содержимого файловой системы.

---

## Пример udev события после mkfs.btrfs﻿

`UDEV[...] change /devices/.../block/sda/sda1 (block)
ACTION=change
DEVLINKS=/dev/disk/by-uuid/... /dev/disk/by-label/data-btrfs /dev/disk/by-path/...
ID_FS_TYPE=btrfs
ID_FS_UUID=cd530dea-7f4d-45be-a307-f683fa43c2cc
ID_FS_LABEL=data-btrfs
`Такие события могут отлавливаться прикладными сервисами, чтобы реагировать на создание или изменение файловых систем.

---

## Вывод﻿

systemd-udevd﻿ — ключевой компонент, обеспечивающий создание стабильных симлинков устройств в /dev/disk/by-*﻿.
Понимание их назначения облегчает диагностику, автоматизацию и настройку монтирования в Linux, особенно на серверах и виртуализированных системах.
