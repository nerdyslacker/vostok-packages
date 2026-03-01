#!/bin/bash
# Дополнительная конфигурация системы для Vostok Linux
# Выполняется ВНУТРИ chroot окружения Calamares

set -euo pipefail  # Добавляем pipefail для надёжности

echo "⚙️  Starting Vostok-specific system configuration..."

# ========== 1. НАСТРОЙКА SUDO ==========
echo "🔐 Configuring sudo permissions for wheel group..."
mkdir -p /etc/sudoers.d

# Более безопасный способ создания sudoers файла
cat > /tmp/vostok-wheel-sudoers << 'EOF'
# Разрешить участникам группы wheel выполнять любые команды
%wheel ALL=(ALL:ALL) ALL

# Примеры для Vostok Linux (раскомментируйте при необходимости):
# Разрешить обновление системы без пароля:
# %wheel ALL=(ALL) NOPASSWD: /usr/bin/xbps-install -Syu
# Разрешить управление сервисами без пароля:
# %wheel ALL=(ALL) NOPASSWD: /usr/bin/sv *
EOF

# Проверяем синтаксис перед применением
if visudo -c -f /tmp/vostok-wheel-sudoers 2>/dev/null; then
    cp /tmp/vostok-wheel-sudoers /etc/sudoers.d/wheel
    chmod 440 /etc/sudoers.d/wheel
    rm -f /tmp/vostok-wheel-sudoers
    echo "  ✅ Sudo configured for wheel group"
else
    echo "  ⚠️  Sudo configuration syntax error, skipping"
    rm -f /tmp/vostok-wheel-sudoers
fi

# ========== 2. СМЕНА ОБОЛОЧКИ ==========
echo "🐚 Setting default shells (sh/dash -> bash)..."

# Более эффективный подход с awk (однопроходный)
awk -F: '
    ($3 == 0 || $3 >= 1000) && 
    ($7 == "/bin/sh" || $7 == "/bin/dash") && 
    ($1 != "nobody" && $1 != "messagebus") {
        $7 = "/bin/bash"
        print "  ✅ Shell changed for: " $1
        changed++
    }
    {print $1 ":" $2 ":" $3 ":" $4 ":" $5 ":" $6 ":" $7}
' /etc/passwd > /etc/passwd.new

if [[ -f /etc/passwd.new ]] && [[ $(wc -l < /etc/passwd.new) -eq $(wc -l < /etc/passwd) ]]; then
    mv /etc/passwd.new /etc/passwd
    echo "  🔄 Shell update completed"
else
    echo "  ⚠️  Error updating /etc/passwd, keeping original"
    rm -f /etc/passwd.new
fi

# ========== 3. НАСТРОЙКА ОКРУЖЕНИЯ ==========
echo "🛡️  Configuring default environment..."

# Umask для всех оболочек
cat > /etc/profile.d/vostok-umask.sh << 'EOF'
# Vostok Linux default umask
if [ "$(id -u)" = 0 ]; then
    umask 022  # root - читаемость для всех
else
    umask 027  # пользователи - безопасность
fi
EOF

chmod +x /etc/profile.d/vostok-umask.sh

# Bashrc с проверкой существующих настроек
mkdir -p /etc/skel
if [[ ! -f /etc/skel/.bashrc ]] || ! grep -q "Vostok Linux bash configuration" /etc/skel/.bashrc 2>/dev/null; then
    cat >> /etc/skel/.bashrc << 'EOF'

# ============================================================================
# Vostok Linux bash configuration
# ============================================================================

# История
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
shopt -s histappend
export PROMPT_COMMAND="history -a; history -c; history -r"

# Фирменный промпт Vostok (бирюзовый)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;36m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi

# Полезные алиасы для Void Linux
alias vinst='sudo xbps-install -S'
alias vupd='sudo xbps-install -Syu'
alias vrem='sudo xbps-remove -R'
alias vclean='sudo xbps-remove -Oy'
alias vsearch='xbps-query -Rs'
alias vfiles='xbps-query -f'
alias vinfo='xbps-query -S'
alias vstat='sv status /var/service/*'
alias vlog='sudo svlogtail'

# Алиасы для системы
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Безопасность
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Утилиты
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Сеть
alias myip='curl -s ifconfig.me'
alias ports='sudo ss -tulpn'

# Функции
vkernel() {
    echo "Installed kernels:"
    xbps-query -s "linux[0-9]*" | grep "^ii"
}

vclean-all() {
    sudo xbps-remove -Oy
    sudo xbps-remove -o
    echo "Cleaning package cache..."
    sudo rm -rf /var/cache/xbps/*
}

EOF
    echo "  ✅ Created /etc/skel/.bashrc"
fi

# ========== 4. ПРИМЕНЕНИЕ К ПОЛЬЗОВАТЕЛЯМ ==========
echo "🏠 Syncing user home directories..."

# Функция для безопасного добавления конфигурации
add_bashrc_config() {
    local user_home="$1"
    local user_name="$2"
    local backup_file=""
    
    if [[ -f "$user_home/.bashrc" ]]; then
        # Делаем backup если файл существует
        backup_file="$user_home/.bashrc.vostok-backup-$(date +%Y%m%d)"
        cp "$user_home/.bashrc" "$backup_file"
        
        # Добавляем только если ещё нет нашей конфигурации
        if ! grep -q "Vostok Linux bash configuration" "$user_home/.bashrc"; then
            cat /etc/skel/.bashrc >> "$user_home/.bashrc"
            echo "  ✅ Updated .bashrc for $user_name (backup: $(basename $backup_file))"
        else
            echo "  ⏭️  .bashrc already configured for $user_name"
            rm -f "$backup_file"
        fi
    else
        # Файла нет - копируем полностью
        cp /etc/skel/.bashrc "$user_home/.bashrc"
        echo "  ✅ Created .bashrc for $user_name"
    fi
    
    # Восстанавливаем права
    chown "$user_name:$user_name" "$user_home/.bashrc" 2>/dev/null || true
    chmod 644 "$user_home/.bashrc"
}

# Обработка пользователей в /home
for home_dir in /home/*/; do
    home_dir="${home_dir%/}"  # Убираем trailing slash
    user_name=$(basename "$home_dir")
    
    if id "$user_name" >/dev/null 2>&1; then
        add_bashrc_config "$home_dir" "$user_name"
    fi
done

# Обработка root
add_bashrc_config "/root" "root"

# ========== 5. ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ VOID ==========
echo "📦 Additional Void Linux optimizations..."

# Настройка XBPS (если есть репозиторий Vostok)
if [[ -f /usr/share/vostok-mirrorlist ]]; then
    echo "  🔧 Configuring Vostok repositories..."
    mkdir -p /etc/xbps.d
    cp /usr/share/vostok-mirrorlist /etc/xbps.d/00-vostok-repository.conf
    xbps-install -S 2>/dev/null || true
fi

# Оптимизация для SSD
if lsblk -d -o ROTA 2>/dev/null | grep -q "^0"; then
    echo "  💾 SSD detected - enabling optimizations..."
    echo "noatime,discard" >> /etc/fstab 2>/dev/null || true
fi

# ========== 6. ФИНАЛЬНЫЕ ПРОВЕРКИ ==========
echo "🔍 Final checks..."

# Проверка настроек sudo
if sudo -l -U "$(whoami)" 2>&1 | grep -q "not allowed"; then
    echo "  ⚠️  Sudo may not be configured correctly for current user"
else
    echo "  ✅ Sudo configuration verified"
fi

# Проверка оболочки
if [[ "$SHELL" != "/bin/bash" ]]; then
    echo "  ℹ️  Current shell is $SHELL, bash will be active after relogin"
fi

echo "✅ Vostok-specific system configuration completed successfully!"
echo ""
echo "Summary:"
echo "  • Sudo configured for wheel group"
echo "  • Default shell set to bash"
echo "  • User environments configured"
echo "  • Void Linux optimizations applied"