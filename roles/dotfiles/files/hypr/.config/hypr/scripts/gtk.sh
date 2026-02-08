#!/bin/bash

# Define os temas
gnome_schema="org.gnome.desktop.interface"
gtk_theme="Nordic"
icon_theme="Papirus-Dark"
cursor_theme="Bibata-Modern-Ice"
font_name="JetBrainsMono Nerd Font 11"

# Aplica as configurações via gsettings
gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
gsettings set "$gnome_schema" icon-theme "$icon_theme"
gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
gsettings set "$gnome_schema" font-name "$font_name"
gsettings set "$gnome_schema" color-scheme "prefer-dark"

# Garante que o tema GTK-4.0 também herde a preferência escura
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
