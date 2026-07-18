#!/usr/bin/env bash
#
# ===============================================================
# Instalador Profesional de Entorno de Desarrollo Python
# Compatible con Debian 12+, Ubuntu 22.04+, Linux Mint
# Autor: ChatGPT
# Versión: 2.0
# ===============================================================

set -Eeuo pipefail

#############################
# Variables
#############################

LOG="/var/log/python_install_$(date +%Y%m%d_%H%M%S).log"

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

#############################
# Funciones
#############################

info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

ok() {
    echo -e "${GREEN}[ OK ]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

trap 'error "Ocurrió un error en la línea $LINENO"' ERR

#############################
# Root
#############################

if [[ $EUID -ne 0 ]]; then
    error "Debe ejecutar este script como root."
    echo "Ejecute:"
    echo "sudo $0"
    exit 1
fi

#############################
# Inicio del Log
#############################

exec > >(tee -a "$LOG") 2>&1

echo
echo "=============================================="
echo " INSTALADOR PROFESIONAL DE PYTHON"
echo "=============================================="
echo

#############################
# Internet
#############################

info "Comprobando conexión a Internet..."

if ! ping -c1 8.8.8.8 >/dev/null 2>&1; then
    error "No existe conexión a Internet."
    exit 1
fi

ok "Conexión OK"

#############################
# Detectar SO
#############################

source /etc/os-release

info "Sistema detectado: $PRETTY_NAME"

#############################
# Actualizar
#############################

info "Actualizando repositorios..."

apt update

info "Actualizando paquetes..."

apt -y upgrade

#############################
# Instalar paquetes
#############################

PACKAGES=(
python3
python3-full
python3-dev
python3-pip
python3-venv
python3-setuptools
python3-wheel
python3-tk
idle-python3
git
curl
wget
vim
nano
tree
htop
zip
unzip
build-essential
libssl-dev
libffi-dev
zlib1g-dev
libbz2-dev
libreadline-dev
libsqlite3-dev
tk-dev
libncursesw5-dev
xz-utils
libxml2-dev
libxmlsec1-dev
libffi-dev
liblzma-dev
)

info "Instalando paquetes..."

apt install -y "${PACKAGES[@]}"

#############################
# Pip
#############################

info "Actualizando pip..."

python3 -m pip install --upgrade pip setuptools wheel

#############################
# Librerías Python
#############################

info "Instalando librerías de desarrollo..."

pip3 install --upgrade \
numpy \
pandas \
scipy \
matplotlib \
seaborn \
scikit-learn \
jupyter \
jupyterlab \
notebook \
ipython \
requests \
beautifulsoup4 \
lxml \
flask \
fastapi \
uvicorn \
sqlalchemy \
openpyxl \
xlsxwriter \
pillow \
psutil \
paramiko \
python-dotenv \
tqdm \
black \
flake8 \
autopep8 \
pytest \
virtualenv

#############################
# IDE
#############################

info "Instalando Thonny..."

apt install -y thonny

#############################
# VS Code
#############################

if command -v snap >/dev/null; then

    if ! snap list | grep -q code; then

        info "Instalando Visual Studio Code..."

        snap install code --classic

    fi

fi

#############################
# Crear Workspace
#############################

mkdir -p /opt/python

python3 -m venv /opt/python/venv

chmod -R 755 /opt/python

#############################
# Información
#############################

echo
echo "=============================================="

python3 --version

pip3 --version

echo

echo "Directorio del entorno virtual:"
echo "/opt/python/venv"

echo

echo "Activar entorno:"

echo "source /opt/python/venv/bin/activate"

echo

echo "Iniciar JupyterLab"

echo "jupyter lab"

echo

echo "Editor IDLE"

echo "idle-python3"

echo

echo "Visual Studio Code"

echo "code"

echo

echo "Log de instalación"

echo "$LOG"

echo

echo "=============================================="

ok "Instalación completada correctamente."

echo "=============================================="