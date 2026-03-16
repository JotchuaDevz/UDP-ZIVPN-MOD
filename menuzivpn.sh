#!/bin/bash
#Jotchua_Devz
IP=`curl -4 icanhazip.com`;
distribution=`( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1`;
Network=`ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1`;
ports=`netstat -tunlp | grep zivpn | grep ::: | awk '{print substr($4,4); }' > /tmp/udpzivpn.txt && echo | cat /tmp/udpzivpn.txt | tr '\n' ' ' > /tmp/udpzivpnports.txt && cat /tmp/udpzivpnports.txt`;
#colores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GRAY='\033[1;37m'
WHITE='\033[1;37m'
RESET='\033[0m'
#menu
while true; do
  if [ $(id -u) -eq 0 ]; then
    clear
  else
    echo -e "Ejecuta el script como usuario root"
    exit
  fi
#instalarv1
function installv1(){
echo -e "${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}Esta opcion instalara ZiVPN-MOD version 1, rango de puertos UDP 20000:50000 redirigido al 5666"
echo -e "${YELLOW}Continuar?"
while [[ ${yesno} != @(s|S|y|Y|n|N) ]]; do
read -p "[S/N]: " yesno
tput cuu1 && tput dl1
done
if [[ ${yesno} = @(s|S|y|Y) ]]; then
echo -e "${YELLOW}INSTALANDO.."
bash <(curl -fsSL https://raw.githubusercontent.com/JotchuaDevz/UDP-ZIVPN-MOD/refs/heads/main/ziv1.sh)
fi
}
#instalarv2
function installv2(){
echo -e "${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}Esta opcion instalara ZiVPN-MOD version 2 AMD, rango de puertos UDP 6000:19999 redirigido al 5667"
echo -e "${YELLOW}Continuar?"
while [[ ${yesno} != @(s|S|y|Y|n|N) ]]; do
read -p "[S/N]: " yesno
tput cuu1 && tput dl1
done
if [[ ${yesno} = @(s|S|y|Y) ]]; then
echo -e "${YELLOW}INSTALANDO.."
bash <(curl -fsSL https://raw.githubusercontent.com/JotchuaDevz/UDP-ZIVPN-MOD/refs/heads/main/ziv2.sh)
fi
}
#instalarv3
function installv3(){
echo -e "${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}Esta opcion instalara ZiVPN-MOD version 2 ARM, rango de puertos UDP 6000:19999 redirigido al 5667"
echo -e "${YELLOW}Continuar?"
while [[ ${yesno} != @(s|S|y|Y|n|N) ]]; do
read -p "[S/N]: " yesno
tput cuu1 && tput dl1
done
if [[ ${yesno} = @(s|S|y|Y) ]]; then
echo -e "${YELLOW}INSTALANDO.."
bash <(curl -fsSL https://raw.githubusercontent.com/JotchuaDevz/UDP-ZIVPN-MOD/refs/heads/main/ziv2.sh)
fi
}
#desinstalar
function uninstall(){
echo -e "${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}Esta opcion desinstalara el servidor ZiVPN-MOD en cualquiera de sus versiones"
echo -e "${YELLOW}Continuar?"
while [[ ${yesno} != @(s|S|y|Y|n|N) ]]; do
read -p "[S/N]: " yesno
tput cuu1 && tput dl1
done
if [[ ${yesno} = @(s|S|y|Y) ]]; then
echo -e "${YELLOW}DESINSTALANDO.."
bash <(curl -fsSL https://raw.githubusercontent.com/powermx/zivpn/main/uninstall.sh)
fi
}
#iniciar
function startzivpn(){
echo -e "${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}Esta opcion iniciara el servidor ZiVPN-MOD"
echo -e "${YELLOW}Continuar?"
while [[ ${yesno} != @(s|S|y|Y|n|N) ]]; do
read -p "[S/N]: " yesno
tput cuu1 && tput dl1
done
if [[ ${yesno} = @(s|S|y|Y) ]]; then
echo -e "${YELLOW}INICIANDO.."
        echo -e "${YELLOW}Verificando servicios ZiVPN-MOD..."
        if [[ -f /etc/systemd/system/zivpn.service ]]; then
            echo -e "${YELLOW}Iniciando servicio ZiVPN-MOD..."
            sudo systemctl start zivpn.service
        fi
        if [[ -f /etc/systemd/system/zivpn_backfill.service ]]; then
            echo -e "${YELLOW}Iniciando servicio ZiVPN-MOD Backfill..."
            sudo systemctl start zivpn_backfill.service
        fi
        echo -e "${YELLOW}LISTO!"
fi
}
#detener
function stopzivpn(){
echo -e "${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}Esta opcion detendra el servidor ZiVPN-MOD"
echo -e "${YELLOW}Continuar?"
while [[ ${yesno} != @(s|S|y|Y|n|N) ]]; do
read -p "[S/N]: " yesno
tput cuu1 && tput dl1
done
if [[ ${yesno} = @(s|S|y|Y) ]]; then
echo -e "${YELLOW}DETENIENDO.."
        echo -e "${YELLOW}Verificando servicios ZiVPN-MOD..."
        if [[ -f /etc/systemd/system/zivpn.service ]]; then
            echo -e "${YELLOW}Deteniendo servicio ZiVPN-MOD..."
            sudo systemctl stop zivpn.service
        fi
        if [[ -f /etc/systemd/system/zivpn_backfill.service ]]; then
            echo -e "${YELLOW}Deteniendo servicio ZiVPN-MOD Backfill..."
            sudo systemctl stop zivpn_backfill.service
        fi
        echo -e "${YELLOW}LISTO!"
fi
}
#reiniciar
function restartzivpn(){
echo -e "${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}Esta opcion reiniciara el servidor ZiVPN-MOD"
echo -e "${YELLOW}Continuar?"
while [[ ${yesno} != @(s|S|y|Y|n|N) ]]; do
read -p "[S/N]: " yesno
tput cuu1 && tput dl1
done
if [[ ${yesno} = @(s|S|y|Y) ]]; then
echo -e "${YELLOW}REINICIANDO.."
        echo -e "${YELLOW}Verificando servicios ZiVPN-MOD..."
        if [[ -f /etc/systemd/system/zivpn.service ]]; then
            echo -e "${YELLOW}Reiniciando servicio ZiVPN-MOD..."
            sudo systemctl restart zivpn.service
        fi
        if [[ -f /etc/systemd/system/zivpn_backfill.service ]]; then
            echo -e "${YELLOW}Reiniciando servicio ZiVPN-MOD Backfill..."
            sudo systemctl restart zivpn_backfill.service
        fi
        echo -e "${YELLOW}LISTO!"
fi
}
#agregar usuario
function adduser_uri(){
echo -e "${RED} ────────────── /// ─────────────── "

if grep -q "5666" /etc/systemd/system/zivpn.service 2>/dev/null; then
    PORT=5666
    VERSION="v1"
elif grep -q "5667" /etc/systemd/system/zivpn.service 2>/dev/null; then
    PORT=5667
    VERSION="v2"
else
    echo -e "${RED}ZiVPN-MOD no esta instalado."
    return
fi

echo -e "${YELLOW}ZiVPN $VERSION detectado en puerto $PORT"
echo -e "${RED} ────────────── /// ─────────────── "
read -p "Ingresa la nueva contrasena: " NEW_USER

if [ -z "$NEW_USER" ]; then
    echo -e "${RED}La contrasena no puede estar vacia."
    return
fi

CURRENT_PASSWORDS=$(python3 -c "
import json
with open('/etc/zivpn/config.json') as f:
    data = json.load(f)
print(','.join(data['auth']['config']))
" 2>/dev/null)

if [ -n "$CURRENT_PASSWORDS" ]; then
    ALL_PASSWORDS="${CURRENT_PASSWORDS},${NEW_USER}"
else
    ALL_PASSWORDS="${NEW_USER}"
fi

IFS=',' read -r -a arr <<< "$ALL_PASSWORDS"
new_config_str="\"config\": [$(printf "\"%s\"," "${arr[@]}" | sed 's/,$//')]"
sed -i -E "s|\"config\": \[[^\]]*\]|${new_config_str}|" /etc/zivpn/config.json

systemctl restart zivpn.service

URI="udp-zivpn-labx://${IP}:${PORT}?password=${NEW_USER}"

echo -e "\n${GREEN}=============================="
echo -e "  Usuario agregado exitosamente"
echo -e "==============================${RESET}"
echo -e "${YELLOW}Contrasena: ${WHITE}${NEW_USER}"
echo -e "${YELLOW}URI:        ${WHITE}${URI}"
echo -e "${GREEN}==============================${RESET}\n"
read -p "Presiona Enter para continuar..."
}

#mostrar uris
function showuris(){
echo -e "${RED} ────────────── /// ─────────────── "

if grep -q "5666" /etc/systemd/system/zivpn.service 2>/dev/null; then
    PORT=5666
elif grep -q "5667" /etc/systemd/system/zivpn.service 2>/dev/null; then
    PORT=5667
else
    echo -e "${RED}ZiVPN-MOD no esta instalado."
    return
fi

PASSWORDS=$(python3 -c "
import json
with open('/etc/zivpn/config.json') as f:
    data = json.load(f)
for p in data['auth']['config']:
    print(p)
" 2>/dev/null)

echo -e "\n${GREEN}=============================="
echo -e "       URIs de conexion"
echo -e "==============================${RESET}"
while IFS= read -r passwd; do
    URI="udp-zivpn-labx://${IP}:${PORT}?password=${passwd}"
    echo -e "${YELLOW}Contrasena: ${WHITE}${passwd}"
    echo -e "${YELLOW}URI:        ${WHITE}${URI}"
    echo -e "${GREEN}------------------------------${RESET}"
done <<< "$PASSWORDS"
read -p "Presiona Enter para continuar..."
}

  if [[ $1 == "" ]]; then
    clear && printf '\e[3J'
echo -e "${GRAY}[${RED}-${GRAY}]${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}   【          ${RED}ZiVPN-MOD            ${YELLOW}】 "
echo -e "${YELLOW} › ${WHITE}Distribucion:${GREEN} $distribution "
echo -e "${YELLOW} › ${WHITE}IP:${GREEN} $IP "
echo -e "${YELLOW} › ${WHITE}Red:${GREEN} $Network "
echo -e "${YELLOW} › ${WHITE}Ejecutando:${GREEN} $ports "
echo -e "${GRAY}[${RED}-${GRAY}]${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW}[${GREEN}1${YELLOW}] ${RED} › ${WHITE} INSTALAR ZiVPN-MOD V1 (5666) [Descontinuado]
${YELLOW}[${GREEN}2${YELLOW}] ${RED} › ${WHITE} INSTALAR ZiVPN-MOD V2 AMD (5667) [Recomendado]
${YELLOW}[${GREEN}3${YELLOW}] ${RED} › ${WHITE} INSTALAR ZIVPN V2 ARM (5667)
${YELLOW}[${GREEN}4${YELLOW}] ${RED} › ${WHITE} DESINSTALAR ZiVPN-MOD
${YELLOW}[${GREEN} ${YELLOW}] ${RED} › ${WHITE} ────────
${YELLOW}[${GREEN}5${YELLOW}] ${RED} › ${WHITE} INICIAR ZiVPN-MOD
${YELLOW}[${GREEN}6${YELLOW}] ${RED} › ${WHITE} DETENER ZiVPN-MOD
${YELLOW}[${GREEN}7${YELLOW}] ${RED} › ${WHITE} REINICIAR ZiVPN-MOD
${YELLOW}[${GREEN} ${YELLOW}] ${RED} › ${WHITE} ────────
${YELLOW}[${GREEN}8${YELLOW}] ${RED} › ${WHITE} AGREGAR USUARIO / VER URI
${YELLOW}[${GREEN}9${YELLOW}] ${RED} › ${WHITE} VER TODOS LOS URIs
${YELLOW}[${GREEN}0${YELLOW}] ${RED} › ${WHITE} SALIR
${GRAY}[${RED}-${GRAY}]${RED} ────────────── /// ─────────────── "
echo -e "${YELLOW} Δ ELIGE UNA OPCION:      ${YELLOW}"
read -p " : " option
tput cuu1 >&2 && tput dl1 >&2
else
option=$1
fi
case $option in
  1 | 01 )
   installv1;;
  2 | 02 )
   installv2;;
  3 | 03 )
   installv3;;
  4 | 04)
   uninstall;;
  5 | 05)
   startzivpn;;
  6 | 06)
   stopzivpn;;
  7 | 07)
   restartzivpn;;
  8 | 08)
   adduser_uri;;
  9 | 09)
   showuris;;
  0)
  exit;;
  *)
  continue;;
  esac
  break
  done
