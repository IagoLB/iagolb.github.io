---
layout: default
title: Software de monitorización
parent: Introducción
nav_order: 3
---
# Estructura de navegación
{: .no_toc }

<details open markdown="block">
  <summary>
    Tabla de contenidos
  </summary>
  {: .text-delta }
- TOC
{:toc}
</details>
# Software utilizado en este proyecto

## Grafana

### ¿Qué es Grafana?

Grafana es una plataforma de visualización de datos de código abierto y altamente personalizable que te permite crear paneles de control dinámicos e interactivos para visualizar y analizar métricas, registros y eventos de una amplia variedad de fuentes. Se utiliza ampliamente en el ámbito de la monitorización de sistemas informáticos, DevOps y análisis de negocio.

### ¿Qué hace Grafana?

Grafana te permite:

- **Conectar con diferentes fuentes de datos**: Prometheus, InfluxDB, Elasticsearch, Graphite, SQL, entre otras.

- **Crear paneles de control personalizados**: Combinar diferentes tipos de gráficos, tablas y otros elementos para visualizar datos de forma clara y concisa.

- **Analizar datos**: Aplicar filtros, funciones y análisis estadísticos para obtener información valiosa de tus datos.

- **Compartir paneles de control**: Colaborar con otros usuarios y compartir tus paneles de control para facilitar la toma de decisiones.

- **Configurar alertas:** Recibir notificaciones cuando se detecten eventos o valores anormales en tus datos.


## Prometheus

### Que es Prometheus

Prometheus es un sistema de recolección y consulta de métricas de código abierto, altamente flexible y escalable. Se utiliza para recopilar métricas de una amplia variedad de fuentes, incluyendo sistemas operativos, aplicaciones, contenedores y servicios en la nube.

### ¿Qué son las métricas?

Las métricas son valores numéricos que representan el estado o rendimiento de un sistema o aplicación. Por ejemplo, algunas métricas comunes incluyen el uso de la CPU, la memoria RAM, el tráfico de red, el tiempo de respuesta de las aplicaciones y la tasa de errores.

### ¿Cómo funciona Prometheus?

Prometheus funciona recopilando métricas de diferentes fuentes a través de exporters. Los exporters son herramientas especializadas que se instalan en las fuentes de datos y se encargan de exportar las métricas en formato Prometheus. Una vez que Prometheus ha recogido las métricas, las almacena en una base de datos interna de series temporales.

## Influxdb

### ¿Qué es InfluxDB?

InfluxDB es una base de datos de series temporales de código abierto y altamente escalable diseñada para almacenar y consultar grandes volúmenes de datos de series temporales. Se utiliza ampliamente en el ámbito de la monitorización de sistemas informáticos, DevOps y análisis de negocio.

### ¿Qué son los datos de series temporales?

Los datos de series temporales son datos que se recopilan a lo largo del tiempo y que tienen un timestamp asociado a cada valor. Por ejemplo, algunos ejemplos de datos de series temporales incluyen:

- **Tráfico de red**: La cantidad de datos que se envían y reciben por una red cada segundo.

- **Rendimiento de las aplicaciones**: El tiempo de respuesta de una aplicación web cada solicitud.

- **Monitorizar el rendimiento del hardware**: Los datos de series temporales sobre el uso de la CPU, la memoria RAM o el disco.


### ¿Cómo funciona InfluxDB?

InfluxDB almacena los datos de series temporales en buckets. Los buckets son contenedores lógicos que agrupan datos relacionados por un criterio específico, como el nombre del host, la aplicación o el tipo de métrica. Cada bucket tiene una o más series, que son secuencias de valores de datos ordenadas cronológicamente.

## Windows Exporter

### ¿Qué es Windows Exporter?
Windows Exporter es un componente de código abierto que forma parte del ecosistema de Prometheus, un sistema de recolección y consulta de métricas.

### ¿Qué hace Windows Exporter?

Su función principal es recolectar métricas de rendimiento y estado de un sistema Windows. Estas métricas pueden incluir:

- **Uso de CPU y memoria**: Carga del procesador, uso de memoria RAM, memoria libre, etc.
- **Rendimiento del disco**: Espacio en disco disponible, velocidad de lectura y escritura, etc.
- **Rendimiento de la red**: Tráfico de red entrante y saliente, errores de red, etc.
- **Estado de los procesos**: Número de procesos en ejecución, uso de CPU por proceso, memoria utilizada por proceso, etc.
- **Eventos del sistema**: Registros de eventos de Windows, errores del sistema, etc.

### ¿Cómo funciona Windows Exporter?

Windows Exporter se ejecuta como un servicio de Windows y se comunica con Prometheus a través de una interfaz HTTP. Para recolectar las métricas, utiliza la API de Windows Management Instrumentation (WMI) y otros métodos de acceso a datos de Windows.