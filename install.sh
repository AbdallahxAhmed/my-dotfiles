#!/bin/bash

# إنشاء مجلد .config لو مش موجود
mkdir -p ~/.config

# قائمة بالمجلدات اللي هننقلها للـ Home
folders=("kitty" "fish" "mpv")

echo "🚀 Starting Dotfiles Installation..."

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
    echo "✅ ACPI Fix Applied and Enabled."
fi

echo "🎉 All done! Restart your terminal to see the changes."
