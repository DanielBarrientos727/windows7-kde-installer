# Windows 7 KDE Installer

Un instalador sencillo para darle a **KDE Plasma 6 o superior** una apariencia inspirada en Windows 7, sin compilar un shell alternativo ni sustituir componentes centrales de KDE.

El script descarga e instala los paquetes de apariencia de sus proyectos originales:

- [Windows 7 Enhanced](https://github.com/leonkhoo123/windows-7-enhanced): tema global de Plasma, colores Aero, decoración de ventanas, tema del escritorio y tema Kvantum.
- [Windows 7 Enhanced Icons](https://github.com/leonkhoo123/windows-7-enhanced-icons): iconos del sistema.
- [Kvantum](https://github.com/tsujan/Kvantum): estilo de widgets Qt necesario para que los controles también sigan el aspecto del tema.

## Instalación

Clona este repositorio y ejecuta el instalador **desde una sesión gráfica de KDE Plasma**:

~~~bash
git clone https://github.com/DanielBarrientos727/windows7-kde-installer.git
cd windows7-kde-installer
chmod +x install.sh
./install.sh
~~~

El menú también admite estos comandos directos:

~~~bash
./install.sh --install   # instala el tema y los iconos
./install.sh --restore   # revierte los cambios de apariencia
./install.sh --help      # muestra la ayuda
~~~

Antes de instalar, el script comprueba la versión de Plasma, instala Kvantum desde el gestor de paquetes de la distribución y crea una copia de seguridad de los archivos de configuración visual que puede modificar. Los temas y los iconos se instalan en la carpeta del usuario, no en directorios del sistema. **sudo solo se utiliza para instalar Kvantum** mediante el gestor de paquetes.

## Distribuciones

El instalador detecta recetas de paquetes para Fedora, Arch Linux y derivados, Debian/Ubuntu y derivados, y openSUSE. En Debian/Ubuntu solo usa paquetes que encuentre en los repositorios ya configurados; **no añade PPAs**. Otras distribuciones deben instalar Kvantum manualmente antes de que puedan añadirse como compatibles.

Requisitos: Bash, Git, sudo, una sesión activa de KDE Plasma 6+ y acceso a Internet.

## Qué cambia y qué no

- Instala y aplica el tema global **Windows 7 Enhanced** y sus iconos.
- Configura el tema Kvantum de Windows 7 Enhanced.
- Guarda una copia de los archivos de configuración visual anteriores.
- La opción **--restore** restaura esa configuración y retira las carpetas de tema instaladas por este script. Kvantum se conserva instalado porque otras aplicaciones pueden usarlo.
- **No borra ni reconstruye los paneles de Plasma.** Así evita quitar tus widgets o perder un panel personalizado. El resultado exacto de la barra de tareas depende del panel que ya tengas; en caso de usar una disposición personalizada, puede requerir algún ajuste manual.
- No cambia SDDM, la pantalla de inicio de sesión, el arranque, fuentes de Windows ni aplicaciones del sistema.

El instalador no puede garantizar un resultado idéntico en todas las versiones o distribuciones. Cierra sesión y vuelve a entrar si los bordes de las ventanas o el estilo de las aplicaciones no se actualizan por completo. Si el proceso falla después de crear la copia de seguridad, ejecuta **./install.sh --restore** desde este repositorio.

## Licencias y atribuciones

Este proyecto actúa como instalador y descarga los temas desde los repositorios originales; no redistribuye sus archivos. **Windows 7 Enhanced** publica sus componentes bajo GPL-3.0-or-later. **Windows 7 Enhanced Icons** usa CC BY-NC-SA 4.0, que incluye una restricción de uso no comercial. Consulta sus repositorios para ver los créditos y condiciones completas.

El aspecto de Windows 7 se recrea con componentes comunitarios de KDE; no es software oficial de Microsoft ni requiere archivos de Windows.
