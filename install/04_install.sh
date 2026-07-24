#!/usr/bin/env bash
#
# ===============================================================
# Instalador Automatizado de Google Chrome Stable
# Compatible con Debian, Ubuntu, Linux Mint y derivados (64-bit)
# ===============================================================

set -Eeuo pipefail

# Colores para la terminal (solo si es interactiva)
if [[ -t 1 ]]; then
    GREEN="\e[32m"
    RED="\e[31m"
    BLUE="\e[34m"
    RESET="\e[0m"
else
    GREEN=""
    RED=""
    BLUE=""
    RESET=""
fi

info()  { echo -e "${BLUE}[INFO]${RESET} $1"; }
ok()    { echo -e "${GREEN}[ OK ]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1" >&2; }

# Control de errores
trap 'error "El script falló en la línea $LINENO con código de salida $?"' ERR

# Validar permisos de root
if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root (usando sudo)."
    exit 1
fi

# 1. Instalar dependencias necesarias para descargar de forma segura
info "Instalando dependencias necesarias (curl/wget)..."
apt-get update -y
apt-get install -y curl wget gdebi-core

# 2. Descargar el paquete oficial .deb de Google Chrome
info "Descargando el paquete oficial de Google Chrome (.deb)..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# 3. Instalar el paquete resolviendo dependencias automáticamente
info "Instalando Google Chrome..."
export DEBIAN_FRONTEND=noninteractive
gdebi -n google-chrome-stable_current_amd64.deb

# 4. Limpieza de archivos temporales
cd ~
rm -rf "$TEMP_DIR"

echo "----------------------------------------------"
ok "¡Google Chrome se ha instalado correctamente!"
info "Nota: El repositorio oficial se ha añadido automáticamente a /etc/apt/sources.list.d/"
info "Chrome se actualizará solo la próxima vez que ejecutes 'apt upgrade'."
echo "----------------------------------------------"