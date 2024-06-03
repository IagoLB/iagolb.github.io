---
title: Creación de alertas
layout: default
parent: Creación de Dashboards
nav_order: 4
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

# Alertas en Grafana

**¿Qué son las alertas?**

Las alertas en Grafana son notificaciones automáticas generadas cuando ciertas condiciones, definidas previamente en los paneles de monitoreo, se cumplen, por ejemplo cuando el uso de RAM excede un porcentaje Grafana nos enviaría un aviso por los medios que hayamos configurado.

## Envió de alertas

Lo primero para la creación de alertas en Grafana es definir como serán enviadas las alertas, para ello vamos a`Home > Alerting > Contact Point` y pulsaremos en `Add contact point`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/210.png" />

Le asignamos un nombre y escogemos el método por el que enviaremos las alertas, en mi caso elegiré `telegram`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/211.png" />

Para ello tendremos que configurar un bot de telegram, lo haremos usando el bot `BotFather`.

- Le indicaremos que queremos crear un bot con el comando `/newbot`

- Le asignaremos un nombre al bot, en mi caso `GrafanaProyectoBot`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/212.png" />

Iremos al bot y lo inicializaremos con el comando `/start`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/213.png" />

Con el bot ya inicializado le mandamos un mensaje y accedemos a la ruta "https://api.telegram.org/botTOKEN/getupdates"

Con esto obtendremos el id del bot.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/214.png" />

Con el TOKEN y el id del bot volvemos a Grafana, completaremos las partes que nos faltaban.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/215.png" />

Pulsaremos el botón de test, para enviar una notificación, y si hemos configurado todo correctamente nos llegará a telegram un mensaje como este:

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/216.png" />

Ya hemos creado el método de envió, ahora necesitamos establecerlo por defecto, para ello iremos a `Home > Alerting > Notification policies`.

Por defecto hay creada una política llamada `Default policy`, en ella pulsaremos en los 3 puntos del final y en la opción de `Edit` y en `Default contact point` seleccionamos la que acabamos de crear.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/217.png" />

Con este ya tendremos todo listo para la configuración de las alertas.


## Configuración de las alertas


Para crear las alertas primero necesitaremos un sitio para organizarlas, para ello en `Home > Dashboard` pulsaremos en nuevo y en `New Folder` y le daremos un nombre.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/218.png" />

Ahora iremos a nuestro Dashboard e iremos a un panel para poner una alerta, por ejemplo monitorizaremos el panel de `Uso de CPU`.

Para ello iremos a la sección de alertas > `New alert rule`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/219.png" />

Establecemos la condición, en este caso la alerta saltará cuando el uso de la CPU superé el 80%

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/220.png" />

En `Set evaluation behavior` escogemos el directorio donde se guardará la alerta, en `Evaluation group` escogeremos `New valuation group`, ya que aún no hemos creado ningún grupo y en `evaluation interval` pondremos el tiempo durante el cual evalúa la condición para que salte la alerta, lo estableceremos en 30 segundos.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/221.png" />

El `Pending period`  define un retraso antes de que se active una alerta, estableceremos  el `Pending period` en 90 segundos, para explicarlo:

- La evaluación se realizará de la siguiente manera:

	- [00:30] Primera evaluación: condición no cumplida.

	- [01:00] Segunda evaluación: condición incumplida. Inicios de contador pendientes. La alerta comienza pendiente.

	- [01:30] Tercera evaluación: condición incumplida. Contador pendiente = 30s. Estado pendiente.

	- [02:00] Cuarta evaluación - condición incumplida. Contador pendiente = 60 s Estado pendiente.

	- [02:30] Quinta evaluación - condición incumplida. Contador pendiente = 90s. La alerta comienza a dispararse.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/222.png" />

En `Configuration labels and notifications` estableceremos el Contac point.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/223.png" />

Si intentamos guardar la alerta nos saltará el mensaje `You cannot use time series data as an alert condition, consider adding a reduce expression.` esto es porque evalúa valores únicos en cada punto, y el panel actual es un `Time series`, por lo cuál deberemos adaptar la query:

`100 - avg by (instance) (irate(windows_cpu_time_total{job=~"Server 1",mode!="idle"}[2m]))`

Con esa query medimos directamente el tiempo de actividad, al excluir el tiempo inactivo.

Tras esto si que nos dejará guardar y nos aparecerá la alerta en el panel y un corazón al lado del titulo que cambiara de color según el estado de la alarma.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/224.png" />

Usaremos el software Prime95 para forzar el uso de la CPU y que salte la alarma, tras lo cual recibiremos una alerta mediante telegram.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/225.png" />

Pararemos el software y cuando finalice el intervalo recibiremos un aviso de que la alarma esta resuelta.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/226.png" />

## Alertas para seguridad

Podremos también crear alertas para la seguridad, por defecto `windows exporter` no nos da datos de los puertos abiertos, pero podemos crear un script en powershell que obtenga los puertos y los guarde en un fichero, y decirle a `windows exporter` que use ese fichero, para ello:

```powershell
$ports = Get-NetTCPConnection -State Listen | Select-Object -Unique -Property LocalPort 
$metrics = @()
foreach ($port in $ports) {
    $metrics += "open_ports{port=`"$($port.LocalPort)`"} 1"
}
$metrics -join "`n" | Set-Content -Path "C:\Exporter\test\ports.prom"
```

Usaremos el programador de tareas para que se ejecute cada 60 segundos y modificaremos el archivo `config.yml` para añadir el `textfile` como `collector` .

```config.yml
collectors:
  enabled: cpu,cpu_info,cs,logical_disk,memory,net,os,process,service,system,tcp,iis,dns,dhcp,textfile
log:
  level: info
```

Nuevo servicio:
```powershell
try { 
  $servicio = (Get-Service -Name node_exporter -ErrorAction SilentlyContinue) -ne $null #comprueba si existe el servicio
} catch {  
  $servicio = $null
}

if (!(Test-Path -Path "c:\Exporter")) {  #comprueba si existe la ruta
  New-Item -ItemType Directory "c:\Exporter"
}

if (!$servicio) {  #sino existe el servicio lo crea

  try {
    Copy-Item "\\DC-01\exporter\exporter.exe" "c:\Exporter\exporter.exe" -Force
    Copy-Item "\\DC-01\exporter\config.yml" "c:\Exporter\config.yml" -Force
    } catch {        
    Copy-Item "\\DC-02\exporter\exporter.exe" "c:\Exporter\exporter.exe" -Force
    Copy-Item "\\DC-02\exporter\config.yml" "c:\Exporter\config.yml" -Force
    }
    
  New-Service -Name node_exporter -DisplayName "node_exporter" -BinaryPathName "c:\Exporter\exporter.exe --config.file=c:\Exporter\config.yml --log.file=c:\Exporter\log.txt --collector.textfile.directories=C:\Exporter\test\" -StartupType Automatic
    
  Start-Service -Name node_exporter  -InformationAction SilentlyContinue 
}	
```

En Grafana crearemos un nuevo panel en formato `Time series` con la query:

`count(open_ports{instance=~"$instance"})`

Esa query nos indica el número de puertos abiertos en la `instance actual`

Ahora procederemos a crear una alerta, por ejemplo para monitorizar el puerto 4444, ya que es el puerto por defecto de `Metasploit`, para ello empezaremos creando una alerta con la siguiente query:

`count(open_ports{port="4444"})`

Esa query cuenta el número de puertos abiertos cuyo número de puerto es igual a 4444.

Añadiremos una query para la alerta que sea:

`WHEN count() OF query(B) IS ABOVE 0`, para que cuando la query anterior sea mayor que 0 salte la alerta.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/227.png" />

Configuraremos el resto de valores igual que el apartado anterior, excepto al final que pondremos una breve descripción en `Summary` para entender la alerta.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/228.png" />

Ahora forzamos la apertura del puerto 4444 y nos llegará la alerta por telegram.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/229.png" />

Y una vez cerrado el puerto y pasado el tiempo nos saldrá el aviso de que la alerta ha finalizado.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/230.png" />

Se pueden crear alertas para la mayoría de los paneles, pero hay ciertos formatos que no admiten alertas, recomiendo revisar la configuración de Grafana para tener información actualizada de que paneles admites alertas y cuales no.