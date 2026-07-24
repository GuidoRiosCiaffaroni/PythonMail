#!/usr/bin/env bash
#
# ===============================================================
# Script de Instalación de Utilidades y Dependencias del Sistema
# Compatible con Debian 12+, Ubuntu 22.04+, Linux Mint
# Versión: 1.1 (Con documentación detallada de paquetes)
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

# Manejo de errores catastróficos
trap 'error "El script falló en la línea $LINENO con código de salida $?"' ERR

# Validar permisos de Administrador
if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root (usando sudo)."
    exit 1
fi

info "Actualizando el índice de repositorios..."
apt-get update -y

# Lista de paquetes extraídos de tus capturas y comentados
PACKAGES=(
    # --- Herramientas de Consola y Monitoreo ---
    apg                     # Generador automático de contraseñas seguras y aleatorias (Automated Password Generator).
    atop                    # Monitor de rendimiento del sistema y procesos avanzado (CPU, memoria, disco, red).
    bmon                    # Monitor de ancho de banda y flujo de red en tiempo real con gráficos en texto.
    byobu                   # Gestor de ventanas y terminales basado en texto que mejora y envuelve a tmux/screen.
    ccze                    # Coloreador de logs robusto que facilita la lectura de archivos en /var/log/.
    cmatrix                 # El clásico efecto visual de lluvia de código de la película "The Matrix" para la terminal.
    hollywood               # Utilidad que divide la terminal en múltiples paneles llenos de scripts técnicos simulando a un hacker de película.
    moreutils               # Colección de herramientas útiles para pipelines en Bash (como 'sponge', 'ts', 'vidir').
    speedometer             # Muestra gráficos limpios y visuales de la velocidad de transferencia de red actual.
    tmux                    # Multiplexor de terminales; permite dividir la pantalla y mantener sesiones activas en segundo plano.

    # --- Librerías de Sistema y Dependencias C ---
    libconfuse-common       # Archivos comunes y de soporte para la librería de parsing de archivos de configuración.
    libconfuse2             # Librería en C para parsear archivos de configuración con sintaxis limpia y fácil.
    libevent-core-2.1-7t64  # Componentes esenciales de libevent, usada para manejo de eventos asíncronos en red (requerida por tmux).

    # --- Librerías de Perl ---
    libio-pty-perl          # Módulo de Perl para manejo de pseudo-terminales (PTYs), necesario para automatizar interacciones de texto.
    libipc-run-perl         # Módulo de Perl que facilita la ejecución y control de procesos hijos (redirecciones I/O, pipes).
    libtime-duration-perl   # Módulo de Perl que convierte valores de tiempo en segundos a expresiones legibles ("hace 2 horas").

    # --- Librerías y Módulos de Python 3 ---
    python3-newt            # Interfaz de Python para la librería 'newt', usada para crear menús y ventanas de diálogo de texto (TUI).
    python3-urwid           # Librería avanzada de Python para construir interfaces de usuario complejas y fluidas en la terminal.
    python3-wcwidth         # Módulo de Python para calcular el ancho de caracteres Unicode en pantallas de terminal.

    # --- Utilidades de Ejecución ---
    run-one                 # Script contenedor que asegura que no se ejecute más de una instancia de un comando a la vez (útil en cronjobs).
)

info "Instalando paquetes y utilidades de la lista..."
export DEBIAN_FRONTEND=noninteractive
apt-get install -y "${PACKAGES[@]}"

echo "----------------------------------------------"
ok "¡Todos los paquetes se han instalado correctamente!"
echo "----------------------------------------------"