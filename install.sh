#!/bin/bash

# إنشاء مجلد .config لو مش موجود
mkdir -p ~/.config

# 1. ربط ملفات التخصيص (User Level)
folders=("kitty" "fish" "mpv")
echo "🚀 Starting Master System Setup..."

for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        echo "📂 Linking $folder..."
        rm -rf ~/.config/$folder
        ln -s $(pwd)/$folder ~/.config/$folder
    fi
done

# ربط ملفات الإعدادات الفردية
files=("starship.toml" "baloofilerc")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✨ Linking $file..."
        rm -f ~/.config/$file
        ln -s $(pwd)/$file ~/.config/$file
    fi
done

# 2. ترقيعة NVIDIA للـ Sleep والشاشة السوداء (System Level)
echo "🏎️ Applying NVIDIA VRAM Preservation Fix..."
echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" | sudo tee /etc/modprobe.d/nvidia-sleep.conf
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
echo "✅ NVIDIA Fix Applied."

# 3. تطبيق ترقيعة الهاردوير للبوردة AORUS (System Level)
if [ -f "acpi-wake-fix.service" ]; then
    echo "🛡️ Applying Gigabyte ACPI Wake Fix..."
    sudo cp acpi-wake-fix.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable --now acpi-wake-fix.service
    echo "✅ ACPI Fix Applied."
fi

# 4. إضافة بارتيشنات Windows و Data لـ fstab (System Level)
echo "💾 Adding Windows and Data partitions to /etc/fstab..."
DATA_UUID="01DC54AD072198F0"
WIN_UUID="106A13A76A13889C"
MOUNT_OPTS="defaults,noauto,x-systemd.automount,windows_names,uid=1000,gid=1000,umask=022"

if ! grep -q "$DATA_UUID" /etc/fstab; then
    echo "UUID=$DATA_UUID  /mnt/Data  ntfs-3g  $MOUNT_OPTS  0 0" | sudo tee -a /etc/fstab
fi

if ! grep -q "$WIN_UUID" /etc/fstab; then
    echo "UUID=$WIN_UUID  /mnt/Windows  ntfs-3g  $MOUNT_OPTS  0 0" | sudo tee -a /etc/fstab
fi

echo "🎉 Congratulations! Your system is fully automated and ready."
