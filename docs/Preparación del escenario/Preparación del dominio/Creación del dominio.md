---
title: Creación del dominio
layout: default
parent: Preparación del dominio
grand_parent: Preparación del escenario
nav_order: 2
has_children: true
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

### Preparando la base

La creación del dominio se hará con la siguiente configuración:

- **Controlador principal del dominio** `Windows Server 2022`:
El controlador principal del dominio gestiona la autenticación de usuarios y dispositivos, administra las políticas de grupo, y mantiene la base de datos principal del Active Directory. Proporciona servicios DNS y DHCP para la resolución de nombres y asignación de direcciones IP en la red.

- **Controlador secundario del dominio** `Windows Server 2022`:
El controlador secundario del dominio replica la base de datos del Active Directory para redundancia, apoya en la autenticación y aplicación de políticas de grupo, y actúa como un servidor DNS adicional, también tendrá configurado el IIS y una pequeña base de datos MySQL para simular un servicio de dominio. Proporciona balanceo de carga y respaldo en caso de fallo del controlador principal.

- **Clientes** `Windows 10 PRO`:
Los clientes son dispositivos que se conectan al dominio para acceder a recursos de red, aplicar políticas de grupo, y utilizar servicios DNS y DHCP proporcionados por los controladores de dominio.

### Creación del dominio

Inicializamos el controlador principal del dominio, de ahora en adelante `DC-01`, para crear el dominio abrimos la `Administración del servidor`, pulsamos en `Administrar` y en `Agregar Roles y características` y se nos abrirá la siguiente ventana, donde elegiremos la opción de: `Instalación basada en características o en roles`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/25.png" />

Elegimos el servidor de destino, por ahora sólo tendremos a `DC-01`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/26.png" />

Elegimos los roles que instalaremos, por ahora sólo instalaremos el rol de: `Servicios de dominio de Active Directory`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/27.png" />

En caso de querer alguna características la añadiríamos en esta pestaña, por ahora no añadiremos ninguna mas que las que vienen por defecto con los `Servicios de dominio de Active Directory`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/28.png" />

En la siguiente pestaña obtendremos una pequeña descripción del rol que estamos instalando.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/29.png" />

Finalmente obtendremos un resumen de las herramientas que se agregan con el rol que estamos añadiendo, debemos revisar que estemos instalando lo necesario para nuestro objetivo y pulsamos en instalar.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/30.png" />

Cuando finalice la instalación nos saldrá la opción de `Promover este servidor a controlador de dominio`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/31.png" />

Tras pulsarla nos aparecerán 3 opciones principales:

1.  Agregar un controlador de dominio a un dominio existente:
	Esta opción se usa cuando ya hay un dominio de Active Directory configurado y queremos agregar otro servidor que funcione como controlador de dominio para ese dominio.
	
2. Agregar un nuevo dominio a un bosque existente:

	Esta opción se usa cuando ya hay un bosque de Active Directory configurado y queremos agregar un nuevo dominio a ese bosque.

3. Agregar un nuevo bosque:
	Esta opción se usa cuando no hay ningún dominio o bosque de Active Directory configurado. Esta es la opción que se usa para crear la primera instancia de Active Directory en una red.


Por lo tanto elegiremos la 3º opción y nombraremos nuestro dominio como `DamBeaver`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/32.png" />

Dejaremos las opciones por defecto y crearemos una contraseña para el administrador de este dominio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/33.png" />


Introducimos las credenciales para la creación de la delegación dns, está se crea para, añadiendo las direccion IP del DC a un cliente este pueda resolver el nombre del dominio y unirse a él.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/34.png" />

Asignamos un nombre `NetBios` al dominio, esto es un identificador único de 16 caracteres que se utiliza para identificar un dominio de Windows en una red local.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/35.png" />

Ahora tendremos la opción de modificar las rutas de:

- Carpeta de la base de datos: 
	La carpeta de la base de datos de Active Directory (AD) almacena la información fundamental que define el dominio, incluyendo usuarios, grupos, computadoras, impresoras y otros recursos

- Carpetas de archivos de registro: 
	Las carpetas de archivos de registro de Active Directory almacenan eventos y mensajes relacionados con el funcionamiento del dominio.
	
- Carpeta SYSVOL:
	SYSVOL (SYStem VOlume) es una carpeta compartida replicada en todos los controladores de dominio de un dominio de Windows. Almacena una copia de los archivos de directiva de grupo, scripts de inicio de sesión y otros archivos críticos para el funcionamiento del dominio.

Dejaremos las rutas por defecto y seguiremos con la instalación.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/36.png" />

Ahora nos aparecerá una lista con todas las opciones elegidas, y la posibilidad de obtener un script para replicar esa configuración especifica, este sería nuestro script.

```powershell
# Script de Windows PowerShell para implementación de AD DS

Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$true `
-DatabasePath "C:\Windows\NTDS" `
-DnsDelegationCredential (Get-Credential) `
-DomainMode "WinThreshold" `
-DomainName "DamBeaver.com" `
-DomainNetbiosName "DAMBEAVER" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
```
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/37.png" />

Finalmente Windows hace una comprobación del sistema y de las opciones, nos dará las advertencias correspondientes, y en caso de que la comprobación sea favorable nos permitirá realizar la instalación.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/38.png" />

Tras finalizar la instalación se reiniciará automáticamente y si todo ha ido bien durante la instalación debería salirnos la opción de iniciar sesión como administrador, tras lo cual podremos empezar a configurar el dominio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/39.png" />

### Creación del segundo controlador del dominio

Para tener un servicio resiliente y con tolerancia a fallos crearemos un segundo controlador de dominio que se encargará de proporcionar redundancia, escalabilidad y mejoras en el rendimiento para la gestión de usuarios, grupos..., etc, al dividir la carga entre dos servidores.

Para añadir el segundo controlador de dominio, de ahora en adelante `DC-02`, necesitamos configurar sus DNS apuntando a `DC-01` para poder resolver el nombre de dominio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/40.png" />

Una vez con el DNS apuntando a , vamos a: `Sistema> Cambiar el nombre de este equipo (Avanzado) > Cambiar`. En dominio pondremos el nombre del dominio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/41.png" />

Necesitamos introducir las credenciales de un usuario con permisos para añadir un nuevo equipo al dominio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/42.png" />

Si hemos introducido las credenciales correctas de un usuario válido nos saldrá un mensaje confirmando que el equipo forma parte del dominio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/43.png" />

Tras reiniciar ya podremos iniciar sesión con `DC-02`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/44.png" />

Una vez iniciada la sesión vamos a convertirlo en controlador de dominio, para esto vamos a `Administrador del servidor > Administar > Agregar Roles y características > Instalación basada en roles` y agregamos los `Servicios de dominio de Active Directory` 

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/45.png" />

Dejaremos las opciones por defecto hasta que podamos instalar el rol.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/46.png" />

Una vez finalizada la instalación lo promovemos a `Controlador de dominio`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/47.png" />

Dado que el dominio ya existe, en este caso elegiremos la opción de: ` Agregar un controlador de dominio a un dominio existente`

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/48.png" />

En la siguiente pantalla dejamos las opciones por defecto e indicamos las credenciales.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/49.png" />

Dado que aún no hemos instalado el servicio DNS en el servidor principal no podemos crear un 
segundo servidor de nombres.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/50.png" />

Especificamos desde que DC debería duplicar la información.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/51.png" />

Dejamos las opciones por defecto hasta el apartado de: `Revisar opciones`, donde guardaremos el script de instalación.
```powershell
# Script de Windows PowerShell para implementación de AD DS
Import-Module ADDSDeployment
Install-ADDSDomainController `
-NoGlobalCatalog:$false `
-CreateDnsDelegation:$false `
-CriticalReplicationOnly:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainName "DamBeaver.com" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SiteName "Default-First-Site-Name" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
```
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/52.png" />

Dejamos que compruebe los requisitos y en caso de ser favorables proseguiremos con la instalación.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/53.png" />

Tras finalizar la instalación el servidor se reiniciará, si todo ha ido correctamente al comprobar los DC del dominio deberían estar `DC-01` y `DC-02`.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/54.png" />

### Servicio DHCP

El servicio DHCP será instalado en `DC-01` con conmutación por error en `DC-02`.

Para la instalación del servicio DHCP:

- En el servidor Windows, vamos al `Administrador del servidor > Administar > Agregar Roles y características.`
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/55.png" />

Escogemos el tipo de instalación basada en características o en roles.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/56.png" />

Seleccionamos el equipo en el que vamos a instalar el rol.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/57.png" />

Seleccionamos el rol de DHCP.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/58.png" />

Dejamos las opciones por defecto hasta instalar el rol.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/59.png" />

Una vez finalizada la instalación, tendremos la opción de configurar el servicio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/60.png" />

Debemos autorizar el servicio en el servidor.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/61.png" />

Una vez autorizado procederemos a configurar el servicio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/62.png" />

En la parte de Herramientas de la administración del servidor debería salirnos ahora el servicio DHCP.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/63.png" />

Dentro del DHCP, hacemos click derecho en IPv4 y seleccionamos Ámbito nuevo.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/64.png" />

Asignamos un nombre al nuevo ámbito.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/65.png" />

 Asignamos el rango de direcciones IP que se asignarán, así como su máscara.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/66.png" />

Seleccionamos si queremos excluir alguna dirección, en mi caso lo dejaré por defecto.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/67.png" />

Seleccionamos la duración de cada concesión.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/68.png" />

Ya estaría finalizada la configuración principal, pero nos avisa si queremos configurar más opciones, yo continuaré con la configuración.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/69.png" />

Agregamos la puerta de enlace, este paso es muy importante, ya que un problema en la puerta de enlace es la forma más fácil de aislar un equipo.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/70.png" />

Agregamos los servidores DNS, los cuales configuraremos en su correspondiente sección.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/71.png" />

Omito la configuración del WINS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/72.png" />

Finalmente el ámbito esta configurado y lo activamos.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/73.png" />

Configuraremos la conmutación para el supuesto de que se caiga DHCP principal pulsando click derecho sobre el ámbito a compartir.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/74.png" />

La conmutación puede hacerse para todos los ámbitos del servidor, para un subconjunto de ellos o uno solamente, ya que se puede seleccionar esta opción desde IPv4, al tener sólo un ámbito sale pre-seleccionado por defecto.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/75.png" />

Ponemos la IP del otro servidor DHCP, en este caso dejaremos en `DC-02` el servicio instalado, ya que no es necesario configurarlo.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/76.png" />

- Configuramos las opciones de conmutación
	- Plazo máximo para clientes: Esta opción nos permite definir cuanto tiempo espera uno de los DHCP si su compañero no presta el servicio, tras la espera que definamos en el parámetro, el otro tomará el control por completo del ámbito.
	
	- Equilibrio de carga: Si escogemos Equilibrio de carga ambos servidores distribuyen IP’s a los clientes. En este caso debemos establecer qué porcentaje tendrá cada uno, siendo el valor por defecto 50% para ambos. Si por el contrario elegimos Espera activa, uno de los servidores actúa como primario y otro como secundario. El primario es el que lleva el peso de la concesión de IPs y el secundario esta en modo de espera por si el primario falla.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/77.png" />

Finalmente nos aparece una lista con la configuración elegida.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/78.png" />

Tras finalizar nos saldra una ventana avisando si se pudo realizar la configuración correctamente o no, en este caso se realizo correctamente.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/79.png" />

Veremos en el servidor secundario como nos aparecio el ámbito tras realizar la conmutación por error.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/80.png" />

### Servicio DNS

El servicio DNS será instalado en `DC-01` con `DC-02` como servidor secundario.

Para instalar el servicio DNS realizamos la misma configuración que en el DHCP hasta la parte de roles de servidor, donde en este caso seleccionaremos DNS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/81.png" />

Le damos a siguiente hasta que tengamos la opción de instalar.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/82.png" />

Para configurarlo en la parte de Herramientas de la administración del servidor debería salirnos ahora el servicio DNS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/83.png" />

En el administrador de DNS hacemos click derecho en “Zonas de búsqueda directa” y pulsamos en zona nueva.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/84.png" />

Le damos a siguiente en el asistente.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/85.png" />

Escogemos el tipo de zona que queremos, en este caso una zona principal.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/86.png" />

Escogemos como queremos que sea la replicación de la zona DNS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/87.png" />

Escribimos el nombre que tendra esta zona.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/88.png" />

Al tener el servidor un servicio DHCP ya configurado vamos a permitir actualizaciones dinamicas seguras, esto significa que los servidores DHCP podrán realizar actualizaciones sobre los registros DNS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/89.png" />

Seleccionamos finalizar la creación de la zona.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/90.png" />

Añadimos un registro para el DC-02 y permitimos que se le transfiera la zona.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/91.png" />
<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/92.png" />

Ahora agregaremos la zona de búsqueda inversa, para resolver IP\`s a nombres.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/93.png" />

Seleccionamos zona principal.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/94.png" />

Seleccionamos como queremos que se repliquen los datos.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/95.png" />

Seleccionamos si la búsqueda será para direcciones IPv4 ó IPv6, en este caso IPv4.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/96.png" />

Seleccionamos la parte de la red correspondiente a la máscara.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/97.png" />

Permitimos actualizaciones dinámicas para esta zona.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/98.png" />

Finalizamos el asistente.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/99.png" />

Marcamos y desmarcamos los registros PTR en la zona de búsqueda directa para que se actualizen en la zona inversa.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/100.png" />

Volvemos a añadir en la zona secundaria a DC-02 como servidor de nombres y habilitamos la transferencia de zona.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/101.png" />

En el caso de que nuestros servidores no sepan resolver una petición dns y no queramos que vayan a los servidores raíz a preguntar necesitaremos un reenviador, este se configura haciendo click derecho sobre DC-01  y propiedades.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/102.png" />

Vamos a la pestaña de reenviadores y ponemos, por ejemplo, los servidores de google.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/103.png" />


### Servicio IIS

El servicio IIS será instalado exclusivamente en `DC-02`.

Para instalar el servicio IIS realizamos la misma configuración que en el DHCP hasta la parte de roles de servidor, donde en este caso seleccionaremos IIS.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/104.png" />

En servicios de rol seleccionamos a mayores de las ya seleccionadas:
- Autentificación básica
- Autentificación de Windows
- Autorización para URL
- Restricciones de ip y dominio
- CGI

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/105.png" />

Esperamos a que instale y cuando finalice accedemos al servicio IIS.

!<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/106.png" />

Tendremos un sitio por defecto llamado “Default Web Site” que renombraremos a intranet haciendo click derecho sobre su icono y eligiendo la opción de cambiar nombre.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/107.png" />
Iremos a autentificación y deshabilitamos la Autentificación anónima y habilitamos la Autentificación de Windows.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/108.png" />

En reglas de autorización indicamos que es una página sólo para los usuarios del dominio.

<img src="https://raw.githubusercontent.com/IagoLB/iagolb.github.io/main/images/109.png" />

Con esto dejamos la base lista para desplegar algunas aplicaciones en el dominio y desplegar la extracción de métricas.

