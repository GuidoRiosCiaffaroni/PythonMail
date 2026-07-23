#!/usr/bin/env bash
#
# ===============================================================
# Instalador Profesional de Entorno de Desarrollo Python
# Compatible con Debian 12+, Ubuntu 22.04+, Linux Mint
# Autor: Linux Expert Refactor
# Versión: 3.0 (Corregido para PEP 668 & Multi-User)
# ===============================================================

set -Eeuo pipefail

#############################
# Variables y Configuración
#############################

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/python_install_${TIMESTAMP}.log"

# Colores dinámicos (solo si se ejecuta en una terminal interactiva)
if [[ -t 1 ]]; then
    GREEN="\e[32m"
    RED="\e[31m"
    YELLOW="\e[33m"
    BLUE="\e[34m"
    RESET="\e[0m"
else
    GREEN=""
    RED=""
    YELLOW=""
    BLUE=""
    RESET=""
fi

#############################
# Funciones de logs
#############################

info()  { echo -e "${BLUE}[INFO]${RESET} $1"; }
ok()    { echo -e "${GREEN}[ OK ]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1" >&2; }

# Captura de errores mejorada
failure_trap() {
    local exit_code=$?
    local line_number=$1
    error "El script falló en la línea $line_number con el código de salida $exit_code"
    exit "$exit_code"
}
trap 'failure_trap $LINENO' ERR

#############################
# Validaciones Iniciales
#############################

if [[ $EUID -ne 0 ]]; then
    error "Debe ejecutar este script como root (sudo)."
    exit 1
fi

# Detectar el usuario real que invocó sudo
REAL_USER=${SUDO_USER:-$USER}
if [[ "$REAL_USER" == "root" ]]; then
    warn "Está ejecutando directamente como root. El workspace se creará para el usuario root."
fi

# Intentar escribir en el log antes de redirigir
touch "$LOG_FILE" || { error "No se pudo crear el archivo de log en $LOG_FILE"; exit 1; }
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================================="
echo " INSTALADOR PROFESIONAL DE PYTHON v3.0"
echo "=============================================="

#############################
# Conexión a Internet
#############################
info "Comprobando conexión a Internet..."
# Usamos un puerto HTTP/DNS común en lugar de asumir que ICMP (ping) está permitido
if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
    # Si no hay herramientas, usamos una redirección TCP nativa de Bash a los DNS de Cloudflare
    exec 3<>/dev/tcp/1.1.1.1/53 || { error "No hay conexión a Internet detectada."; exit 1; }
    exec 3>&-
else
    curl -Is https://1.1.1.1 --connect-timeout 5 >/dev/null || { error "No existe conexión a Internet."; exit 1; }
fi
ok "Conexión a Internet verificada."

#############################
# Actualización del Sistema
#############################
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    info "Sistema detectado: $PRETTY_NAME"
else
    error "No se pudo determinar la distribución de Linux (/etc/os-release ausente)."
    exit 1
fi

info "Actualizando repositorios del sistema..."
apt-get update -y

info "Actualizando paquetes instalados..."
export DEBIAN_FRONTEND=noninteractive
apt-get -y upgrade

#############################
# Instalación de Paquetes APT
#############################
PACKAGES=(
    python3 python3-full python3-dev python3-pip python3-venv 
    python3-setuptools python3-wheel python3-tk idle-python3
    git curl wget vim nano tree htop zip unzip build-essential 
    libssl-dev libffi-dev zlib1g-dev libbz2-dev libreadline-dev 
    libsqlite3-dev tk-dev xz-utils libxml2-dev libxmlsec1-dev 
    liblzma-dev thonny
)

info "Instalando dependencias nativas del sistema..."
apt-get install -y "${PACKAGES[@]}"

# Instalación limpia de VS Code vía Snap si está disponible
if command -v snap &>/dev/null; then
    if ! snap list | grep -q "^code "; then
        info "Instalando Visual Studio Code vía Snap..."
        snap install code --classic
    fi
fi

#############################
# Workspace y Entorno Virtual Global Compartido
#############################
WORKSPACE="/opt/python"
VENV_PATH="$WORKSPACE/venv"

info "Configurando el entorno de trabajo en $WORKSPACE..."
mkdir -p "$WORKSPACE"

# Evitamos romper APT: Creamos un entorno virtual aislado en /opt
info "Creando entorno virtual Python..."
python3 -m venv "$VENV_PATH"

# Forzamos la actualización de herramientas críticas DENTRO del entorno virtual
info "Actualizando pip, setuptools y wheel dentro del entorno virtual..."
"$VENV_PATH/bin/pip" install --upgrade pip setuptools wheel

#############################
# Instalación de Librerías Python (VENV)
#############################
PYTHON_LIBS=(
    numpy pandas scipy matplotlib seaborn scikit-learn
    jupyter jupyterlab notebook ipython requests
    beautifulsoup4 lxml flask fastapi uvicorn sqlalchemy
    openpyxl xlsxwriter pillow psutil paramiko python-dotenv
    tqdm black flake8 autopep8 pytest virtualenv
)

info "Instalando paquetes científicos y de desarrollo en el entorno virtual..."
"$VENV_PATH/bin/pip" install --upgrade "${PYTHON_LIBS[@]}"

# Ajuste crítico de permisos:
# Permitimos que todos los usuarios del sistema lean/ejecuten el venv,
# pero le devolvemos la propiedad al usuario que ejecutó el sudo para que no tenga problemas de permisos en su IDE.
info "Configurando permisos del Workspace para el usuario '$REAL_USER'..."
chown -R "$REAL_USER:$REAL_USER" "$WORKSPACE"
chmod -R 755 "$WORKSPACE"

#############################
# Reporte Final
#############################
echo
echo "=============================================="
echo "      RESUMEN DE LA INSTALACIÓN"
echo "=============================================="
echo "Versión del Sistema:  $(python3 --version)"
echo "Versión de Pip (Venv): $("$VENV_PATH/bin/pip" --version | awk '{print $2}')"
echo "Entorno Virtual en:   $VENV_PATH"
echo "Log guardado en:      $LOG_FILE"
echo "----------------------------------------------"
echo "Para activar este entorno virtual ejecuta:"
echo "  source $VENV_PATH/bin/activate"
echo ""
echo "Para iniciar JupyterLab:"
echo "  source $VENV_PATH/bin/activate && jupyter lab"
echo "=============================================="
ok "El entorno de desarrollo se ha instalado correctamente."