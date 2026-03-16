#!/bin/bash
# Zivpn UDP Module installer
# Creator Zahid Islam

echo -e "Actualizando servidor"
sudo apt-get update && apt-get upgrade -y
systemctl stop zivpn.service 1> /dev/null 2> /dev/null
echo -e "Descargando servicio UDP"
wget https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn 1> /dev/null 2> /dev/null
chmod +x /usr/local/bin/zivpn
mkdir /etc/zivpn 1> /dev/null 2> /dev/null
wget https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O /etc/zivpn/config.json 1> /dev/null 2> /dev/null

echo "Generando certificados:"
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"
sysctl -w net.core.rmem_max=16777216 1> /dev/null 2> /dev/null
sysctl -w net.core.wmem_max=16777216 1> /dev/null 2> /dev/null
cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=zivpn VPN Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zivpn
ExecStart=/usr/local/bin/zivpn -config /etc/zivpn/config.json server
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

echo -e "Usuarios/Contraseñas ZiVPN-MOD UDP"
read -p "Ingresa los usuarios separados por comas, ejemplo: user1,user2 (Enter para usar 'zi' por defecto): " input_config

if [ -n "$input_config" ]; then
    IFS=',' read -r -a config <<< "$input_config"
    if [ ${#config[@]} -eq 1 ]; then
        config+=(${config[0]})
    fi
else
    config=("zi")
fi

new_config_str="\"config\": [$(printf "\"%s\"," "${config[@]}" | sed 's/,$//')]"

sed -i -E "s/\"config\": ?\[[[:space:]]*\"zi\"[[:space:]]*\]/${new_config_str}/g" /etc/zivpn/config.json

systemctl enable zivpn.service
systemctl start zivpn.service
iptables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport 20000:50000 -j DNAT --to-destination :5666
ufw allow 20000:50000/udp
ufw allow 5666/udp
rm zi.* 1> /dev/null 2> /dev/null

# Generar URIs de conexion
SERVER_IP=$(curl -4 icanhazip.com 2>/dev/null)
PORT=5666

echo -e "\n\033[1;33m=============================="
echo -e "       URIs de conexion"
echo -e "==============================\033[0m"
for passwd in "${config[@]}"; do
    URI="udp-zivpn-labx://${SERVER_IP}:${PORT}?password=${passwd}"
    echo -e "\033[1;32mContrasena:\033[0m $passwd"
    echo -e "\033[1;32mURI:\033[0m $URI"
    echo -e "\033[1;33m------------------------------\033[0m"
done

echo -e "Instalacion completada"
