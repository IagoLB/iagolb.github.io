---
title: Base
layout: default
parent: Preparación del servidor de monitorización
grand_parent: Preparación del escenario
nav_order: 1
has_children: false
has_toc: false
---

Test-El sistema base utilizado será Debian 12, elegido por su reconocida robustez y estabilidad, características esenciales para un servidor de monitoreo confiable. Este entorno será la base sobre la cual se instalarán varias herramientas para la monitorización: Grafana, InfluxDB y Prometheus.

Para garantizar una instalación, configuración y uso adecuados de estas herramientas, también instalaremos los paquetes necesarios. Los paquetes específicos que se requieren son `apt-transport-https`, `software-properties-common` y `wget`.

Además, será necesario crear usuarios dedicados para la ejecución de estos servicios, lo cual mejorará la seguridad y gestión de los mismos.