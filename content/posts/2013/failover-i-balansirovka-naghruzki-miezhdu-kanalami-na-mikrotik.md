---
title: "Failover и балансировка нагрузки между каналами на Mikrotik"
date: 2013-01-02
author: "Silver Ghost"
tags: ["Самохостинг"]
image: "https://images.unsplash.com/photo-1494783367193-149034c05e8f?crop&#x3D;entropy&amp;cs&#x3D;tinysrgb&amp;fit&#x3D;max&amp;fm&#x3D;jpg&amp;ixid&#x3D;M3wxMTc3M3wwfDF8c2VhcmNofDF8fHJvdXRlfGVufDB8fHx8MTczOTgxMTI5NHww&amp;ixlib&#x3D;rb-4.0.3&amp;q&#x3D;80&amp;w&#x3D;2000"
description: "Положу тут рецептик балансировки нагрузки без BGP с failover&#x27;ом на
Mikrotik&#x27;е:

;; Balancing
add chain&#x3D;prerouting action&#x3D;mark-connection new-connection-mark&#x3D;routeKS passthrough&#x3D;no connection-state&#x3D;new src-address&#x3D;192.168.33.0/24 nth&#x3D;2,1
add chain&#x3D;prerouting action&#x3D;mark-routing new-routing-mark&#x3D;routeKS passthrough&#x3D;yes src-address&#x3D;192.168.33.0/24 connection-mark&#x3D;routeKS
add"
---

Положу тут рецептик балансировки нагрузки без BGP с failover'ом на
Mikrotik'е:

`;; Balancing
add chain=prerouting action=mark-connection new-connection-mark=routeKS passthrough=no connection-state=new src-address=192.168.33.0/24 nth=2,1
add chain=prerouting action=mark-routing new-routing-mark=routeKS passthrough=yes src-address=192.168.33.0/24 connection-mark=routeKS
add chain=prerouting action=mark-connection new-connection-mark=routeMX passthrough=yes connection-state=new src-address=192.168.33.0/24
add chain=prerouting action=mark-routing new-routing-mark=routeMX passthrough=yes src-address=192.168.33.0/24 connection-mark=routeMX

;; Routing
add dst-address=0.0.0.0/0 gateway=(адрес первого шлюза) scope=255 target-scope=10 routing-mark=routeKS
add dst-address=0.0.0.0/0 gateway=(адрес второго шлюза) scope=255 target-scope=10 routing-mark=routeMX
`Пояснять тут особо нечего.
