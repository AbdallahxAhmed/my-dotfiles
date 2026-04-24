#!/bin/bash

# إنشاء مجلد .config لو مش موجود
mkdir -p ~/.config

# قائمة بالمجلدات اللي هننقلها
folders=("kitty" "fish" "mpv")

echo "🚀 Starting Dotfiles Installation..."

for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        echo "📂 Linking $folder..."
        # حذف القديم لو موجود وعمل رابط سحري (Symlink)
        rm -rf ~/.config/$folder
        ln -s $(pwd)/$folder ~/.config/$folder
    fi
done

# نقل ملف starship المنفرد
if [ -f "starship.toml" ]; then
    echo "✨ Linking starship.toml..."
    rm -f ~/.config/starship.toml
    ln -s $(pwd)/starship.toml ~/.config/starship.toml
fi

echo "✅ Done! Restart your terminal to see the magic."
