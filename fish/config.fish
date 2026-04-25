source /usr/share/cachyos-fish-config/cachyos-config.fish
starship init fish | source

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
end

# Updated path to the safe location
# Dynamic Fastfetch with Random Logos
function fastfetch
    # Pick a random image from the logos folder
    set random_logo (random choice ~/.config/kitty/assets/logos/*)
    
    # Run fastfetch with the chosen image
    command fastfetch --logo $random_logo --logo-type kitty --logo-width 40 --logo-padding-right 5
end

# Run it on startup
fastfetch

