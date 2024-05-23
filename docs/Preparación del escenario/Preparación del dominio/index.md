---
title: Preparación del dominio
layout: default
parent: Preparación del escenario
nav_order: 1
has_children: true
has_toc: false
---

En este paso, llevaremos a cabo la preparación y configuración del dominio. Estableceremos el dominio principal y configuraremos los controladores de dominio (DCs) para gestionar la autenticación y la política de seguridad de la red. En estos DCs se instalarán y configurarán servicios  como DHCP , DNS e IIS. También añadiremos un servidor secundario para proporcionar redundancia y balanceo de carga. Este servidor actuará como respaldo en caso de fallo del servidor principal y ayudará a distribuir la carga de trabajo. 
Se integrarán un par de clientes en el dominio para probar la configuración y extraer métricas de rendimiento para configurar nuestros dashboard.

