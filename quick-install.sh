#!/usr/bin/env bash
# One-command bootstrap for Windows 7 KDE Installer.
# This script deliberately runs as the desktop user, never as root.
set -Eeuo pipefail

readonly REPO_URL='https://github.com/DanielBarrientos727/windows7-kde-installer.git'
readonly BRANCH='main'
readonly DATA_HOME="\${XDG_DATA_HOME:-$HOME/.local/share}"
readonly INSTALL_DIR="$DATA_HOME/programs/windows7-kde-installer"

C_RESET=$'\033[0m'
C_BLUE=$'\033[1;34m'
C_GREEN=$'\033[1;32m'
C_YELLOW=$'\033[1;33m'
C_RED=$'\033[1;31m'
if [[ ! -t 1 || -n "\${NO_COLOR:-}" ]]; then
  C_RESET=''; C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''
fi

info() { printf '%s[INFO]%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '%s[ OK ]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s[AVISO]%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()  { printf '%s[ERROR]%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

printf '\n%s' "$C_BLUE"
cat <<'BANNER'
╭──────────────────────────────────────────────────────╮
│          WINDOWS 7 KDE · QUICK INSTALL               │
╰──────────────────────────────────────────────────────╯
BANNER
printf '%s\n' "$C_RESET"

[[ "\${EUID:-$(id -u)}" -ne 0 ]] || die 'No lo ejecutes con sudo ni como root. Ejecuta el comando desde tu usuario de escritorio.'
command -v git >/dev/null 2>&1 || die 'Falta Git. Instálalo con el gestor de paquetes de tu distribución y vuelve a ejecutar este comando.'
command -v bash >/dev/null 2>&1 || die 'Falta Bash.'

mkdir -p "$(dirname "$INSTALL_DIR")"

if [[ -e "$INSTALL_DIR" && ! -d "$INSTALL_DIR/.git" ]]; then
  die "La ruta de instalación ya existe y no es un clon Git: $INSTALL_DIR. No borraré ni sobrescribiré esa carpeta."
fi

if [[ -d "$INSTALL_DIR/.git" ]]; then
  remote="$(git -C "$INSTALL_DIR" remote get-url origin 2>/dev/null || true)"
  [[ "$remote" == "$REPO_URL" ]] || die "La carpeta existe, pero su origen Git no coincide con $REPO_URL. No la modificaré."
  if [[ -n "$(git -C "$INSTALL_DIR" status --porcelain)" ]]; then
    die "Hay cambios locales en $INSTALL_DIR. Para no perderlos, guarda o respalda esos cambios antes de actualizar."
  fi
  info 'Actualizando el instalador…'
  git -C "$INSTALL_DIR" fetch --depth 1 origin "$BRANCH"
  git -C "$INSTALL_DIR" merge --ff-only FETCH_HEAD
else
  info 'Descargando el instalador…'
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

[[ -f "$INSTALL_DIR/install.sh" ]] || die 'No encuentro install.sh en la copia descargada.'
ok 'Instalador preparado.'
info 'Se abrirá el instalador principal; revisa los cambios y confirma allí cuando estés listo.'
exec bash "$INSTALL_DIR/install.sh" --install
