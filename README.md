# Windows 7 KDE Installer

Un instalador sencillo para darle a **KDE Plasma 6 o superior** una apariencia inspirada en Windows 7, sin compilar un shell alternativo ni sustituir componentes centrales de KDE.

El script descarga e instala los paquetes de apariencia de sus proyectos originales:

- [Windows 7 Enhanced](https://github.com/leonkhoo123/windows-7-enhanced): tema global de Plasma, colores Aero, decoración de ventanas, tema del escritorio y tema Kvantum.
- [Windows 7 Enhanced Icons](https://github.com/leonkhoo123/windows-7-enhanced-icons): iconos del sistema.
- [Kvantum](https://github.com/tsujan/Kvantum): estilo de widgets Qt necesario para que los controles también sigan el aspecto del tema.

## Instalación rápida (un comando)

Desde una terminal dentro de tu sesión gráfica de KDE Plasma 6+, puedes descargar y ejecutar el instalador con:

```bash
curl -fsSL https://raw.githubusercontent.com/DanielBarrientos727/windows7-kde-installer/main/quick-install.sh | bash
```

El comando necesita **curl, Bash y Git**. El script descarga o actualiza una copia del proyecto en `$XDG_DATA_HOME/programs/windows7-kde-installer` (normalmente `~/.local/share/programs/windows7-kde-installer`) y abre el instalador principal.

No se ejecuta como `root`; solo pedirá privilegios administrativos para instalar Kvantum mediante el gestor de paquetes. El instalador solicita confirmación antes de cambiar la apariencia.

Por seguridad, ejecuta este comando solo si confías en el repositorio. Puedes inspeccionar primero el código de [quick-install.sh](https://github.com/DanielBarrientos727/windows7-kde-installer/blob/main/quick-install.sh).

## Instalación manual

Clona este repositorio y ejecuta el instalador **desde una sesión gráfica de KDE Plasma**:

```bash
git clone https://github.com/DanielBarrientos727/windows7-kde-installer.git
cd windows7-kde-installer
chmod +x install.sh
./install.sh
```

El instalador también admite estos comandos directos:

```bash
./install.sh --install   # Instalar el tema y los iconos
./install.sh --restore   # Restaurar la apariencia anterior
./install.sh --help      # Mostrar la ayuda
```

Antes de instalar, el script comprueba la versión de Plasma y crea una copia de seguridad de los archivos de configuración visual que puede modificar. Los temas y los iconos se instalan en la carpeta del usuario, no en directorios del sistema.

**`sudo` solo se utiliza para instalar Kvantum** mediante el gestor de paquetes de la distribución.

## Distribuciones compatibles

El instalador incluye métodos de instalación para:

- Fedora y derivados.
- Arch Linux y derivados.
- Debian, Ubuntu y derivados.
- openSUSE.

En Debian y Ubuntu solo utiliza paquetes disponibles en los repositorios configurados; **no añade PPAs automáticamente**.

El instalador está diseñado para sesiones de **KDE Plasma 6 o superior**. No está pensado para escritorios como GNOME ni para distribuciones cuya gestión de paquetes todavía no esté contemplada.

Requisitos: Bash, Git, sudo, curl para la instalación rápida, una sesión gráfica activa de KDE Plasma 6+ y conexión a Internet.

## Paquete RPM para Fedora

El repositorio también incluye el empaquetado nativo en **windows7-kde.spec**, el comando **windows7-kde** y un workflow de GitHub Actions para construir un RPM de prueba en Fedora 44. Puedes consultar [las instrucciones de COPR](https://github.com/DanielBarrientos727/windows7-kde-installer/blob/main/packaging/fedora/COPR.md).

**Importante: el paquete todavía no está publicado en COPR.** Por tanto, `sudo dnf install windows7-kde` no está disponible todavía desde los repositorios normales de Fedora. Primero hay que crear el proyecto COPR, vincular este repositorio de GitHub, compilar el paquete y confirmar que la compilación termina correctamente.

Cuando el repositorio COPR esté habilitado en Fedora, la instalación será:

~~~bash
sudo dnf install windows7-kde
~~~

Tras instalarlo, ejecuta **windows7-kde** como usuario normal dentro de KDE Plasma 6 o superior, sin sudo. El RPM instala el lanzador y declara las dependencias de Plasma, Git, Bash y Kvantum; la personalización visual se aplica en la sesión del usuario.

## Qué cambia y qué no

- Instala el tema global **Windows 7 Enhanced** y su paquete de iconos.
- Configura el tema Kvantum correspondiente.
- Guarda una copia de seguridad de los archivos de configuración visual antes de modificarlos.
- Si detecta componentes de Windows 7 Enhanced ya instalados fuera de una instalación previa de este script, se detiene para evitar sobrescribirlos sin una copia de seguridad.
- La opción `--restore` restaura la configuración respaldada y retira las carpetas de tema instaladas por el script.
- Kvantum no se desinstala automáticamente durante la restauración, ya que otras aplicaciones pueden utilizarlo.
- **No borra ni reconstruye los paneles de Plasma**, para evitar eliminar tus widgets o perder un panel personalizado. La barra inferior y el menú de aplicaciones pueden necesitar ajustes manuales para parecerse más a Windows 7.
- No modifica SDDM, la pantalla de inicio de sesión, el arranque ni las aplicaciones del sistema.

El resultado puede variar según la distribución y la versión de Plasma. Si los bordes de las ventanas o el estilo de algunas aplicaciones no se actualizan por completo, cierra sesión y vuelve a entrar.

Si la instalación falla después de crear la copia de seguridad, puedes intentar restaurar la configuración desde la carpeta del repositorio:

```bash
./install.sh --restore
```

## Licencias y atribuciones

Este proyecto funciona como instalador y descarga los temas desde sus repositorios originales; no redistribuye sus archivos.

- **Windows 7 Enhanced:** GPL-3.0-or-later.
- **Windows 7 Enhanced Icons:** CC BY-NC-SA 4.0, una licencia que restringe el uso comercial.

Consulta los repositorios originales para conocer los créditos, las licencias y las condiciones completas de cada componente.

El aspecto de Windows 7 se recrea mediante componentes comunitarios de KDE. Este proyecto no es software oficial de Microsoft ni requiere archivos de Windows.
