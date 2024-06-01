---
title: Creación de dashboards
layout: default
parent: Creación de Dashboards
nav_order: 3
has_children: false
has_toc: false
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

### Paneles de Grafana

#### Qué son los dashboard

Un Dashboard es como el tablero de instrumentos de un coche, proporciona información sobre el funcionamiento del vehículo, como la velocidad, las RPM y el nivel de combustible. De manera similar, los paneles de Grafana son interfaces visuales que permiten monitorizar y comprender el estado de los sistemas e infraestructuras.


Los datos pasan por una serie de procesos para convertirse en un dashboard.

1. Fuente de datos:
	Extraemos los datos con los exporters para ser recolectados.
	
2. Plugins:
	Usamos el plugin de Prometheus para recolectar las métricas e introducirlas en Grafana.

3. Consultas:
	Permiten filtrar y reducir los datos a un conjunto específico, mostrando solo la información relevante.

4. Transformaciones:
	 Manipulan los datos devueltos por una consulta para cambiar su formato o realizar operaciones adicionales. Son útiles para combinar campos, convertir tipos de datos o filtrar datos.

5. Dashboards:
	Paneles: Son los bloques de construcción básicos de un panel de control. Cada panel muestra datos en forma de gráficos, tablas o indicadores.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/Dashboard.png" />

#### Creación del primer dashboard


Antes de empezar el primer dashboard tengo que explicar que hay 3 tipos principales de datos para trabajar con ellos:

1. Vector instantáneo (instant vector):
	Representa un conjunto de series temporales, cada una con un único valor para un momento específico en el tiempo.
	Suele utilizarse para consultas que obtienen el estado actual del sistema en un momento dado.

2.  Vector de rango (range vector):
	Representa un conjunto de series temporales, cada una con varios valores medidos a lo largo de un intervalo de tiempo.
	Se utiliza para consultas que recuperan datos a lo largo de un período determinado, permitiendo analizar tendencias y patrones a lo largo del tiempo.

3. Escalar (scalar):
	Es un único valor numérico de punto flotante.
	Suele utilizarse para realizar cálculos matemáticos a partir de datos de series temporales o para representar valores agregados (por ejemplo, promedio, suma) a lo largo de un rango de tiempo.

He de añadir que existe un 4º tipo, que es el `String`, aunque este implementado no se utiliza actualmente.


Empezaremos creando, por ejemplo un panel para controlar el uso de la CPU:

`windows_cpu_time_total`
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/150.png" />
![[150.png]]

Con esa consulta nos da el tiempo de uso para la CPU, pero como no añadimos ningún filtro salen todos los datos de todos los equipos de los que obtenemos los datos, ahora filtraremos los datos para obtener sólo los del DC-01:

`windows_cpu_time_total{hostname="DC-01"}`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/151.png" />

Ahora estamos filtrando los datos sólo para el DC-01, vamos a afinar un poco más para filtrar el modo que queremos obtener, ya que las CPU tienen varios modos, filtraremos por el modo de reposo o `idle`:

`windows_cpu_time_total{hostname="DC-01",mode="idle"}`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/152.png" />

Vamos empezar a trabajar con rangos temporales, agregando la función `irate`, que calcula la tasa instantánea de aumento por segundo de la serie temporal en el vector de rango.

`(irate(windows_cpu_time_total{hostname="DC-01",mode="idle"}[2m]))`
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/153.png" />

Como tenemos 2 núcleos de procesador vamos a filtrar por un único núcleo.

`(irate(windows_cpu_time_total{hostname="DC-01",mode="idle",core="0,0"}[2m]))`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/154.png" />

Finalmente vamos hacer una opción para convertirlo en un porcentaje, y modificar la unidad de medida del dashboard a un porcentaje.

`100 -(irate(windows_cpu_time_total{hostname="DC-01",mode="idle",core="0,0"}[2m])) * 100`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/155.png" />

En este caso hemos calculado el uso de la CPU al restar la tasa de cambio del tiempo de inactividad de 100, la expresión intenta estimar el porcentaje de utilización de la CPU. Un mayor tiempo de inactividad indica una menor utilización de la CPU.


#### Creación de un dashboard dinámico

Hemos realizado un dashboard estático, ya que hemos especificado el ordenador que está monitoreando, pero esto no es útil si tenemos varios equipos y un servicio de discovery, razón por la que vamos a crear variables de entorno para tener dashboard dinámicos.

Para ello vamos a las opciones del dashboard.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/156.png" />

Dentro de las opciones vamos a `variables > Add variable`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/157.png" />

Vamos a crear tres variables relacionadas entre si: la `Instancia` (dirección IP:puerto), el `Hostname` y el `Job` (la etiqueta `job` sirve como un identificador clave para diferenciar entre diferentes instancias de un servicio o aplicación).

Está será la configuración de la variable `Job`:

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/158.png" />

Está será la configuración de la variable `Instance`:

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/159.png" />

Está será la configuración de la variable `Hostname`:

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/160.png" />

He creado una 4º variable para hacer un panel más adelante, llamada `show_hostname`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/161.png" />

Está es la relación entre las 4 variables.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/162.png" />

En el menú del dashboard ahora tendremos esta interfaz, donde podremos filtrar por Job de Prometheus, por Hostname o por IP.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/163.png" />

Ahora adaptaremos el dashboard para hacerlo dinámico cambiando las variables estáticas por dinámicas. 

`100 - (avg by (instance) (irate(windows_cpu_time_total{job=~"$job",mode="idle"}[2m])) * 100)`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/164.png" />

- Diferencias entre las consultas:

1. `100 -(irate(windows_cpu_time_total{hostname="DC-01",mode="idle",core="0,0"}[2m])) * 100`

2. `100 - (avg by (instance) (irate(windows_cpu_time_total{job=~"$job",mode="idle"}[2m])) * 100)`

En la 1º consulta es necesario especificar el Hostname y el núcleo del que queremos obtener las métricas.

En la 2º consulta ya filtramos al Hostname por la instancia y con la función `avg` calculamos automáticamente el uso medio de todos los núcleos del Hostname  

#### Creación de un dashboard con varias métricas

##### Cálculo de RAM

Vamos a calcular el porcentaje de RAM usada, para ello usaremos:

- `windows_cs_physical_memory_bytes`: Total de RAM en el sistema
- `windows_os_physical_memory_free_bytes`: Total de RAM libre

Así obtendríamos la relación entre las memorias.

`windows_os_physical_memory_free_bytes{job=~"$job"} / windows_cs_physical_memory_bytes{job=~"$job"}`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/165.png" />

Así obtendríamos el porcentaje de uso de la memoria RAM:

`100.0 - 100 * windows_os_physical_memory_free_bytes{job=~"$job"} / windows_cs_physical_memory_bytes{job=~"$job"}`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/166.png" />

##### Control de red

Hasta ahora sólo estábamos usando 1 query para obtener los Dashboards, pero podremos utilizar varias querys para obtener Dashboards más complejos, por ejemplo vamos a crear un Dashboard con dos querys, una para medir los datos enviados por las interfaces de red y otra query para los datos recibidos.

- Datos enviados:
`max by (instance) (irate(windows_net_bytes_sent_total{job=~"$job",nic!~"(?i:(.*(isatap|VPN).*))"}[2m]))*8`

- Datos recibidos:
`-max by (instance) (irate(windows_net_bytes_received_total{job=~"$job",nic!~"(?i:(.*(isatap|VPN).*))"}[2m]))*8`

En estas querys estamos usando un filtro de expresiones regulares para que no incluya las tarjetas de red con el patrón `isatap` o `VPN`, para evitar interfaces tunelizadas.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/167.png" />

##### Control de procesos

También hay funciones que nos permites hacer lo contrario que el ejemplo anterior, con una única query podemos obtener varios datos, por ejemplo:

`sum(windows_service_state{job=~"$job",instance=~"$instance"}) by (state)`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/168.png" />

Esto es posible porque la query agrupa los servicios por el estado.

