#!/bin/bash

# === COLORES ===
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m' # Sin color

# Función para mostrar la barra de progreso
progress_bar() {
    let "cols = 40"  # Limitar el tamaño de la barra a 40 caracteres
    let "progress = $1*100/$2"
    let "bars = $progress*($cols)/100"
    let "empty = $cols-$bars"
    printf "["
    for i in $(seq 1 $bars); do printf "="; done
    for i in $(seq 1 $empty); do printf " "; done
    printf "] $progress%%\r"
}

clear
echo -e "${BLUE}==========================================="
echo -e "🛠️  ${YELLOW}Instalación Profesional de Odoo 17+ (rama master)${BLUE}"
echo -e "===========================================${NC}"

read -p "$(echo -e ${YELLOW}¿Deseas actualizar el sistema antes de instalar Odoo? [s/n]:${NC} )" actualizar
if [[ "$actualizar" == "s" ]]; then
    echo -e "${BLUE}📦 Actualizando sistema...${NC}"
    sudo apt update > /dev/null 2>&1 &
    pid=$!
    while kill -0 $pid 2>/dev/null; do
        progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
        sleep 0.1
    done
    sudo apt upgrade -y > /dev/null 2>&1 &
    pid=$!
    while kill -0 $pid 2>/dev/null; do
        progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
        sleep 0.1
    done
else
    echo -e "${YELLOW}⏭️  Saltando actualización del sistema...${NC}"
fi

echo -e "${BLUE}📥 Instalando dependencias necesarias para Odoo...${NC}"
sudo apt install -y build-essential wget python3-dev python3-venv python3-wheel \
libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev \
python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev libxslt1-dev \
libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev liblcms2-dev \
libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done

echo -e "${BLUE}👤 Creando usuario del sistema 'odoo'...${NC}"
sudo useradd -m -d /opt/odoo -U -r -s /bin/bash odoo > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done

echo -e "${BLUE}🐘 Instalando y configurando PostgreSQL...${NC}"
sudo apt install postgresql -y > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done
sudo systemctl status postgresql > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done

echo -e "${BLUE}🛠️  Creando usuario de base de datos para Odoo...${NC}"
sudo su - postgres -c "createuser -s odoo" > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done

echo -e "${BLUE}🧾 Instalando wkhtmltopdf (para PDF)...${NC}"
sudo apt install wkhtmltopdf -y > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done

echo -e "${BLUE}👨‍💻 Cambiando al usuario 'odoo' para instalar Odoo...${NC}"
sudo -u odoo -s <<'EOF'
cd ~
echo -e "🔄 Clonando repositorio de Odoo..."
git clone https://www.github.com/odoo/odoo --depth 1 --branch master --single-branch > /dev/null 2>&1
echo -e "🐍 Creando entorno virtual de Python..."
python3 -m venv odoo-venv
if [ -f "odoo-venv/bin/activate" ]; then
    source odoo-venv/bin/activate
    echo -e "📦 Instalando dependencias de Python..."
    pip3 install wheel > /dev/null 2>&1
    pip3 install -r odoo/requirements.txt > /dev/null 2>&1
    deactivate
else
    echo -e "${RED}❌ Error: El entorno virtual de Python no se pudo crear correctamente.${NC}"
    exit 1
fi
echo -e "📁 Creando carpeta para módulos personalizados..."
mkdir /opt/odoo/odoo-custom-addons > /dev/null 2>&1
EOF

echo -e "${BLUE}📝 Creando archivo de configuración en /etc/odoo.conf...${NC}"
sudo tee /etc/odoo.conf > /dev/null <<EOL
[options]
; Database operations password:
admin_passwd = CAMBIAESTOPORUNACONTRASEÑA
db_host = False
db_port = False
db_user = odoo
db_password = False
addons_path = /opt/odoo/odoo/addons,/opt/odoo/odoo-custom-addons
EOL

echo -e "${BLUE}⚙️  Creando servicio systemd en /etc/systemd/system/odoo.service...${NC}"
sudo tee /etc/systemd/system/odoo.service > /dev/null <<EOL
[Unit]
Description=Odoo
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo
PermissionsStartOnly=true
User=odoo
Group=odoo
ExecStart=/opt/odoo/odoo-venv/bin/python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOL

echo -e "${BLUE}🔄 Recargando daemon y activando servicio Odoo...${NC}"
sudo systemctl daemon-reload > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done
sudo systemctl enable --now odoo > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done

echo -e "${BLUE}📡 Verificando estado del servicio Odoo...${NC}"
sudo systemctl status odoo > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done

read -p "$(echo -e ${YELLOW}¿Deseas ver los logs del servicio Odoo ahora? [s/n]:${NC} )" ver_logs
if [[ "$ver_logs" == "s" ]]; then
    sudo journalctl -u odoo
fi

echo -e "${BLUE}🔁 Reiniciando servicio Odoo...${NC}"
sudo systemctl restart odoo > /dev/null 2>&1 &
pid=$!
while kill -0 $pid 2>/dev/null; do
    progress_bar $(( $(ps -p $pid -o pid= | wc -l) )) 1
    sleep 0.1
done

echo -e "${GREEN}✅ Instalación completada con éxito.${NC}"
echo -e "${GREEN}🌐 Accede a tu instancia de Odoo desde el navegador:${NC}"
echo -e "${BLUE}➡️  http://localhost:8069${NC}"
echo -e "${BLUE}📌 Usuario por defecto: admin (creas la contraseña al iniciar)${NC}"

echo -e "${YELLOW}⚠️  No olvides cambiar 'CAMBIAESTOPORUNACONTRASEÑA' en /etc/odoo.conf por una contraseña segura.${NC}"
