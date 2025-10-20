---
title: "Сброс пароля пользователя root в MySQL"
date: 2019-03-13
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1489875347897-49f64b51c1f8?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDF8fG15c3FsfGVufDB8fHx8MTczOTgwMzcxM3ww&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Сбросить пароль для пользователя root в MySQL не просто, а очень просто. Для этого надо остановить базу:

$ sudo service mysql stop


Теперь запустим базу без проверки привилегий:

$ sudo mysqld_safe --skip-grant-tables &amp;


Теперь можно зайти в базу и поправить пароль:

$ mysql -u root


После этого будет доступна консоль MySQL. Выполняем обновление"
---

Сбросить пароль для пользователя root в MySQL не просто, а очень просто. Для этого надо остановить базу:

`$ sudo service mysql stop
`Теперь запустим базу без проверки привилегий:

`$ sudo mysqld_safe --skip-grant-tables &
`Теперь можно зайти в базу и поправить пароль:

`$ mysql -u root
`После этого будет доступна консоль MySQL. Выполняем обновление пароля:

`mysql> SET PASSWORD FOR root@'localhost' = PASSWORD('password');
`Иногда установка нового пароля заканчивается ошибкой:

`ERROR 1290 (HY000): The MySQL server is running with the --skip-grant-tables option so it cannot execute this statement
`Это ошибка в MySQL и тогда пароль можно установить другой командой:

`mysql> UPDATE mysql.user SET authentication_string=password('password') WHERE user='root';
`Дальше сбрасываем привилегии и перезапускаем сервер в нормальном режиме:

`mysql> FLUSH PRIVILEGES;
mysql> exit;
$ sudo mysqladmin -u root -p shutdown
$ sudo service mysql start
`Теперь можно логиниться в базу обычным образом:
`$ mysql -u root -p
`
