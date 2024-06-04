---
title: Seguridad de los datos
layout: default
parent: Seguridad
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

# Backups

Todo nuestro sistema se basa en la obtención de métricas, su uso y gestión, por lo cual tener nuestros datos es critico, afortunadamente `influxdb` ya tiene esto en cuenta y tiene un comando para la realización de backups, como no se recomienda guardar los backups en la misma máquina compartiremos una carpeta desde `DC-01`, la montaremos en nuestro servidor de monitorización y realizaremos backups periódicos mediante una tarea cron, para ello:

1. Crearemos una carpeta de backups y la compartiremos desde `DC-01`, gestionando los permisos para que se puedan guardar las copias.
2. Instalaremos `cifs-utils` y `smbclient` para la conexión desde el servidor de monitorización.
3. Crearemos una carpeta donde montar la carpeta compartida  la carpeta y la montaremos con el comando `sudo mount -t cifs //172.19.0.10/backups /mnt/backup -o username="administrador",password="abc123.",vers=3.0`, podemos también pasar el usuario y contraseña por un fichero.
4. Crearemos una entrada en fstab para que la ubicación este montada permanentemente.
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/256.png" />


<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/257.png" />

5. Comprobamos que si creamos una carpeta en Windows aparece en la ubicación de Linux.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/258.png" />

6. Crearemos el backup de InfluxDB con el comando

`influx backup --org-id c184b96027631c2a --token 2TxN_pBWuIw5MsZDOeSViU2HZqHUKe0W6iCuxGUOXaAvnMtX8B2WJP_EowJ7oN7SQve1F9qYVoLLRPJG3NsKAQ==  --skip-verify /mnt/backup`

En caso de que quisiésemos solamente copiar el backup de Prometheus usaríamos el comando:

`influx backup --org-id c184b96027631c2a --token 2TxN_pBWuIw5MsZDOeSViU2HZqHUKe0W6iCuxGUOXaAvnMtX8B2WJP_EowJ7oN7SQve1F9qYVoLLRPJG3NsKAQ== --bucket prometheus --skip-verify /mnt/backup`

Tras ejecutarlo veremos que nos ha creado varios archivos.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/259.png" />

Vamos a optimizar la creación de backups con un script:

```bash
#!/bin/bash
influx backup --org-id c184b96027631c2a --token 2TxN_pBWuIw5MsZDOeSViU2HZqHUKe0W6iCuxGUOXaAvnMtX8B2WJP_EowJ7oN7SQve1F9qYVoLLRPJG3NsKAQ== --skip-verify /opt/backup


BACKUP_SOURCE="/opt/backup"     
BACKUP_DEST="/mnt/backup"       
MAX_BACKUPS=7                       
DATE=$(date +%Y%m%d%H%M%S)        


tar -czf "$BACKUP_DEST/backup-$DATE.tar.gz" -C "$BACKUP_SOURCE" .

if [ $? -eq 0 ]; then
  
  rm -rf "$BACKUP_SOURCE"/*
else
  echo "Error"
  exit 1
fi

# Contar el número de backups y eliminar los más antiguos si es necesario
BACKUP_COUNT=$(ls "$BACKUP_DEST"/backup-*.tar.gz | wc -l)

if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
  # Eliminar los backups más antiguos
  OLDEST_BACKUP=$(ls "$BACKUP_DEST"/backup-*.tar.gz | sort | head -n 1)
  rm "$OLDEST_BACKUP"
fi
```

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/260.png" />

Y si lo comprobamos veremos que se ha creado en el servidor.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/261.png" />

Si ahora borrásemos un bucket por error:

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/262.png" />

Sería tan fácil como descomprimir el comprimido y restaurarlo.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/263.png" />

Volverá estar operativo con todos los datos a fecha del último backup-

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/264.png" />

Por último crearíamos la tarea en cron, y se ejecutaría todos los días a las 00:00.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/265.png" />