---
title: "GeoIP в Clickhouse"
date: 2025-07-01
author: "Silver Ghost"
tags: ["Разное"]
image: "https://images.unsplash.com/photo-1633412802994-5c058f151b66?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDF8fHNxbHxlbnwwfHx8fDE3NTEzNjkyNzV8MA&amp;ixlib&#x3D;rb-4.1.0&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Не всегда есть возможность использовать MaxMind GeoIP базы. В ClickHouse я прикрутил для себя вот такой вариант:

-- 1. Создаем базу данных для GeoIP
CREATE DATABASE IF NOT EXISTS geoip;

-- 2. Переключаемся на базу geoip
USE geoip;

-- 3. Создаем таблицу для стран (самый быстрый вариант)
CREATE TABLE ip_"
---

Не всегда есть возможность использовать MaxMind GeoIP базы. В ClickHouse я прикрутил для себя вот такой вариант:

```SQL
-- 1. Создаем базу данных для GeoIP
CREATE DATABASE IF NOT EXISTS geoip;

-- 2. Переключаемся на базу geoip
USE geoip;

-- 3. Создаем таблицу для стран (самый быстрый вариант)
CREATE TABLE ip_country (
    ip_start UInt32,
    ip_end UInt32,
    country_code FixedString(2)
) ENGINE = MergeTree()
ORDER BY ip_start
SETTINGS index_granularity = 8192;

-- 4. Загружаем данные из готового CSV (GeoLite2)
-- Используем URL функцию для прямой загрузки
INSERT INTO ip_country 
SELECT 
    IPv4StringToNum(ip_range_start) as ip_start,
    IPv4StringToNum(ip_range_end) as ip_end,
    country_code
FROM url(
    'https://cdn.jsdelivr.net/npm/@ip-location-db/geolite2-country/geolite2-country-ipv4.csv',
    'CSV',
    'ip_range_start String, ip_range_end String, country_code String'
) WHERE country_code != '';

-- 5. Создаем расширенную таблицу с дополнительной информацией о странах
CREATE TABLE country_info (
    country_code FixedString(2),
    country_name String,
    continent_code FixedString(2),
    continent_name String
) ENGINE = MergeTree()
ORDER BY country_code;

-- 6. Заполняем справочник стран
INSERT INTO country_info VALUES
('AD', 'Andorra', 'EU', 'Europe'),
('AE', 'United Arab Emirates', 'AS', 'Asia'),
('AF', 'Afghanistan', 'AS', 'Asia'),
('AG', 'Antigua and Barbuda', 'NA', 'North America'),
('AI', 'Anguilla', 'NA', 'North America'),
('AL', 'Albania', 'EU', 'Europe'),
('AM', 'Armenia', 'AS', 'Asia'),
('AO', 'Angola', 'AF', 'Africa'),
('AQ', 'Antarctica', 'AN', 'Antarctica'),
('AR', 'Argentina', 'SA', 'South America'),
('AS', 'American Samoa', 'OC', 'Oceania'),
('AT', 'Austria', 'EU', 'Europe'),
('AU', 'Australia', 'OC', 'Oceania'),
('AW', 'Aruba', 'NA', 'North America'),
('AX', 'Åland Islands', 'EU', 'Europe'),
('AZ', 'Azerbaijan', 'AS', 'Asia'),
('BA', 'Bosnia and Herzegovina', 'EU', 'Europe'),
('BB', 'Barbados', 'NA', 'North America'),
('BD', 'Bangladesh', 'AS', 'Asia'),
('BE', 'Belgium', 'EU', 'Europe'),
('BF', 'Burkina Faso', 'AF', 'Africa'),
('BG', 'Bulgaria', 'EU', 'Europe'),
('BH', 'Bahrain', 'AS', 'Asia'),
('BI', 'Burundi', 'AF', 'Africa'),
('BJ', 'Benin', 'AF', 'Africa'),
('BL', 'Saint Barthélemy', 'NA', 'North America'),
('BM', 'Bermuda', 'NA', 'North America'),
('BN', 'Brunei Darussalam', 'AS', 'Asia'),
('BO', 'Bolivia', 'SA', 'South America'),
('BQ', 'Bonaire, Sint Eustatius and Saba', 'NA', 'North America'),
('BR', 'Brazil', 'SA', 'South America'),
('BS', 'Bahamas', 'NA', 'North America'),
('BT', 'Bhutan', 'AS', 'Asia'),
('BV', 'Bouvet Island', 'AN', 'Antarctica'),
('BW', 'Botswana', 'AF', 'Africa'),
('BY', 'Belarus', 'EU', 'Europe'),
('BZ', 'Belize', 'NA', 'North America'),
('CA', 'Canada', 'NA', 'North America'),
('CC', 'Cocos (Keeling) Islands', 'AS', 'Asia'),
('CD', 'Congo, The Democratic Republic of the', 'AF', 'Africa'),
('CF', 'Central African Republic', 'AF', 'Africa'),
('CG', 'Congo', 'AF', 'Africa'),
('CH', 'Switzerland', 'EU', 'Europe'),
('CI', 'Côte d''Ivoire', 'AF', 'Africa'),
('CK', 'Cook Islands', 'OC', 'Oceania'),
('CL', 'Chile', 'SA', 'South America'),
('CM', 'Cameroon', 'AF', 'Africa'),
('CN', 'China', 'AS', 'Asia'),
('CO', 'Colombia', 'SA', 'South America'),
('CR', 'Costa Rica', 'NA', 'North America'),
('CU', 'Cuba', 'NA', 'North America'),
('CV', 'Cape Verde', 'AF', 'Africa'),
('CW', 'Curaçao', 'NA', 'North America'),
('CX', 'Christmas Island', 'AS', 'Asia'),
('CY', 'Cyprus', 'AS', 'Asia'),
('CZ', 'Czech Republic', 'EU', 'Europe'),
('DE', 'Germany', 'EU', 'Europe'),
('DJ', 'Djibouti', 'AF', 'Africa'),
('DK', 'Denmark', 'EU', 'Europe'),
('DM', 'Dominica', 'NA', 'North America'),
('DO', 'Dominican Republic', 'NA', 'North America'),
('DZ', 'Algeria', 'AF', 'Africa'),
('EC', 'Ecuador', 'SA', 'South America'),
('EE', 'Estonia', 'EU', 'Europe'),
('EG', 'Egypt', 'AF', 'Africa'),
('EH', 'Western Sahara', 'AF', 'Africa'),
('ER', 'Eritrea', 'AF', 'Africa'),
('ES', 'Spain', 'EU', 'Europe'),
('ET', 'Ethiopia', 'AF', 'Africa'),
('FI', 'Finland', 'EU', 'Europe'),
('FJ', 'Fiji', 'OC', 'Oceania'),
('FK', 'Falkland Islands (Malvinas)', 'SA', 'South America'),
('FM', 'Micronesia, Federated States of', 'OC', 'Oceania'),
('FO', 'Faroe Islands', 'EU', 'Europe'),
('FR', 'France', 'EU', 'Europe'),
('GA', 'Gabon', 'AF', 'Africa'),
('GB', 'United Kingdom', 'EU', 'Europe'),
('GD', 'Grenada', 'NA', 'North America'),
('GE', 'Georgia', 'AS', 'Asia'),
('GF', 'French Guiana', 'SA', 'South America'),
('GG', 'Guernsey', 'EU', 'Europe'),
('GH', 'Ghana', 'AF', 'Africa'),
('GI', 'Gibraltar', 'EU', 'Europe'),
('GL', 'Greenland', 'NA', 'North America'),
('GM', 'Gambia', 'AF', 'Africa'),
('GN', 'Guinea', 'AF', 'Africa'),
('GP', 'Guadeloupe', 'NA', 'North America'),
('GQ', 'Equatorial Guinea', 'AF', 'Africa'),
('GR', 'Greece', 'EU', 'Europe'),
('GS', 'South Georgia and the South Sandwich Islands', 'AN', 'Antarctica'),
('GT', 'Guatemala', 'NA', 'North America'),
('GU', 'Guam', 'OC', 'Oceania'),
('GW', 'Guinea-Bissau', 'AF', 'Africa'),
('GY', 'Guyana', 'SA', 'South America'),
('HK', 'Hong Kong', 'AS', 'Asia'),
('HM', 'Heard Island and McDonald Islands', 'AN', 'Antarctica'),
('HN', 'Honduras', 'NA', 'North America'),
('HR', 'Croatia', 'EU', 'Europe'),
('HT', 'Haiti', 'NA', 'North America'),
('HU', 'Hungary', 'EU', 'Europe'),
('ID', 'Indonesia', 'AS', 'Asia'),
('IE', 'Ireland', 'EU', 'Europe'),
('IL', 'Israel', 'AS', 'Asia'),
('IM', 'Isle of Man', 'EU', 'Europe'),
('IN', 'India', 'AS', 'Asia'),
('IO', 'British Indian Ocean Territory', 'AS', 'Asia'),
('IQ', 'Iraq', 'AS', 'Asia'),
('IR', 'Iran, Islamic Republic of', 'AS', 'Asia'),
('IS', 'Iceland', 'EU', 'Europe'),
('IT', 'Italy', 'EU', 'Europe'),
('JE', 'Jersey', 'EU', 'Europe'),
('JM', 'Jamaica', 'NA', 'North America'),
('JO', 'Jordan', 'AS', 'Asia'),
('JP', 'Japan', 'AS', 'Asia'),
('KE', 'Kenya', 'AF', 'Africa'),
('KG', 'Kyrgyzstan', 'AS', 'Asia'),
('KH', 'Cambodia', 'AS', 'Asia'),
('KI', 'Kiribati', 'OC', 'Oceania'),
('KM', 'Comoros', 'AF', 'Africa'),
('KN', 'Saint Kitts and Nevis', 'NA', 'North America'),
('KP', 'Korea, Democratic People''s Republic of', 'AS', 'Asia'),
('KR', 'Korea, Republic of', 'AS', 'Asia'),
('KW', 'Kuwait', 'AS', 'Asia'),
('KY', 'Cayman Islands', 'NA', 'North America'),
('KZ', 'Kazakhstan', 'AS', 'Asia'),
('LA', 'Lao People''s Democratic Republic', 'AS', 'Asia'),
('LB', 'Lebanon', 'AS', 'Asia'),
('LC', 'Saint Lucia', 'NA', 'North America'),
('LI', 'Liechtenstein', 'EU', 'Europe'),
('LK', 'Sri Lanka', 'AS', 'Asia'),
('LR', 'Liberia', 'AF', 'Africa'),
('LS', 'Lesotho', 'AF', 'Africa'),
('LT', 'Lithuania', 'EU', 'Europe'),
('LU', 'Luxembourg', 'EU', 'Europe'),
('LV', 'Latvia', 'EU', 'Europe'),
('LY', 'Libya', 'AF', 'Africa'),
('MA', 'Morocco', 'AF', 'Africa'),
('MC', 'Monaco', 'EU', 'Europe'),
('MD', 'Moldova, Republic of', 'EU', 'Europe'),
('ME', 'Montenegro', 'EU', 'Europe'),
('MF', 'Saint Martin (French part)', 'NA', 'North America'),
('MG', 'Madagascar', 'AF', 'Africa'),
('MH', 'Marshall Islands', 'OC', 'Oceania'),
('MK', 'Macedonia, Republic of', 'EU', 'Europe'),
('ML', 'Mali', 'AF', 'Africa'),
('MM', 'Myanmar', 'AS', 'Asia'),
('MN', 'Mongolia', 'AS', 'Asia'),
('MO', 'Macao', 'AS', 'Asia'),
('MP', 'Northern Mariana Islands', 'OC', 'Oceania'),
('MQ', 'Martinique', 'NA', 'North America'),
('MR', 'Mauritania', 'AF', 'Africa'),
('MS', 'Montserrat', 'NA', 'North America'),
('MT', 'Malta', 'EU', 'Europe'),
('MU', 'Mauritius', 'AF', 'Africa'),
('MV', 'Maldives', 'AS', 'Asia'),
('MW', 'Malawi', 'AF', 'Africa'),
('MX', 'Mexico', 'NA', 'North America'),
('MY', 'Malaysia', 'AS', 'Asia'),
('MZ', 'Mozambique', 'AF', 'Africa'),
('NA', 'Namibia', 'AF', 'Africa'),
('NC', 'New Caledonia', 'OC', 'Oceania'),
('NE', 'Niger', 'AF', 'Africa'),
('NF', 'Norfolk Island', 'OC', 'Oceania'),
('NG', 'Nigeria', 'AF', 'Africa'),
('NI', 'Nicaragua', 'NA', 'North America'),
('NL', 'Netherlands', 'EU', 'Europe'),
('NO', 'Norway', 'EU', 'Europe'),
('NP', 'Nepal', 'AS', 'Asia'),
('NR', 'Nauru', 'OC', 'Oceania'),
('NU', 'Niue', 'OC', 'Oceania'),
('NZ', 'New Zealand', 'OC', 'Oceania'),
('OM', 'Oman', 'AS', 'Asia'),
('PA', 'Panama', 'NA', 'North America'),
('PE', 'Peru', 'SA', 'South America'),
('PF', 'French Polynesia', 'OC', 'Oceania'),
('PG', 'Papua New Guinea', 'OC', 'Oceania'),
('PH', 'Philippines', 'AS', 'Asia'),
('PK', 'Pakistan', 'AS', 'Asia'),
('PL', 'Poland', 'EU', 'Europe'),
('PM', 'Saint Pierre and Miquelon', 'NA', 'North America'),
('PN', 'Pitcairn', 'OC', 'Oceania'),
('PR', 'Puerto Rico', 'NA', 'North America'),
('PS', 'Palestine, State of', 'AS', 'Asia'),
('PT', 'Portugal', 'EU', 'Europe'),
('PW', 'Palau', 'OC', 'Oceania'),
('PY', 'Paraguay', 'SA', 'South America'),
('QA', 'Qatar', 'AS', 'Asia'),
('RE', 'Réunion', 'AF', 'Africa'),
('RO', 'Romania', 'EU', 'Europe'),
('RS', 'Serbia', 'EU', 'Europe'),
('RU', 'Russian Federation', 'EU', 'Europe'),
('RW', 'Rwanda', 'AF', 'Africa'),
('SA', 'Saudi Arabia', 'AS', 'Asia'),
('SB', 'Solomon Islands', 'OC', 'Oceania'),
('SC', 'Seychelles', 'AF', 'Africa'),
('SD', 'Sudan', 'AF', 'Africa'),
('SE', 'Sweden', 'EU', 'Europe'),
('SG', 'Singapore', 'AS', 'Asia'),
('SH', 'Saint Helena, Ascension and Tristan da Cunha', 'AF', 'Africa'),
('SI', 'Slovenia', 'EU', 'Europe'),
('SJ', 'Svalbard and Jan Mayen', 'EU', 'Europe'),
('SK', 'Slovakia', 'EU', 'Europe'),
('SL', 'Sierra Leone', 'AF', 'Africa'),
('SM', 'San Marino', 'EU', 'Europe'),
('SN', 'Senegal', 'AF', 'Africa'),
('SO', 'Somalia', 'AF', 'Africa'),
('SR', 'Suriname', 'SA', 'South America'),
('SS', 'South Sudan', 'AF', 'Africa'),
('ST', 'Sao Tome and Principe', 'AF', 'Africa'),
('SV', 'El Salvador', 'NA', 'North America'),
('SX', 'Sint Maarten (Dutch part)', 'NA', 'North America'),
('SY', 'Syrian Arab Republic', 'AS', 'Asia'),
('SZ', 'Swaziland', 'AF', 'Africa'),
('TC', 'Turks and Caicos Islands', 'NA', 'North America'),
('TD', 'Chad', 'AF', 'Africa'),
('TF', 'French Southern Territories', 'AN', 'Antarctica'),
('TG', 'Togo', 'AF', 'Africa'),
('TH', 'Thailand', 'AS', 'Asia'),
('TJ', 'Tajikistan', 'AS', 'Asia'),
('TK', 'Tokelau', 'OC', 'Oceania'),
('TL', 'Timor-Leste', 'AS', 'Asia'),
('TM', 'Turkmenistan', 'AS', 'Asia'),
('TN', 'Tunisia', 'AF', 'Africa'),
('TO', 'Tonga', 'OC', 'Oceania'),
('TR', 'Turkey', 'AS', 'Asia'),
('TT', 'Trinidad and Tobago', 'NA', 'North America'),
('TV', 'Tuvalu', 'OC', 'Oceania'),
('TW', 'Taiwan', 'AS', 'Asia'),
('TZ', 'Tanzania, United Republic of', 'AF', 'Africa'),
('UA', 'Ukraine', 'EU', 'Europe'),
('UG', 'Uganda', 'AF', 'Africa'),
('UM', 'United States Minor Outlying Islands', 'NA', 'North America'),
('US', 'United States', 'NA', 'North America'),
('UY', 'Uruguay', 'SA', 'South America'),
('UZ', 'Uzbekistan', 'AS', 'Asia'),
('VA', 'Vatican City State', 'EU', 'Europe'),
('VC', 'Saint Vincent and the Grenadines', 'NA', 'North America'),
('VE', 'Venezuela', 'SA', 'South America'),
('VG', 'Virgin Islands, British', 'NA', 'North America'),
('VI', 'Virgin Islands, U.S.', 'NA', 'North America'),
('VN', 'Viet Nam', 'AS', 'Asia'),
('VU', 'Vanuatu', 'OC', 'Oceania'),
('WF', 'Wallis and Futuna', 'OC', 'Oceania'),
('WS', 'Samoa', 'OC', 'Oceania'),
('YE', 'Yemen', 'AS', 'Asia'),
('YT', 'Mayotte', 'AF', 'Africa'),
('ZA', 'South Africa', 'AF', 'Africa'),
('ZM', 'Zambia', 'AF', 'Africa'),
('ZW', 'Zimbabwe', 'AF', 'Africa');

```

Для более удобного использования теперь создадим хранимую функцию:

```SQL
CREATE TABLE geoip_fast (
    ip_start UInt32,
    ip_end UInt32, 
    country_code String
) ENGINE = MergeTree()
ORDER BY ip_start;

INSERT INTO geoip_fast 
SELECT ip_start, ip_end, country_code 
FROM geoip.ip_country;

CREATE FUNCTION get_country AS (ip_string) -> 
    if(ip_string = '', 'Unknown', 
       coalesce((SELECT country_code FROM geoip_fast WHERE IPv4StringToNum(ip_string) BETWEEN ip_start AND ip_end LIMIT 1), 'Unknown'));
```

Использовать не просто, а очень просто:

```sql
SELECT get_country('8.8.8.8') as country;
```