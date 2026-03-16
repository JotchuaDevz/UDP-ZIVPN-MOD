#!/bin/bash

CONFIG_DIR="/etc/hysteria"
CONFIG_FILE="$CONFIG_DIR/config.json"
USER_DB="$CONFIG_DIR/udpusers.db"
SYSTEMD_SERVICE="/etc/systemd/system/hysteria-server.service"
SCRIPT_PATH="$0"

mkdir -p "$CONFIG_DIR"
touch "$USER_DB"

export TZ="Asia/Manila"

# Colores
R='\e[1;31m'
G='\e[1;32m'
Y='\e[1;33m'
C='\e[1;36m'
M='\e[1;35m'
B='\e[1;34m'
W='\e[1;37m'
NC='\e[0m'

get_server_ip() {
    local ip=""
    if command -v curl >/dev/null 2>&1; then
        ip=$(curl -s -4 ifconfig.me 2>/dev/null) || \
        ip=$(curl -s -4 icanhazip.com 2>/dev/null) || \
        ip=$(curl -s -4 ipecho.net/plain 2>/dev/null)
    fi
    if [[ -z "$ip" ]] && command -v wget >/dev/null 2>&1; then
        ip=$(wget -qO- ifconfig.me 2>/dev/null) || \
        ip=$(wget -qO- icanhazip.com 2>/dev/null)
    fi
    if [[ -z "$ip" ]]; then
        ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127' | head -n 1)
    fi
    if [[ -z "$ip" ]]; then
        ip=$(hostname -I | awk '{print $1}')
    fi
    echo "$ip"
}

limpiar_despues_de_comando() {
    echo -e "\n${Y}Presiona Enter para continuar...${NC}"
    read
    clear
    mostrar_banner
}

obtener_usuarios() {
    if [[ -f "$USER_DB" ]]; then
        sqlite3 "$USER_DB" "SELECT password FROM users;" | paste -sd, -
    fi
}

actualizar_config_usuarios() {
    local usuarios=$(obtener_usuarios)
    local array_usuarios=$(echo "$usuarios" | awk -F, '{for(i=1;i<=NF;i++) printf "\"" $i "\"" ((i==NF) ? "" : ",")}')
    jq ".auth.config = [$array_usuarios]" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
}

generar_uri_zivpn() {
    local contrasena="$1"
    local ip_servidor="$2"
    local puerto=$(jq -r ".listen" "$CONFIG_FILE" | tr -d ':')

    echo "udp-zivpn-labx://${ip_servidor}:${puerto}?password=${contrasena}"
}

mostrar_info_conexion() {
    local contrasena="$1"
    local ip_servidor=$(get_server_ip)
    local uri=$(generar_uri_zivpn "$contrasena" "$ip_servidor")

    echo -e "\n${Y}╔══════════════════════════════════════════╗${NC}"
    echo -e "${Y}║        INFORMACION DE CONEXION           ║${NC}"
    echo -e "${Y}╚══════════════════════════════════════════╝${NC}"
    echo -e "${G}  IP del Servidor : ${W}$ip_servidor${NC}"
    echo -e "${G}  Contrasena      : ${W}$contrasena${NC}"
    echo -e "${G}  Puerto UDP      : ${W}10000-65000${NC}"
    echo -e "${Y}──────────────────────────────────────────${NC}"
    echo -e "${C}  URI: $uri${NC}"
    echo -e "${Y}══════════════════════════════════════════${NC}"
}

agregar_usuario() {
    echo -e "\n${C}  Ingresa la contrasena:${NC}"
    read -r contrasena
    sqlite3 "$USER_DB" "INSERT INTO users (password) VALUES ('$contrasena');"
    if [[ $? -eq 0 ]]; then
        echo -e "${G}  Contrasena agregada exitosamente.${NC}"
        mostrar_info_conexion "$contrasena"
        actualizar_config_usuarios
        reiniciar_servidor
    else
        echo -e "${R}  Error: No se pudo agregar la contrasena.${NC}"
    fi
    limpiar_despues_de_comando
}

editar_usuario() {
    echo -e "\n${C}  Ingresa la contrasena actual:${NC}"
    read -r contrasena_actual
    echo -e "${C}  Ingresa la nueva contrasena:${NC}"
    read -r contrasena_nueva
    sqlite3 "$USER_DB" "UPDATE users SET password = '$contrasena_nueva' WHERE password = '$contrasena_actual';"
    if [[ $? -eq 0 ]]; then
        echo -e "${G}  Contrasena actualizada exitosamente.${NC}"
        mostrar_info_conexion "$contrasena_nueva"
        actualizar_config_usuarios
        reiniciar_servidor
    else
        echo -e "${R}  Error: No se pudo actualizar la contrasena.${NC}"
    fi
    limpiar_despues_de_comando
}

eliminar_usuario() {
    echo -e "\n${C}  Ingresa la contrasena a eliminar:${NC}"
    read -r contrasena
    sqlite3 "$USER_DB" "DELETE FROM users WHERE password = '$contrasena';"
    if [[ $? -eq 0 ]]; then
        echo -e "${G}  Contrasena eliminada exitosamente.${NC}"
        actualizar_config_usuarios
        reiniciar_servidor
    else
        echo -e "${R}  Error: No se pudo eliminar la contrasena.${NC}"
    fi
    limpiar_despues_de_comando
}

mostrar_usuarios() {
    local ip_servidor=$(get_server_ip)

    echo -e "\n${Y}╔══════════════════════════════════════════╗${NC}"
    echo -e "${Y}║           CONTRASENAS ACTIVAS            ║${NC}"
    echo -e "${Y}╚══════════════════════════════════════════╝${NC}"

    while IFS= read -r contrasena; do
        local uri=$(generar_uri_zivpn "$contrasena" "$ip_servidor")
        echo -e "${G}  Contrasena : ${W}$contrasena${NC}"
        echo -e "${C}  URI        : $uri${NC}"
        echo -e "${Y}  ──────────────────────────────────────${NC}"
    done < <(sqlite3 "$USER_DB" "SELECT password FROM users;")

    limpiar_despues_de_comando
}

cambiar_velocidad_subida() {
    echo -e "\n${C}  Ingresa la nueva velocidad de subida (Mbps):${NC}"
    read -r velocidad_subida
    jq ".up_mbps = $velocidad_subida" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    jq ".up = \"$velocidad_subida Mbps\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    echo -e "${G}  Velocidad de subida cambiada a $velocidad_subida Mbps.${NC}"
    reiniciar_servidor
    limpiar_despues_de_comando
}

cambiar_velocidad_bajada() {
    echo -e "\n${C}  Ingresa la nueva velocidad de bajada (Mbps):${NC}"
    read -r velocidad_bajada
    jq ".down_mbps = $velocidad_bajada" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    jq ".down = \"$velocidad_bajada Mbps\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    echo -e "${G}  Velocidad de bajada cambiada a $velocidad_bajada Mbps.${NC}"
    reiniciar_servidor
    limpiar_despues_de_comando
}

cambiar_servidor() {
    echo -e "\n${C}  Ingresa la nueva direccion del servidor:${NC}"
    read -r servidor
    jq ".server = \"$servidor\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    echo -e "${G}  Servidor cambiado a $servidor.${NC}"
    reiniciar_servidor
    limpiar_despues_de_comando
}

reiniciar_servidor() {
    systemctl restart hysteria-server
    if [[ $? -eq 0 ]]; then
        echo -e "${G}  Servidor reiniciado exitosamente.${NC}"
    else
        echo -e "${R}  Error: No se pudo reiniciar el servidor.${NC}"
    fi
}

mostrar_ram_y_nucleos() {
    local ram_total=$(free -m | awk '/Mem:/ { print $2 }')
    local ram_usada=$(free -m | awk '/Mem:/ { print $3 }')
    local nucleos=$(nproc)
    echo -e "${M}  RAM: ${W}${ram_usada}/${ram_total} MB${M}  |  CPU: ${W}${nucleos} nucleos${NC}"
}

desinstalar_servidor() {
    echo -e "\n${R}  Desinstalando UDP-ZIVPN-MOD...${NC}"
    systemctl stop hysteria-server
    systemctl disable hysteria-server
    rm -f "$SYSTEMD_SERVICE"
    systemctl daemon-reload
    rm -rf "$CONFIG_DIR"
    rm -f /usr/local/bin/hysteria
    echo -e "${G}  UDP-ZIVPN-MOD desinstalado exitosamente.${NC}"

    cat > /tmp/remove_script.sh << EOF
#!/bin/bash
sleep 1
rm -f "$SCRIPT_PATH"
rm -f /tmp/remove_script.sh
EOF
    chmod +x /tmp/remove_script.sh
    nohup /tmp/remove_script.sh >/dev/null 2>&1 &
    exit 0
}

mostrar_banner() {
    clear
    local ip_servidor=$(get_server_ip)
    echo -e "${C}"
    echo -e "  ╔═══════════════════════════════════════════╗"
    echo -e "  ║  ██╗   ██╗██████╗ ██████╗               ║"
    echo -e "  ║  ██║   ██║██╔══██╗██╔══██╗              ║"
    echo -e "  ║  ██║   ██║██║  ██║██████╔╝              ║"
    echo -e "  ║  ██║   ██║██║  ██║██╔═══╝               ║"
    echo -e "  ║  ╚██████╔╝██████╔╝██║                   ║"
    echo -e "  ║   ╚═════╝ ╚═════╝ ╚═╝                   ║"
    echo -e "  ║                                           ║"
    echo -e "  ║      ${M}Z I V P N - M O D${C}                  ║"
    echo -e "  ║      ${W}by JotchuaDevz${C}                     ║"
    echo -e "  ╚═══════════════════════════════════════════╝${NC}"
    echo -e "${Y}  ┌─────────────────────────────────────────┐${NC}"
    echo -e "${Y}  │${NC}  IP Servidor  : ${W}$ip_servidor${NC}"
    echo -e "${Y}  │${NC}  Hora         : ${W}$(TZ='Asia/Manila' date '+%I:%M %p')${NC}"
    echo -e "${Y}  │${NC}  Fecha        : ${W}$(TZ='Asia/Manila' date '+%Y-%m-%d')${NC}"
    echo -e "${Y}  └─────────────────────────────────────────┘${NC}"
    mostrar_ram_y_nucleos
    echo ""
}

mostrar_menu() {
    echo -e "${C}  ╔═══════════════════════════════════════════╗${NC}"
    echo -e "${C}  ║          UDP-ZIVPN-MOD  MENU              ║${NC}"
    echo -e "${C}  ╚═══════════════════════════════════════════╝${NC}"
    echo -e "${G}  [${W}1${G}]${NC}  Agregar contrasena"
    echo -e "${G}  [${W}2${G}]${NC}  Editar contrasena"
    echo -e "${G}  [${W}3${G}]${NC}  Eliminar contrasena"
    echo -e "${G}  [${W}4${G}]${NC}  Mostrar contrasenas y URIs"
    echo -e "${Y}  ────────────────────────────────────────────${NC}"
    echo -e "${G}  [${W}5${G}]${NC}  Cambiar velocidad de subida"
    echo -e "${G}  [${W}6${G}]${NC}  Cambiar velocidad de bajada"
    echo -e "${G}  [${W}7${G}]${NC}  Cambiar dominio"
    echo -e "${Y}  ────────────────────────────────────────────${NC}"
    echo -e "${R}  [${W}10${R}]${NC} Desinstalar"
    echo -e "${R}  [${W}0${R}]${NC}  Salir"
    echo -e "${C}  ════════════════════════════════════════════${NC}"
    echo -e "${G}  Opcion: ${NC}\c"
}

mostrar_banner
while true; do
    mostrar_menu
    read -r opcion
    case $opcion in
        1)  agregar_usuario ;;
        2)  editar_usuario ;;
        3)  eliminar_usuario ;;
        4)  mostrar_usuarios ;;
        5)  cambiar_velocidad_subida ;;
        6)  cambiar_velocidad_bajada ;;
        7)  cambiar_servidor ;;
        10) desinstalar_servidor ;;
        0)  clear; exit 0 ;;
        *)  echo -e "${R}  Opcion invalida.${NC}"; limpiar_despues_de_comando ;;
    esac
done
        8)  desinstalar_servidor ;;
        0)  clear; exit 0 ;;
        *)  echo -e "${R}  Opcion invalida.${NC}"; limpiar_despues_de_comando ;;
    esac
done
