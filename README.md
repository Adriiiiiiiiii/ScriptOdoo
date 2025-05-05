# 🛠️ Odoo 17+ Auto Installation Script

Este script automatiza la instalación de **Odoo 17+ (rama master)** en sistemas basados en **Ubuntu 20.04+**, facilitando la configuración de las dependencias, la base de datos y la creación de un servicio **systemd** para Odoo.

---

## 📋 ¿Qué hace este script?

1. 📦 **Actualiza el sistema** (opcional, según elige el usuario).
2. 🔍 **Instala las dependencias necesarias** para Odoo, incluyendo PostgreSQL, wkhtmltopdf, librerías de Python y más.
3. 🧑‍💻 **Crea el usuario del sistema `odoo`** para la instalación.
4. 🛠️ **Configura PostgreSQL** para usar una base de datos con el usuario `odoo`.
5. 📂 **Clona el repositorio de Odoo** desde GitHub.
6. 🔒 **Configura un entorno virtual de Python** y **instala las dependencias de Python** necesarias para Odoo.
7. ⚙️ **Crea un servicio `systemd`** para Odoo, para que se inicie automáticamente al arrancar el sistema.
8. 💾 **Genera un archivo de configuración** para Odoo en `/etc/odoo.conf` con los parámetros necesarios.
9. 📝 **Muestra una barra de progreso** para visualizar el avance de cada tarea.

---

## ⚙️ Requisitos

- **Ubuntu 20.04+** (o versiones superiores).
- **Permisos de sudo**.
- **Acceso a una terminal interactiva** (por las interacciones del usuario durante la instalación).

---

## 🧑‍💻 Uso

1. **Clona el repositorio**:

   ```bash
   git clone https://github.com/Adriiiiiiiiii/odoo_installer.git
   cd odoo_installer
   chmod +x odoomulti.sh
   ./odoomulti.sh


