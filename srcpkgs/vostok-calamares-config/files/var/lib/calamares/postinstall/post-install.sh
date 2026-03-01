#!/bin/bash
# Главный пост-установочный скрипт Vostok Linux
# Выполняется ВНУТРИ chroot (благодаря dontChroot: false)

set -e

echo "⚙️ Starting Vostok Linux post-installation..."

# ========== 1. ЛОКАЛИ И ВРЕМЯ ==========
echo "🌐 Configuring locales and time..."

# Локали (только для GLIBC)
if [ -f /etc/locale.gen ]; then
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sed -i 's/^#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
    xbps-reconfigure -f glibc-locales 2>/dev/null || true
fi

# Часовой пояс (Европа/Москва)
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
echo "Europe/Moscow" > /etc/timezone

# ========== 2. НАСТРОЙКА СИСТЕМЫ ==========
echo "⚙️ Configuring system settings..."

# Настройка sudo для группы wheel
if [ -f /etc/sudoers ]; then
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

# Hostname
echo "vostok" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   vostok.localdomain vostok
EOF

# Брендинг
cat > /etc/issue << 'EOF'
[1;36m
    ╭─────────────────────────────────────╮
    │                                     │
    │ [1;32mVostok Linux[1;36m 1.0      │
    │      Fast · Clean · Simple          │
    │                                     │
    │      Based on Void Linux            │
    │          Runit · XBPS               │
    │                                     │
    ╰─────────────────────────────────────╯
[0m
EOF

# Создаем файл релиза
cat > /etc/vostok-release << EOF
VOSTOK LINUX RELEASE 1.0
Based on Void Linux
Kernel: $(uname -r)
Build date: $(date)
EOF

# ========== 3. СЕТЬ И БЕСПРОВОДНЫЕ ИНТЕРФЕЙСЫ ==========
echo "📡 Configuring network..."

# Отключаем dhcpcd (если есть) - конфликтует с NetworkManager
if [ -L /var/service/dhcpcd ] || [ -L /var/service/dhcpcd-* ]; then
    rm -f /var/service/dhcpcd /var/service/dhcpcd-* 2>/dev/null || true
    echo "  ✅ Removed dhcpcd services"
fi

# Настройка NetworkManager
cat > /etc/NetworkManager/conf.d/vostok.conf << EOF
[connection]
wifi.cloned-mac-address=stable
ethernet.cloned-mac-address=stable

[device]
wifi.scan-rand-mac-address=no

[main]
plugins=keyfile
dhcp=internal
EOF

# ========== 4. ВКЛЮЧАЕМ СЕРВИСЫ ==========
echo "🚀 Enabling Vostok system services..."

# ОСНОВНЫЕ СЕРВИСЫ (обязательные)
CORE_SERVICES=(
    "dbus"           # Системная шина
    "elogind"        # Управление сеансами
    "polkitd"        # Права доступа
    "udevd"          # Менеджер устройств
)

# СЕТЕВЫЕ СЕРВИСЫ
NETWORK_SERVICES=(
    "NetworkManager" # Управление сетью
)

# ГРАФИЧЕСКИЕ СЕРВИСЫ
GRAPHICS_SERVICES=(
    "sddm"           # Дисплейный менеджер KDE
    "rtkit"          # Real-time для звука
)

# ДОПОЛНИТЕЛЬНЫЕ СЕРВИСЫ
EXTRA_SERVICES=(
    "bluetoothd"     # Bluetooth
    "acpid"          # Управление питанием (ноутбуки)
    "sshd"           # SSH сервер (опционально)
)

# Функция включения сервиса
enable_service() {
    local svc="$1"
    local category="$2"
    
    if [ -d "/etc/sv/${svc}" ]; then
        ln -sf "/etc/sv/${svc}" "/var/service/"
        echo "  ✅ [$category] ${svc}"
    else
        echo "  ⚠️  [$category] ${svc} not found (package missing?)"
    fi
}

# Включаем сервисы группами
echo "Enabling core services..."
for svc in "${CORE_SERVICES[@]}"; do
    enable_service "$svc" "CORE"
done

echo "Enabling network services..."
for svc in "${NETWORK_SERVICES[@]}"; do
    enable_service "$svc" "NET"
done

echo "Enabling graphics services..."
for svc in "${GRAPHICS_SERVICES[@]}"; do
    enable_service "$svc" "GUI"
done

echo "Enabling extra services..."
for svc in "${EXTRA_SERVICES[@]}"; do
    enable_service "$svc" "EXTRA"
done

# Автоматическое определение и включение для SSD
if lsblk -d -o ROTA 2>/dev/null | grep -q "0"; then
    enable_service "fstrim" "SSD"
fi

# ========== 5. НАСТРОЙКА ГРУПП И ПОЛЬЗОВАТЕЛЕЙ ==========
echo "👥 Configuring user groups..."

# Создаем необходимые группы
groupadd -r autologin 2>/dev/null || true
groupadd -r _seatd 2>/dev/null || true

# Проверяем, что пользователь в нужных группах
USERNAME=$(ls /home/ | head -n1)
if [ -n "$USERNAME" ]; then
    usermod -a -G wheel,audio,video,storage,input,network,render,kvm,users "$USERNAME" 2>/dev/null || true
    echo "  ✅ Added $USERNAME to essential groups"
fi

# ========== 6. НАСТРОЙКА KDE ==========
echo "🎨 Configuring KDE Plasma..."

# Настройка SDDM (если установлен)
if [ -f /usr/bin/sddm ]; then
    mkdir -p /etc/sddm.conf.d
    cat > /etc/sddm.conf.d/vostok.conf << EOF
[Theme]
Current=breeze
CursorTheme=breeze_cursors
[General]
DisplayServer=wayland
EOF
fi

# Настройка обоев по умолчанию
if [ -f /usr/share/wallpapers/vostok-default.jpg ]; then
    mkdir -p /etc/skel/.config
    cp /usr/share/wallpapers/vostok-default.jpg /etc/skel/.config/
fi

# Создаем стандартные папки пользователя
mkdir -p /etc/skel/Desktop /etc/skel/Documents /etc/skel/Downloads /etc/skel/Music /etc/skel/Pictures /etc/skel/Videos

# ========== 7. ФИНАЛЬНАЯ КОНФИГУРАЦИЯ ==========
echo "🔧 Final system configuration..."

# Обновляем системные кэши
update-desktop-database 2>/dev/null || true
gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
fc-cache -f 2>/dev/null || true

# Переконфигурируем все пакеты
xbps-reconfigure -fa

# Очистка кэша, чтобы образ не распухал (если ставили из сети)
xbps-remove -Oy 2>/dev/null || true

# ========== 8. ИНФОРМАЦИЯ О ЗАВЕРШЕНИИ ==========
echo ""
echo "✅ Vostok Linux post-installation completed successfully!"
echo ""
echo "========================================"
echo "   SYSTEM READY FOR USE"
echo "========================================"
echo ""
echo "Services enabled:"
sv status /var/service/* | grep -E "run:|down:" || true
echo ""
echo "Next steps after reboot:"
echo "  1. Log in with your user account"
echo "  2. Run 'sudo xbps-install -Syu' to update"
echo "  3. Enjoy Vostok Linux! 🚀"
echo ""