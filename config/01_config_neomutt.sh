#!/bin/bash

# Salir si ocurre algún error
set -e

echo "===================================================="
echo "   Configurador Automático de NeoMutt para Outlook  "
echo "===================================================="

# 1. Instalar NeoMutt según la distribución
echo -e "\n[1/3] Instalando NeoMutt..."
if [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt install -y neomutt
elif [ -f /etc/redhat-release ]; then
    sudo dnf install -y neomutt
elif [ -f /etc/arch-release ]; then
    sudo pacman -Syu --noconfirm neomutt
else
    echo "⚠️ Sistema operativo no reconocido automáticamente. Instala 'neomutt' manualmente y vuelve a ejecutar."
    exit 1
fi

# 2. Solicitar datos del usuario
echo -e "\n[2/3] Configuración de credenciales..."
read -p "Introduce tu correo de Outlook (ej. usuario@outlook.com): " EMAIL
echo -n "Introduce tu Contraseña de Aplicación de Microsoft (se ocultará el texto): "
read -s PASSWORD
echo ""

# 3. Crear directorios y archivo de configuración
echo -e "\n[3/3] Generando archivos de configuración..."

# Crear carpetas para el manejo de caché y correos locales
mkdir -p "$HOME/.mutt/cache/bodies"
mkdir -p "$HOME/.mutt/cache/headers"

# Ruta del archivo de configuración principal
MUTTRC="$HOME/.muttrc"

# Escribir la configuración en ~/.muttrc
cat << EOF > "$MUTTRC"
# ==========================================
# CONFIGURACIÓN DE NEOMUTT PARA OUTLOOK
# ==========================================

# Datos de la cuenta
set imap_user = "$EMAIL"
set imap_pass = "$PASSWORD"
set smtp_url = "smtp://$EMAIL:$PASSWORD@smtp.office365.com:587/"
set from = "$EMAIL"
set realname = "${EMAIL%%@*}"

# Servidores y Carpetas Remotas (IMAP)
set folder = "imaps://outlook.office365.com:993"
set spoolfile = "+INBOX"
set postponed = "+Drafts"
set record = "+Sent"

# Optimización de Caché (Acelera la carga de correos)
set header_cache = "~/.mutt/cache/headers"
set message_cachedir = "~/.mutt/cache/bodies"

# Ajustes de Conexión y Rendimiento
set mail_check = 60
set timeout = 15
set imap_keepalive = 300

# Interfaz Visual Básica
set sidebar_visible = yes
set sidebar_width = 24
set sidebar_format = "%B%?F? [%F]?%* %?N?%N/?"
set mail_check_stats = yes

# Enlaces de teclas para la barra lateral (Navegar con Flechas)
bind index,pager \033[A sidebar-prev    # Alt + Flecha Arriba
bind index,pager \033[B sidebar-next    # Alt + Flecha Abajo
bind index,pager \033[C sidebar-open    # Alt + Flecha Derecha

echo "✅ ¡Configuración completada con éxito!"
echo "🔒 Tu archivo ~/.muttrc ha sido creado."
echo "🚀 Para iniciar, simplemente escribe: neomutt"
EOF

# Asegurar permisos del archivo para que nadie más pueda leer tu contraseña
chmod 600 "$MUTTRC"