---
title: "Защита SSH через port knocking"
date: 2022-11-25
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1562770584-eaf50b017307?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDh8fGtleXxlbnwwfHx8fDE3Mzk4MDg5NTd8MA&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Иногда, по каким-то причинам необходимо закрыть какой-то порт так, чтоб к нему все же оставался доступ с любого IP адреса.
Например, регулятор требует, чтоб SSH порт был закрыт для всего мира.

На выручку приходит port knocking.

Итак, поставим knockd и настроим его так, чтоб SSH был закрыт, но открывался при"
---

Иногда, по каким-то причинам необходимо закрыть какой-то порт так, чтоб к нему все же оставался доступ с любого IP адреса.
Например, регулятор требует, чтоб SSH порт был закрыт для всего мира.

На выручку приходит port knocking.

Итак, поставим knockd и настроим его так, чтоб SSH был закрыт, но открывался при попытке соединиться с последовательносью портов.

## Установка knockd

`sudo apt install knockd
sudo vim /etc/knockd.conf
`Тут у нас есть уже настроенные правила, которые нам надо поправить. Меняем порты в которые мы будем стучаться, чтоб открылся наш SSH.

`[openSSH]
	sequence    = 2233,2244,2255
	command     = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
...

[closeSSH]
	sequence    = 12322
`Тут мы поменяли список портов и команде сменили `-A` и `-I`, что означает делать вставку правила файервола в начало списка правил, вместо того, чтоб добавлять его в конец.

Теперь нужно указать интерфейс, на котором knockd будет слушать попытки подключения. Для этого смотрим какой интерфейс мы будем использовать:

`sudo ip addr
sudo vim /etc/default/knockd
`Тут раскоментируем строку и вписываем правильное имя интерфейса:

`...
KNOCKD_OPTS="-i ens18"
`
## Iptables
Дальше настраиваем файервол:

`sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j REJECT
`и делаем его активным после перезагрузки:

`sudo apt install iptables-persistent
`При установке соглашаемся сохранить наши существующие правила файервола.

Осталось перезапустить сервис knockd и проверить как все работает.

`sudo service knockd restart
`Подключаемся:

`telnet ip 2233
telnet ip 2244
telnet ip 2255
ssh ip
`Вот и все. SSH порт откроется для вашего текущего IP адреса и пустит вас на сервер.

Чтоб закрыть порт нужно постучать в указанный порт:
`telnet ip 12322
`
