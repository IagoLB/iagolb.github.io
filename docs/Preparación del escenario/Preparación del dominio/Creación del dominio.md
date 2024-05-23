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

Inicializamos el controlador principal del dominio, de ahora en adelante `DC-01`