---
title: "Использование команды grep в Linux - примеры"
date: 2016-07-05
author: "Silver Ghost"
tags: ["Разное"]
image: "https://geeknest.ru/content/images/2025/03/2025-03-14-13.19.02-1.jpg"
description: "grep — утилита командной строки, которая находит на вводе строки,
отвечающие заданному регулярному выражению, и выводит их, если вывод не
отменён специальным ключом.


Синтаксис

Синтаксис может быть следующим:

grep &#x27;word&#x27; filename
grep &#x27;word&#x27; file1 file2 file3
grep &#x27;string1 string2&#x27;  filename
cat otherfile | grep &#x27;something&#x27;
command | grep &#x27;something&#x27;
command option1 | grep &#x27;data&#x27;"
---

grep — утилита командной строки, которая находит на вводе строки,
отвечающие заданному регулярному выражению, и выводит их, если вывод не
отменён специальным ключом.

## Синтаксис

Синтаксис может быть следующим:

`grep 'word' filename
grep 'word' file1 file2 file3
grep 'string1 string2'  filename
cat otherfile | grep 'something'
command | grep 'something'
command option1 | grep 'data'
grep --color 'data' fileName
`
## Поиск по файлу
Чтобы выполнить поиск пользователя boo в файле /etc/passwd запустите:

`$ grep boo /etc/passwd
`Вывод будет примерно таким:

`boo:x:1000:1000:boo,,,:/home/boo:/bin/ksh
`Так же вы можете выполнить регистронезависимый поиск строки boo
(например, bOo, Boo, BOO и т.п.):

`$ grep -i "boo" /etc/passwd
`
# Рекурсивный поиск
Можно искать во всех файлах в каталоге:

`$ grep -r "192.168.1.5" /etc/
`или

`$ grep -R "192.168.1.5" /etc/
`Пример ла, в котором встречается искомая строка (например,
/etc/ppp/options). Такое поведение можно отключить, т.е. grep не будет
вставлять в результаты поиска имена файлов, добавив ключ -h:

`$ grep -h -R "192.168.1.5" /etc/
`или

`$ grep -hR "192.168.1.5" /etc/
`Пример вывода:

`# ms-wins 192.168.1.50
# ms-wins 192.168.1.51
addresses1=192.168.1.5;24;192.168.1.2;
`
## Использование grep для поиска только слов
Если вы ищете boo, то grep найдет и такое сочетание fooboo, boo123,
123boofoo и т.п. Для того чтоб grep нашел именно слово boo можно указать
ключ -w:

`$ grep -w "boo" file
`
## Поиск двух разных слов
`$ egrep -w 'word1|word2' /path/to/file
`
## Подсчет количества
grep может посчитать количество вхождений слова в файл:

`$ grep -c 'word' /path/to/file
`Опция -n позволит вывести пронумерованные строки из файла номером этой
строки:

`$ grep -n 'root' /etc/passwd
`Пример вывода:

`1:root:x:0:0:root:/root:/bin/bash
1042:rootdoor:x:0:0:rootdoor:/home/rootdoor:/bin/csh
3319:initrootapp:x:0:0:initrootapp:/home/initroot:/bin/ksh
`
## Инвертированный вывод
Вы можете использовать параметр -v для инвертирования вывода, т.е.
вывести все строки кроме тех, в которых встречается искомое слово:

`$ grep -v bar /path/to/file
`
## Unix / Linux конвеер и grep
grep можно комбинировать с конвеером
([pipe](https://ru.wikipedia.org/wiki/%D0%9A%D0%BE%D0%BD%D0%B2%D0%B5%D0%B9%D0%B5%D1%80_(UNIX)?ref=geeknest.ru)).
Этот пример выведет имена жестких дисков:

`# dmesg | egrep '(s|h)d[a-z]'
`Показать модель CPU:

`# cat /proc/cpuinfo | grep -i 'Model'
`Эта же команда может быть выполнена по другому без pipe:

`# grep -i 'Model' /proc/cpuinfo
`Пример вывода:

`model       : 30
model name  : Intel(R) Core(TM) i7 CPU       Q 820  @ 1.73GHz
model       : 30
model name  : Intel(R) Core(TM) i7 CPU       Q 820  @ 1.73GHz
`
## Вывести только список файлов
Передав параметр -l можно вывести только имена файлов:

`$ grep -l 'main' *.c
`И, наконец, можно вывести результат с подсветкой:
`$ grep --color vivek /etc/passwd
`
