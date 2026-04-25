# 1. إنشاء مجلد الخطوط
mkdir -p ~/.local/share/fonts/WindowsFonts

# 2. سحب الخطوط الأساسية من مجلد ويندوز
find /mnt/Windows/Windows/Fonts -type f -regextype posix-extended -iregex '.*\.(ttf|otf|ttc|fon|pfb|pfm|woff|woff2)$' -exec cp {} ~/.local/share/fonts/WindowsFonts/ 2>/dev/null \;

# 3. سحب الخطوط من برامج المستخدمين في ويندوز (لو موجودة)
find /mnt/Windows/Users/*/AppData/Local/Microsoft/Windows/Fonts -type f -regextype posix-extended -iregex '.*\.(ttf|otf|ttc|fon|pfb|pfm|woff|woff2)$' -exec cp {} ~/.local/share/fonts/WindowsFonts/ 2>/dev/null \;

# 4. تحديث كاش الخطوط علشان النظام يقرأهم
fc-cache -fv
