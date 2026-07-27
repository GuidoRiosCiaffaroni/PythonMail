#!/bin/bash
# =========================================================================
# SCRIPT DE AUTOMATIZACIÓN: CONFIGURACIÓN DE NEOMUTT CON OAUTH2 (MICROSOFT)
# =========================================================================
set -e

# Configuración de Variables
EMAIL="guido.rios@redsalud.gob.cl"
MUTT_DIR="$HOME/.mutt"
TOKEN_PATH="$MUTT_DIR/token.gpg"
MUTTRC_PATH="$HOME/.muttrc"

echo "====================================================================="
echo "   Configurador Avanzado NeoMutt - Autenticación Moderna OAuth2     "
echo "====================================================================="

# 1. Actualización e Instalación de Dependencias del Sistema
echo -e "\n[1/5] Instalando herramientas criptográficas y dependencias..."
sudo apt update
sudo apt install -y python3-pip gpg curl neomutt

# 2. Creación del entorno y descarga del Script oficial OAuth2 de Mutt
echo -e "\n[2/5] Descargando componente oficial de autenticación de Mutt..."
mkdir -p "$MUTT_DIR/cache/headers"
mkdir -p "$MUTT_DIR/cache/bodies"
curl -sL -o "$MUTT_DIR/mutt_oauth2.py" https://gitlab.com/muttmua/mutt/-/raw/master/contrib/mutt_oauth2.py
chmod +x "$MUTT_DIR/mutt_oauth2.py"

# 3. Inicialización del Par de Llaves Criptográficas GPG
echo -e "\n[3/5] Generando llaves GPG locales para almacenar el Token cifrado..."
echo "---------------------------------------------------------------------"
echo "⚠️  ATENCIÓN: Se abrirá la interfaz de generación de llaves GPG."
echo "1. Ingrese su Nombre y Correo cuando se le solicite."
echo "2. Defina una FRASE DE PASO (Contraseña) segura para proteger su token local."
echo "---------------------------------------------------------------------"
gpg --generate-key

# 4. Fase Interactiva de Autorización OAuth2 con Microsoft Office 365
echo -e "\n[4/5] Iniciando Flujo de Autorización OAuth2 Corporativo..."
echo "---------------------------------------------------------------------"
echo "INSTRUCCIONES:"
echo "1. Copie la URL extremadamente larga que aparecerá abajo."
echo "2. Péguela en su navegador web e inicie sesión con su cuenta corporativa."
echo "3. Tras autorizar, copie la URL FINAL de la barra de direcciones del navegador."
echo "4. Péguela aquí abajo cuando el script se detenga a solicitarla."
echo "---------------------------------------------------------------------"
echo ""

$MUTT_DIR/mutt_oauth2.py "$TOKEN_PATH" --verbose --authorize --provider microsoft \
--client-id 08162f7c-0fd2-4200-a84a-f25a4db058b4 \
--authurl https://login.microsoftonline.com/common/oauth2/v2.0/authorize \
--tokenurl https://login.microsoftonline.com/common/oauth2/v2.0/token \
--scope https://outlook.office.com/IMAP.AccessAsUser.All%20https://outlook.office.com/SMTP.Send

# 5. Generación Automática del Archivo de Configuración .muttrc Limpio
echo -e "\n[5/5] Re-escribiendo archivo ~/.muttrc con la arquitectura de tokens..."

cat << EOF > "$MUTTRC_PATH"
# =========================================================================
# CONFIGURACIÓN DE NEOMUTT CON AUTENTICACIÓN MODERNA OAUTH2 - REDSALUD
# =========================================================================

# Datos de Identidad de la Cuenta
set imap_user = "$EMAIL"
set from = "$EMAIL"
set realname = "guido.rios"

# Forzar Métodos de Autenticación Moderna Obligatorios
set imap_authenticators = "oauthbearer:xoauth2"
set smtp_authenticators = "oauthbearer:xoauth2"

# Invocación Dinámica al Almacén Cifrado del Token mediante GPG
set imap_pass = "\`$MUTT_DIR/mutt_oauth2.py $TOKEN_PATH\`"
set smtp_url = "smtp://$EMAIL@smtp.office365.com:587/"
set smtp_pass = "\`$MUTT_DIR/mutt_oauth2.py $TOKEN_PATH\`"

# Servidores y Asignación de Carpetas Remotas (IMAP)
set folder = "imaps://outlook.office365.com:993"
set spoolfile = "+INBOX"
set postponed = "+Drafts"
set record = "+Sent"

# Optimización Exhaustiva de Caché Local
set header_cache = "~/.mutt/cache/headers"
set message_cachedir = "~/.mutt/cache/bodies"

# Ajustes de Conexión, Sesión y Persistencia
set mail_check = 60
set timeout = 15
set imap_keepalive = 300

# Interfaz Visual Avanzada
set sidebar_visible = yes
set sidebar_width = 24
set sidebar_format = "%B%?F? [%F]?%* %?N?%N/?"
set mail_check_stats = yes

# Atajos Ergonomicos de Teclado para Navegación de Carpetas
bind index,pager \033[A sidebar-prev    # Alt + Flecha Arriba
bind index,pager \033[B sidebar-next    # Alt + Flecha Abajo
bind index,pager \033[C sidebar-open    # Alt + Flecha Derecha
EOF

# Protección estricta de permisos Unix
chmod 600 "$MUTTRC_PATH"

echo -e "\n====================================================================="
echo "✅ DESPLIEGUE COMPLETADO COMPLETAMENTE CON ÉXITO"
echo "🔒 El archivo ~/.muttrc ha sido estructurado y blindado con permisos 600."
echo "🚀 Para inicializar su cliente de correo corporativo, ejecute: neomutt"
echo "====================================================================="