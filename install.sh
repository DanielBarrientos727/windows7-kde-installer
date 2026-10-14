#!/usr/bin/env bash
# windows7-kde-installer — user-level Windows 7 appearance for KDE Plasma 6+
# The theme and icon assets are downloaded from their original upstream repos.
set -Eeuo pipefail
IFS=$'\n\t'

readonly THEME_REPO='https://github.com/leonkhoo123/windows-7-enhanced.git'
readonly ICONS_REPO='https://github.com/leonkhoo123/windows-7-enhanced-icons.git'
readonly DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly STATE_DIR="$DATA_HOME/windows7-kde-installer"
readonly BACKUP_DIR="$STATE_DIR/backup"
readonly BACKUP_MANIFEST="$BACKUP_DIR/manifest.txt"

WORK_DIR=''
COLOR=0
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then COLOR=1; fi

if (( COLOR )); then
  C_RESET=$'\033[0m'; C_BLUE=$'\033[1;34m'; C_CYAN=$'\033[1;36m'
  C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'; C_RED=$'\033[1;31m'
else
  C_RESET=''; C_BLUE=''; C_CYAN=''; C_GREEN=''; C_YELLOW=''; C_RED=''
fi

cleanup() {
  if [[ -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then rm -rf -- "$WORK_DIR"; fi
}
trap cleanup EXIT

info() { printf '%s[INFO]%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '%s[ OK ]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s[AVISO]%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()  { printf '%s[ERROR]%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

banner() {
  printf '\n%s' "$C_CYAN"
  cat <<'BANNER'
╭──────────────────────────────────────────────────────╮
│             WINDOWS 7  ·  KDE PLASMA                 │
│             Appearance installer                     │
╰──────────────────────────────────────────────────────╯
BANNER
  printf '%s\n' "$C_RESET"
  printf '%sEste instalador prepara un aspecto inspirado en Windows 7.%s\n\n' "$C_BLUE" "$C_RESET"
}

usage() {
  cat <<EOF_USAGE
Uso:
  ./install.sh             Abrir el menú interactivo
  ./install.sh --install   Instalar el tema y los iconos
  ./install.sh --restore   Restaurar la configuración visual anterior
  ./install.sh --uninstall Alias de --restore
  ./install.sh --help      Mostrar esta ayuda

Requiere una sesión gráfica de KDE Plasma 6 o superior.
EOF_USAGE
}

confirm() {
  local prompt="$1" answer=''
  [[ -t 0 ]] || die 'Se necesita una terminal interactiva para confirmar los cambios.'
  printf '%s [s/N] ' "$prompt"
  IFS= read -r answer || true
  [[ "$answer" =~ ^([sS]|[sS][iI])$ ]]
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "No encuentro el comando requerido: $1"
}

check_plasma() {
  local version major desktop
  require_command plasmashell
  version="$(plasmashell --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1 || true)"
  [[ -n "$version" ]] || die 'No pude detectar la versión de Plasma. Ejecuta esto dentro de una sesión KDE Plasma.'
  major="${version%%.*}"
  [[ "$major" =~ ^[0-9]+$ ]] || die "Versión de Plasma inesperada: $version"
  (( major >= 6 )) || die "Detecté Plasma $version. Este instalador requiere Plasma 6 o superior."

  desktop="${XDG_CURRENT_DESKTOP:-} ${XDG_SESSION_DESKTOP:-}"
  if [[ "$desktop" != *KDE* && "$desktop" != *Plasma* ]] && ! pgrep -x plasmashell >/dev/null 2>&1; then
    die 'No parece que estés dentro de una sesión KDE Plasma activa.'
  fi

  if ! command -v plasma-apply-lookandfeel >/dev/null 2>&1 && ! command -v lookandfeeltool >/dev/null 2>&1; then
    die 'No encuentro plasma-apply-lookandfeel ni lookandfeeltool; no puedo aplicar el tema automáticamente.'
  fi
  ok "KDE Plasma $version detectado."
}

install_kvantum() {
  local id id_like package_manager
  [[ -r /etc/os-release ]] || die 'No encuentro /etc/os-release para identificar la distribución.'
  # shellcheck disable=SC1091
  . /etc/os-release
  id="${ID:-unknown}"
  id_like="${ID_LIKE:-}"
  package_manager=''

  if [[ "$id" == fedora || " $id_like " == *' fedora '* ]]; then
    package_manager='dnf'
  elif [[ "$id" == arch || "$id" == manjaro || "$id" == endeavouros || "$id" == garuda || " $id_like " == *' arch '* ]]; then
    package_manager='pacman'
  elif [[ "$id" == ubuntu || "$id" == debian || "$id" == linuxmint || "$id" == pop || "$id" == elementary || "$id" == zorin || "$id" == kali || " $id_like " == *' debian '* || " $id_like " == *' ubuntu '* ]]; then
    package_manager='apt'
  elif [[ "$id" == opensuse* || "$id" == suse || " $id_like " == *' suse '* ]]; then
    package_manager='zypper'
  else
    die "Distribución no soportada automáticamente: $id. Instala Kvantum desde el gestor de paquetes de tu distro y vuelve a ejecutar el instalador."
  fi

  require_command sudo
  info 'Kvantum se instalará con el gestor de paquetes del sistema.'
  info 'El resto de componentes se instalarán únicamente en tu carpeta de usuario.'

  case "$package_manager" in
    dnf)
      require_command dnf
      sudo dnf install -y kvantum
      ;;
    pacman)
      require_command pacman
      sudo pacman -S --needed kvantum
      ;;
    apt)
      require_command apt-get
      require_command apt-cache
      local -a packages=()
      local candidate
      # Package names differ across Debian/Ubuntu releases. Install only names
      # present in the configured repositories; do not add third-party PPAs.
      for candidate in qt6-style-kvantum qt6-style-kvantum-themes kvantum-manager; do
        if apt-cache show "$candidate" >/dev/null 2>&1; then packages+=("$candidate"); fi
      done
      ((${#packages[@]} > 0)) || die 'No encuentro Kvantum en los repositorios APT configurados. No añadiré un PPA automáticamente; consulta la documentación de tu distro.'
      sudo apt-get update
      sudo apt-get install -y "${packages[@]}"
      ;;
    zypper)
      require_command zypper
      sudo zypper --non-interactive install kvantum-manager kvantum-qt6
      ;;
    *) die 'Error interno: gestor de paquetes no reconocido.' ;;
  esac
  ok 'Kvantum instalado (o actualizado) por el gestor de paquetes.'
}

create_backup() {
  local rel src dst
  if [[ -f "$BACKUP_MANIFEST" ]]; then
    info 'Ya existe una copia de seguridad inicial; no la sobrescribiré.'
    return
  fi

  mkdir -p "$BACKUP_DIR/files"
  : > "$BACKUP_MANIFEST"
  local -a config_paths=(
    'kdeglobals'
    'kwinrc'
    'plasmarc'
    'ksplashrc'
    'plasma-org.kde.plasma.desktop-appletsrc'
    'plasmashellrc'
    'Kvantum/kvantum.kvconfig'
  )

  for rel in "${config_paths[@]}"; do
    src="$CONFIG_HOME/$rel"
    dst="$BACKUP_DIR/files/$rel"
    if [[ -e "$src" || -L "$src" ]]; then
      mkdir -p "$(dirname "$dst")"
      cp -a -- "$src" "$dst"
      printf 'present|%s\n' "$rel" >> "$BACKUP_MANIFEST"
    else
      printf 'absent|%s\n' "$rel" >> "$BACKUP_MANIFEST"
    fi
  done
  printf '%s\n' "$(date -Is 2>/dev/null || date)" > "$BACKUP_DIR/created-at.txt"
  ok 'Configuración visual anterior respaldada.'
}

clone_sources() {
  WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/windows7-kde-installer.XXXXXX")"
  info 'Descargando el tema visual y el paquete de iconos desde sus repositorios originales…'
  git clone --depth 1 "$THEME_REPO" "$WORK_DIR/windows-7-enhanced"
  git clone --depth 1 "$ICONS_REPO" "$WORK_DIR/windows-7-enhanced-icons"
  [[ -x "$WORK_DIR/windows-7-enhanced/install.sh" || -f "$WORK_DIR/windows-7-enhanced/install.sh" ]] || die 'El repositorio del tema no contiene install.sh.'
  [[ -x "$WORK_DIR/windows-7-enhanced-icons/install.sh" || -f "$WORK_DIR/windows-7-enhanced-icons/install.sh" ]] || die 'El repositorio de iconos no contiene install.sh.'
  ok 'Repositorios descargados.'
}

set_kvantum_theme() {
  mkdir -p "$CONFIG_HOME/Kvantum"
  if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file 'Kvantum/kvantum.kvconfig' --group General --key theme windows-7-enhanced
  else
    warn 'No encuentro kwriteconfig6; escribiré una configuración Kvantum mínima.'
    cat > "$CONFIG_HOME/Kvantum/kvantum.kvconfig" <<'KVANTUM'
[General]
theme=windows-7-enhanced
KVANTUM
  fi
}

apply_global_theme() {
  if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
    plasma-apply-lookandfeel -a windows-7-enhanced
  else
    lookandfeeltool -a windows-7-enhanced
  fi
}

install_all() {
  check_plasma
  if ! confirm '¿Instalar Windows 7 Enhanced, los iconos y Kvantum?'; then
    info 'Instalación cancelada; no se hicieron cambios de apariencia.'
    return 0
  fi

  install_kvantum
  require_command git
  clone_sources
  create_backup

  info 'Instalando los componentes de apariencia…'
  bash "$WORK_DIR/windows-7-enhanced/install.sh"
  bash "$WORK_DIR/windows-7-enhanced-icons/install.sh"
  set_kvantum_theme
  info 'Aplicando el tema global…'
  if ! apply_global_theme; then
    warn 'No se pudo aplicar el tema automáticamente. Los componentes están instalados y puedes seleccionarlo en Configuración del sistema → Apariencia → Tema global.'
    warn 'La copia de seguridad está disponible con: ./install.sh --restore'
    return 1
  fi

  # The global theme sets the Qt widget style; set the matching Kvantum skin
  # after applying it, without replacing other Kvantum settings.
  set_kvantum_theme
  if command -v kbuildsycoca6 >/dev/null 2>&1; then kbuildsycoca6 --noincremental >/dev/null 2>&1 || true; fi

  printf '\n%s¡Listo!%s El tema global y los iconos de Windows 7 Enhanced están instalados.\n' "$C_GREEN" "$C_RESET"
  printf '  • Tema global: Windows 7 Enhanced\n'
  printf '  • Iconos: Windows 7 Enhanced\n'
  printf '  • Estilo Qt: Kvantum + Windows 7 Enhanced\n'
  printf '\nTu panel actual se conserva: el instalador no borra ni reconstruye paneles/applet de Plasma.\n'
  printf 'Si algún borde de ventana o estilo no cambia del todo, cierra sesión y vuelve a entrar.\n'
  printf 'Para revertir la configuración y retirar estos componentes: %s./install.sh --restore%s\n\n' "$C_CYAN" "$C_RESET"
}

remove_theme_files() {
  local path
  local -a targets=(
    "$DATA_HOME/plasma/look-and-feel/windows-7-enhanced"
    "$DATA_HOME/plasma/look-and-feel/windows-7-enhanced-splash"
    "$DATA_HOME/plasma/desktoptheme/windows-7-enhanced"
    "$DATA_HOME/aurorae/themes/windows-7-enhanced"
    "$DATA_HOME/icons/windows-7-enhanced"
    "$CONFIG_HOME/Kvantum/windows-7-enhanced"
  )
  for path in "${targets[@]}"; do
    # Guard against accidental deletion if environment paths are overridden oddly.
    [[ "$path" == "$DATA_HOME/"* || "$path" == "$CONFIG_HOME/"* ]] || die "Ruta de eliminación inesperada: $path"
    if [[ -e "$path" || -L "$path" ]]; then rm -rf -- "$path"; fi
  done
  rm -f -- "$DATA_HOME/color-schemes/Windows7Enhanced.colors" "$DATA_HOME/color-schemes/Windows7EnhancedAero.colors"
}

restore_baseline() {
  local rel status src dst
  [[ -f "$BACKUP_MANIFEST" ]] || die 'No encuentro una copia de seguridad de este instalador; no hay nada que restaurar.'
  if ! confirm '¿Restaurar la configuración anterior y quitar los temas instalados por este script?'; then
    info 'Restauración cancelada.'
    return 0
  fi

  remove_theme_files
  while IFS='|' read -r status rel; do
    [[ -n "$rel" ]] || continue
    # Only restore the explicit set of configuration files managed by this script.
    case "$rel" in
      kdeglobals|kwinrc|plasmarc|ksplashrc|plasma-org.kde.plasma.desktop-appletsrc|plasmashellrc|Kvantum/kvantum.kvconfig) ;;
      *) die "Entrada inesperada en la copia de seguridad: $rel" ;;
    esac
    dst="$CONFIG_HOME/$rel"
    src="$BACKUP_DIR/files/$rel"
    if [[ "$status" == present ]]; then
      [[ -e "$src" || -L "$src" ]] || die "Falta el archivo respaldado: $rel"
      mkdir -p "$(dirname "$dst")"
      rm -f -- "$dst"
      cp -a -- "$src" "$dst"
    elif [[ "$status" == absent ]]; then
      rm -f -- "$dst"
    else
      die "Estado de copia de seguridad inesperado para $rel"
    fi
  done < "$BACKUP_MANIFEST"

  if command -v kbuildsycoca6 >/dev/null 2>&1; then kbuildsycoca6 --noincremental >/dev/null 2>&1 || true; fi
  rm -rf -- "$BACKUP_DIR"
  rmdir "$STATE_DIR" 2>/dev/null || true
  ok 'Se restauró la configuración respaldada y se retiraron los componentes de tema e iconos.'
  warn 'Kvantum no se desinstala automáticamente porque otras aplicaciones pueden utilizarlo.'
  warn 'Cierra sesión y vuelve a entrar para que todos los componentes visuales se actualicen.'
}

menu() {
  local choice=''
  while true; do
    banner
    printf '  %s1)%s Instalar el tema de Windows 7\n' "$C_GREEN" "$C_RESET"
    printf '  %s2)%s Restaurar la apariencia anterior\n' "$C_YELLOW" "$C_RESET"
    printf '  %s0)%s Salir\n\n' "$C_BLUE" "$C_RESET"
    printf 'Selecciona una opción: '
    IFS= read -r choice || exit 0
    case "$choice" in
      1) install_all; return $? ;;
      2) restore_baseline; return $? ;;
      0) info 'Hasta luego.'; return 0 ;;
      *) warn 'Opción no válida. Escribe 1, 2 o 0.'; printf '\n' ;;
    esac
  done
}

main() {
  case "${1:-}" in
    '') menu ;;
    --install|-i) banner; install_all ;;
    --restore|--uninstall|-r|-u) banner; restore_baseline ;;
    --help|-h) usage ;;
    *) usage >&2; die "Opción desconocida: $1" ;;
  esac
}

main "$@"
