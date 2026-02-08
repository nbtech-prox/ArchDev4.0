// Forçar o Firefox a usar as cores do sistema GTK (Nordic)
user_pref("widget.content.gtk-theme-override", "Nordic");
user_pref("browser.display.use_system_colors", true);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1); // Usar seletor de ficheiros nativo (GTK)
user_pref("widget.wayland.opaque-region.enabled", false); // Correção para Wayland
