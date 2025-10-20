---
title: "Мониторинг долгих запросов PostgreSQL в Prometheus"
date: 2025-02-17
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "/images/old/postgresql-monitoring.jpg"
description: "Предположим, что у вас есть PostgreSQL (AWS RDS или классический PostgreSQL server), Prometheus, postgres exporter и alertmanager с Grafana.

Стоит задача присылать уведомления о том, что в Postgres подвис запрос. Причина и т.п. нас мало интересует. Нужно просто сказать всем, кому положено, что есть проблема и ее нужно решить."
---

Предположим, что у вас есть PostgreSQL (AWS RDS или классический PostgreSQL server), Prometheus, postgres exporter и alertmanager с Grafana.

Стоит задача присылать уведомления о том, что в Postgres подвис запрос. Причина и т.п. нас мало интересует. Нужно просто сказать всем, кому положено, что есть проблема и ее нужно решить.

Для этого нам понадобится немного допилить exporter кастомными метриками. Делается это отдельным файлом конфигурации. Пусть это будет */etc/queries.yaml*.

```python
pg_long_running_queries:
  query: |
    SELECT current_database(),
           pid,
           EXTRACT(EPOCH FROM age(clock_timestamp(), query_start)) AS duration_seconds,
           state,
           query
    FROM pg_stat_activity
    WHERE state = 'active' AND now() - query_start > interval '5 minutes';
  metrics:
    - current_database:
        usage: "LABEL"
        description: "Name of DataBase"
    - duration_seconds:
        usage: "GAUGE"
        description: "Duration of long-running queries in seconds"
    - pid:
        usage: "LABEL"
        description: "Process ID"
    - state:
        usage: "LABEL"
        description: "Query state"
    - query:
        usage: "LABEL"
        description: "SQL Query"
```

```bash
[Unit]
Description=Postgres exporter
After=network.target

[Service]
User=postgres
Group=postgres
Type=simple
EnvironmentFile=/etc/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter \
        --config.file=/etc/postgres_exporter.yaml \
        --auto-discover-databases \
        --exclude-databases="rdsadmin,template0,template1,postgres,unused" \
        --collector.stat_statements \
        --collector.long_running_transactions \
        --extend.query-path=/etc/queries.yaml
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Конфиг самого exporter'a лежит в */etc/postgres_exporter.yaml* и окружение в */etc/postgres_exporter.env*.

Перезаупскаем postgres_exporter:

```bash
systemctl daemon-reload
service postgres_exporter restart
```

В результате мы в Prometheus должны увидеть метрику *pg_long_running_queries_duration_seconds*. По ней и строим вот такой алерт:

```yaml
      - alert: LongQueryDetected
        expr: pg_long_running_queries_duration_seconds{query !~ "VACUUM ANALYZE .*"}
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: Long running query detected (instance {{ $labels.instance }})
          description: "Long running query detected\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

```

Задача решена.
