# Publicar el paquete en Fedora COPR

El archivo **windows7-kde.spec** de la raíz permite compilar este proyecto como RPM sin mantener una copia separada de los scripts.

## Crear el proyecto

1. Crea o utiliza una cuenta de Fedora Account System (FAS) y entra en [COPR](https://copr.fedorainfracloud.org/).
2. Crea un proyecto público llamado **windows7-kde** y selecciona el chroot de Fedora que quieras soportar (por ejemplo, **fedora-44-x86_64** para pruebas de compatibilidad).
3. En la sección de fuente de compilación, selecciona **SCM**, Git, y usa:
   - Clone URL: https://github.com/DanielBarrientos727/windows7-kde-installer.git
   - Committish: main
   - Subdirectory: dejar vacío
   - Spec file: windows7-kde.spec
4. Inicia una compilación y comprueba que termine correctamente antes de compartir el repositorio.

COPR admite compilaciones desde repositorios Git con un archivo SPEC en la raíz. Documentación: [Build Source Types](https://docs.copr.fedorainfracloud.org/user_documentation.html).

## Instalar el paquete cuando COPR esté publicado

En la página de tu proyecto COPR habrá instrucciones exactas para habilitar el repositorio. En términos generales, se habilita una vez y luego se instala el paquete:

~~~bash
sudo dnf copr enable USUARIO_FAS/windows7-kde
sudo dnf install windows7-kde
~~~

Reemplaza USUARIO_FAS por el propietario real del proyecto COPR. No tiene por qué coincidir con el nombre de usuario de GitHub. Para usuarios con DNF5, sigue el comando de activación que genere la página de COPR si difiere del anterior.

Después de instalar el RPM, ejecuta **windows7-kde** como usuario normal dentro de KDE Plasma 6 o superior. **No ejecutes ese comando con sudo.** El paquete instala los scripts; el comando aplica la apariencia a la configuración del usuario que inició sesión.

## Desarrollo y comprobación local

El workflow .github/workflows/rpm.yml construye un RPM de prueba en un contenedor Fedora 44 y publica el RPM/SRPM como artefactos de GitHub Actions. Esto prueba el empaquetado; no publica automáticamente el paquete en COPR.

Para tener actualizaciones automáticas en COPR, configura una compilación SCM para este repositorio y revisa la configuración de webhooks en COPR. No se guardan tokens de COPR dentro de este repositorio.
