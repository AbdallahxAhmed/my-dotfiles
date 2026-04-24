#!/bin/bash

# إنشاء مجلد .config لو مش موجود
mkdir -p ~/.config

# قائمة بالمجلدات اللي هننقلها للـ Home
folders=("kitty" "fish" "mpv")

echo "🚀 Starting Dotfiles & System Setup..."

# 1. ربط ملفات التخصيص (User Level)
for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        echo "📂 Linking $folder..."
        rm -rf ~/.config/$folder
        ln -s $(pwd)/$folder ~/.config/$folder
    fi
done

if [ -f "starship.toml" ]; then
    echo "✨ Linking starship.toml..."
    rm -f ~/.config/starship.toml
    ln -s $(pwd)/starship.toml ~/.config/starship.toml
fi

# 2. تطبيق ترقيعة الهاردوير (System Level)
if [ -f "acpi-wake-fix.service" ]; then
    echo "🛡️ Applying Gigabyte ACPI Wake Fix..."
    sudo cp acpi-wake-fix.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable --now acpi-wake-fix.service
    echo "✅ ACPI Fix Applied."
fi

# 3. إضافة بارتيشنات Windows و Data لـ fstab (System Level)
echo "💾 Checking fstab for Windows and Data partitions..."

# بيانات البارتيشنات الخاصة بك
DATA_UUID="01DC54AD072198F0"
WIN_UUID="106A13A76A13889C"
MOUNT_OPTS="defaults,noauto,x-systemd.automount,windows_names,uid=1000,gid=1000,umask=022"

# إضافة بارتيشن Data لو مش موجود
if ! grep -q "$DATA_UUID" /etc/fstab; then
    echo "➕ Adding Data partition to /etc/fstab..."
    echo "UUID=$DATA_UUID  /mnt/Data  ntfs-3g  $MOUNT_OPTS  0 0" | sudo tee -a /etc/fstab
else
    echo "ℹ️ Data partition already exists in fstab."
fi

# إضافة بارتيشن Windows لو مش موجود
if ! grep -q "$WIN_UUID" /etc/fstab; then
    echo "➕ Adding Windows partition to /etc/fstab..."
    echo "UUID=$WIN_UUID  /mnt/Windows  ntfs-3g  $MOUNT_OPTS  0 0" | sudo tee -a /etc/fstab
else
    echo "ℹ️ Windows partition already exists in fstab."
fi

echo "🎉 All done! Your system and terminal are now ready."
