#!/usr/bin/env bash
#
# ==============================================================================
# Archivo    : 01_install.sh
# Descripción: Instalador completo del entorno de desarrollo Python
# Compatible : Debian 12+, Ubuntu 22.04+, Ubuntu 24.04+, Linux Mint
# Versión    : 3.0
# ==============================================================================

set -Eeuo pipefail

############################################
# Variables
############################################

LOG="/var/log/python_install_$(date +%Y%m%d_%H%M%S).log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

############################################
# Funciones
############################################

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[ OK ]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

trap 'error "Ha ocurrido un error en la línea $LINENO"' ERR

############################################
# Root
############################################

if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root."
    echo
    echo "sudo ./01_install.sh"
    exit 1
fi

############################################
# Log
############################################

mkdir -p /var/log
exec > >(tee -a "$LOG") 2>&1

############################################
# Banner
############################################

clear

echo "==========================================================="
echo "      INSTALADOR PROFESIONAL PYTHON WORKSTATION"
echo "==========================================================="
echo

############################################
# Internet
############################################

info "Verificando conexión..."

if ! ping -c 1 8.8.8.8 >/dev/null; then
    error "No existe conexión a Internet."
    exit 1
fi

success "Conexión correcta."

############################################
# Sistema
############################################

source /etc/os-release

info "Sistema detectado: $PRETTY_NAME"

############################################
# Actualización
############################################

info "Actualizando repositorios..."

apt update

info "Actualizando sistema..."

apt -y upgrade

############################################
# Herramientas básicas
############################################

info "Instalando herramientas..."

apt install -y \
software-properties-common \
apt-transport-https \
ca-certificates \
curl \
wget \
git \
nano \
vim \
tree \
zip \
unzip \
htop \
iotop \
iftop \
tmux \
net-tools \
build-essential

############################################
# Python
############################################

info "Instalando Python..."

apt install -y \
python3 \
python3-full \
python3-dev \
python3-pip \
python3-venv \
python3-setuptools \
python3-wheel \
python3-tk \
idle-python3

############################################
# Actualizar pip
############################################

python3 -m pip install --upgrade \
pip \
setuptools \
wheel

############################################
# Librerías Python
############################################

info "Instalando librerías Python..."

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
pytest \
black \
flake8 \
autopep8 \
virtualenv \
psutil \
paramiko \
python-dotenv \
tqdm

############################################
# Docker
############################################

info "Instalando Docker..."

apt install -y docker.io docker-compose-v2

systemctl enable docker
systemctl start docker

############################################
# Bases de datos
############################################

info "Instalando bases de datos..."

apt install -y \
mariadb-server \
mariadb-client \
postgresql \
postgresql-contrib \
sqlite3

############################################
# SSH
############################################

info "Instalando OpenSSH..."

apt install -y openssh-server

systemctl enable ssh

############################################
# Firewall
############################################

info "Configurando Firewall..."

apt install -y ufw

ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable

############################################
# VS Code
############################################

if command -v snap >/dev/null 2>&1; then

    info "Instalando Visual Studio Code..."

    if ! snap list | grep -q code; then
        snap install code --classic
    fi

fi

############################################
# Thonny
############################################

apt install -y thonny

############################################
# Crear Workspace
############################################

info "Creando Workspace..."

mkdir -p /opt/python

python3 -m venv /opt/python/venv

chmod -R 755 /opt/python

############################################
# Limpieza
############################################

info "Limpiando sistema..."

apt autoremove -y
apt autoclean
apt clean

############################################
# Información
############################################

clear

echo
echo "==========================================================="
echo " INSTALACIÓN FINALIZADA"
echo "==========================================================="
echo

echo "Sistema Operativo"

cat /etc/os-release | grep PRETTY_NAME

echo
echo "Python"

python3 --version

echo
echo "PIP"

pip3 --version

echo
echo "Git"

git --version

echo
echo "Docker"

docker --version || true

echo
echo "MariaDB"

mysql --version || true

echo
echo "PostgreSQL"

psql --version || true

echo
echo "Jupyter"

jupyter --version || true

echo
echo "Workspace"

echo "/opt/python"

echo
echo "Entorno Virtual"

echo "/opt/python/venv"

echo
echo "Activar"

echo "source /opt/python/venv/bin/activate"

echo
echo "VS Code"

echo "code"

echo
echo "Jupyter"

echo "jupyter lab"

echo
echo "IDLE"

echo "idle-python3"

echo
echo "Log"

echo "$LOG"

echo
success "Instalación completada correctamente."