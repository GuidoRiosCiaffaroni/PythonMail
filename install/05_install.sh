#!/bin/bash
#
# ===============================================================
# Instalador Automatizado de ll
# Compatible con Debian, Ubuntu, Linux Mint y derivados (64-bit)
# ===============================================================


# 1. Detectar el archivo de configuración del usuario actual
if [ -n "$ZSH_VERSION" ]; then
    CONFIG_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    CONFIG_FILE="$HOME/.bashrc"
else
    # Si no se detecta, usamos .bashrc por defecto
    CONFIG_FILE="$HOME/.bashrc"
fi

# 2. Definir el alias que queremos instalar
ALIAS_LINE="alias ll='ls -la --color=auto'"

# 3. Comprobar si el alias ya existe para no duplicarlo
if grep -Fxq "$ALIAS_LINE" "$CONFIG_FILE"; then
    echo "¡El alias 'll' ya está instalado en $CONFIG_FILE!"
else
    # Añadir el alias al final del archivo
    echo "" >> "$CONFIG_FILE"
    echo "# Alias personalizado creado por script" >> "$CONFIG_FILE"
    echo "$ALIAS_LINE" >> "$CONFIG_FILE"
    
    echo "Configuración añadida con éxito a $CONFIG_FILE."
    echo "Para activar 'll' en esta terminal ejecuta: source $CONFIG_FILE"
fi