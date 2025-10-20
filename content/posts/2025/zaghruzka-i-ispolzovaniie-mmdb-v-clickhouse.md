---
title: "Загрузка и использование MMDB в Clickhouse"
date: 2025-07-07
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1648459776041-cbeab708f17b?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDd8fGRhdGFiYXNlfGVufDB8fHx8MTc1MTg3NTM0M3ww&amp;ixlib&#x3D;rb-4.1.0&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Прошлый способ использования GeoIP данных показал, что он не очень удобен. Поэтому я зарылся в проблему и нашел более простой и действенный способ, как загрузить данные из базы MaxMind (но лучше использовать бесплатные аналоги типа IPInfo) в Clickhouse.

Для этого мы берем отсюда релиз аплоадера и запускаем его вот так:"
---

Прошлый способ использования GeoIP данных показал, что он не очень удобен. Поэтому я зарылся в проблему и нашел более простой и действенный способ, как загрузить данные из базы MaxMind (но лучше использовать бесплатные аналоги типа IPInfo) в Clickhouse.

Для этого мы берем [отсюда](https://github.com/maxmouchet/mmdb-to-clickhouse/releases?ref=geeknest.ru) релиз аплоадера и запускаем его вот так:

```shell
./mmdb-to-clickhouse -dsn clickhouse://admin:admin@localhost:9000 -drop -mmdb ./ipinfo_lite.mmdb -name ipinfo_mmdb -reload -test
```

Далее в ***ВАШЕЙ*** базе надо создать функции-обертки:

```SQL
CREATE FUNCTION get_country_mmdb AS (ip_string) ->
    multiIf(
        ip_string IS NULL, 'Null',
        ip_string = '', 'Empty',
        NOT isIPv4String(ip_string), 'Invalid',
        dictGetOrDefault('default.ipinfo_mmdb_val', 'country',
            dictGetOrDefault('default.ipinfo_mmdb_net', 'pointer', toIPv6(ip_string), 0), 'Unknown')
    );

CREATE FUNCTION get_country_code_mmdb AS (ip_string) ->
    multiIf(
        ip_string IS NULL, 'Null',
        ip_string = '', 'Empty',
        NOT isIPv4String(ip_string), 'Invalid',
        dictGetOrDefault('default.ipinfo_mmdb_val', 'country_code',
            dictGetOrDefault('default.ipinfo_mmdb_net', 'pointer', toIPv6(ip_string), 0), 'Unknown')
    );
```

Остальные функции можете сделать по аналогии. 

Использовать функции можно вот так:

```SQL
SELECT get_country_code_mmdb('8.8.8.8') as country;
SELECT get_country_mmdb('8.8.8.8') as country;
```

Более полный пример использования:

```SQL
SELECT
    toDate(timestamp) AS day,
    get_country_code_mmdb(toString(events.`event_data.ip_address`)) as country,
    count(*) AS count
FROM events
WHERE event_name = 'Account: Signed Up'
  AND events.`event_data.ip_address` IS NOT NULL
GROUP BY day, country
ORDER BY day, country;
```

Обновлять данные можно той же командой, что и загрузка данных.