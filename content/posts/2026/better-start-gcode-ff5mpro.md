---
title: "Улучшенный стартовый GCODE для Flash Forge Adventurer 5M Pro"
date: 2026-03-19
author: "Silver Ghost"
tags: ["3d печать", "flashforge"]
image: "/images/2026/ffa5mpro.jpg"
description: "Улучшенный стартовый GCODE для Flash Forge 5M Pro"
---

Просто замените в слайсере стартовый GCode на новый и пластик при старте не будет так налипать на сопло.
Очистка будет проходить лучше.

```GCode
M190 S[bed_temperature_initial_layer_single]
M104 S[nozzle_temperature_initial_layer]
G90
M83
G1 E-0.2 F800
G1 X110 Y-110 Z5 F6000 ; перемещение в правый нижний угол с опусканием сопла
G1 Z0.2 F1200 ; опускаем сопло к столу на высоту 0.2 мм
G1 E2 F800
G1 X20 E9 F1000 ; печать интро-линии справа налево
G1 X-60 E12.5 F1000 ; продолжение печати линии
G1 E-0.5 F800 ; ретракт после завершения линии
G92 E0
```
