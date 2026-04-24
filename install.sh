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

# 4. إضافة بارتيشنات Windows و Data لـ fstab باستخدام ntfs3
echo "💾 Preparing NTFS partitions with high-performance ntfs3 driver..."

# تثبيت أداة الصيانة لضمان مسح الـ Dirty Bit
sudo pacman -S ntfs-3g --noconfirm --needed

DATA_UUID="01DC54AD072198F0"
WIN_UUID="106A13A76A13889C"

# خيارات ntfs3 الاحترافية:
# discard: مهم جداً لأن هاردك M.2 SSD (بيفعل خاصية TRIM لتحسين الأداء)
# force: بيجبر النظام يفتح الهارد حتى لو فيه مشاكل بسيطة في القفل
# prealloc: بيقلل تشتت الملفات وبيسرع الكتابة
MOUNT_OPTS="defaults,noauto,x-systemd.automount,uid=1000,gid=1000,fmask=0022,dmask=0022,windows_names,prealloc,discard,force"

# تنظيف الهاردات برمجياً قبل الـ Mount (عشان نتفادى مشكلة الـ Force القديمة)
echo "🧹 Cleaning NTFS 'Dirty Bit' for Data and Windows..."
sudo ntfsfix -d /dev/disk/by-uuid/$DATA_UUID 2>/dev/null
sudo ntfsfix -d /dev/disk/by-uuid/$WIN_UUID 2>/dev/null

if ! grep -q "$DATA_UUID" /etc/fstab; then
    echo "UUID=$DATA_UUID  /mnt/Data  ntfs3  $MOUNT_OPTS  0 0" | sudo tee -a /etc/fstab
fi

if ! grep -q "$WIN_UUID" /etc/fstab; then
    echo "UUID=$WIN_UUID  /mnt/Windows  ntfs3  $MOUNT_OPTS  0 0" | sudo tee -a /etc/fstab
fi

echo "🔄 Mounting partitions with ntfs3..."

sudo mount -a
# 5. سحب كل الخطوط من ويندوز (فلترة ذكية تمنع الـ Trash)
echo "🔤 Harvesting ALL valid fonts from Windows (No Trash)..."
mkdir -p ~/.local/share/fonts/WindowsFonts

# 1. سحب من مجلد النظام الأساسي لويندوز
if [ -d "/mnt/Windows/Windows/Fonts" ]; then
    echo "   -> Scanning System Fonts..."
    find /mnt/Windows/Windows/Fonts -type f -regextype posix-extended -iregex '.*\.(ttf|otf|ttc|fon|pfb|pfm|woff|woff2)$' -exec cp {} ~/.local/share/fonts/WindowsFonts/ 2>/dev/null \;
fi

# 2. سحب من مجلدات المستخدمين (AppData)
if [ -d "/mnt/Windows/Users" ]; then
    echo "   -> Scanning Users AppData Fonts..."
    find /mnt/Windows/Users/*/AppData/Local/Microsoft/Windows/Fonts -type f -regextype posix-extended -iregex '.*\.(ttf|otf|ttc|fon|pfb|pfm|woff|woff2)$' -exec cp {} ~/.local/share/fonts/WindowsFonts/ 2>/dev/null \;
fi

# تحديث كاش الخطوط في لينكس
echo "🔄 Updating Font Cache..."
fc-cache -fv
echo "✅ All clean Windows fonts successfully installed!"

echo "🎉 Congratulations! Your system is fully automated and ready."
