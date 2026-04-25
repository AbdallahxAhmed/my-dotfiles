# نقل الملف لمسار خدمات النظام
sudo cp acpi-wake-fix.service /etc/systemd/system/

# إعادة تحميل قائمة الخدمات علشان النظام يشوفه
sudo systemctl daemon-reload

# تفعيل الخدمة وتشغيلها فوراً
sudo systemctl enable --now acpi-wake-fix.service
