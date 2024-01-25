#!/bin/bash
# usage of this script
# for backup use "./xfce-backup.sh backup"
# for restore from backup use "./xfce-backup.sh restore"
# while using restore, MooveNow.tar.zst have to be in the same directory with this script
MODE=$1 # mode
VERSION="0.6.1"

exists() {
  command -v "$1" >/dev/null 2>&1
}

# Prepare function

prepare(){
   
    # Enable 32bit repos
   
    sudo dpkg --add-architecture i386
    sudo apt update
   
    # Remove unwanted packages
   
    sudo apt remove -y libreoffice*
  
    # Packages to be installed

    packages=("libglib2.0-bin" "gpg" "apt-transport-https" "lutris" "qemu-kvm" "libvirt-clients" "libvirt-daemon-system" "bridge-utils" "virtinst" "libvirt-daemon" "steam-installer" "steam-devices" "okular" "pipewire" "pipewire-pulse" "wireplumber" "vlc" "radeontop" "gamemode" "mangohud" "timeshift" "qbittorrent" "filezilla" "openjdk-17-jre" "npm" "nodejs" "btop" "wget" "git" "file-roller" "flameshot" "flatpak" "galculator" "gnome-disk-utility" "gparted" "baobab" "neofetch")  
   
    # Unify packages

    install_command=$(printf "%s " "${packages[@]}")

    # Installation

    sudo apt upgrade -y $install_command

    # vm network set

    sudo virsh net-start default
    sudo virsh net-autostart default

    # Add Repo section

    # Vscode

    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    
    # Wine
    
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
    sudo apt update -y
    
    # Tailscale

    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

    #additional installation

    sudo apt update
    sudo apt install code tailscale -y
    sudo apt install --install-recommends winehq-staging -y

    if [ $? -ne 0 ]; then
    echo 'Package installation failed. Exiting.'
    exit
fi
}

if exists gsettings; then
    :
else
  echo 'Cannot detect gsettings, install libglib2.0-bin'
  prepare
fi

if exists xfconf-query; then
    :
else
    echo 'Cannot detect xfconf-query'
    exit
fi

if exists tar; then
    :
else
    echo 'Cannot detect tar'
    exit
fi

if exists gzip; then
    :
else
    echo 'Cannot detect gzip'
    exit
fi

if [ "$(id -u)" == 0 ]; then
    echo 'you must use this script as home user'
    exit
else
    :
fi

if [ -z "$1" ]; then
    echo 'Please read how to use.'
    exit
fi


# flatpak function

flatpak(){    

    # add flathub repos IT NEEDS RESTART OF THE SYSTEM

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak update

    # Packages to be installed

    flatpak install "org.nomacs.ImageLounge com.ultimaker.cura com.github.tchx84.Flatseal com.stremio.Stremio dev.vencord.Vesktop io.beekeeperstudio.Studio io.missioncenter.MissionCenter org.freedesktop.Piper net.davidotek.pupgui2 org.jdownloader.JDownloader net.brinkervii.grapejuice org.onlyoffice.desktopeditors org.prismlauncher.PrismLauncher org.signal.Signal"
  
  echo "Flatpak packages installed successfully. You may need to reboot your pc!"

}

# main backup function

backupmain() {

    #current themes
    
    eval THEME="$(gsettings get org.gnome.desktop.interface gtk-theme)"
    eval ICON="$(gsettings get org.gnome.desktop.interface icon-theme)"
    eval CURSOR="$(gsettings get org.gnome.desktop.interface cursor-theme)"
    eval CURSORSIZE="$(xfconf-query -c xsettings -p /Gtk/CursorThemeSize)"
    cp -rp "/usr/share/themes/$THEME" ./out/Theme
    mkdir "./out/Icons" && cp -rp "/usr/share/icons/$ICON" ./out/Icons
    cp -rp "/usr/share/icons/$CURSOR" ./out/Cursor

    #invididual files

    cp "$HOME/.bash_history" ./out/.bash_history
    cp "$HOME/.bashrc" ./out/.bashrc
    cp "$HOME/.gtkrc-2.0" ./out/.gtkrc-2.0
    cp "$HOME/.gitconfig" ./out/.gitconfig
    cp "$HOME/cab" ./out/cab
    cp "$HOME/cab.pub" ./out/cab.pub
    cp -rp "/usr/share/applications/firefox-opt.desktop" ./out/firefox-opt.desktop

    #Home

    cp -rp "$HOME/.config" ./out/.config

    #usr

    cp -rp "/usr/share/code/" ./out/code
    cp -rp "/usr/share/cura/" ./out/cura
    cp -rp "/usr/share/filezilla/" ./out/filezilla

    #etc

    sudo cp -rp "/etc/apt/" ./out/etc/apt

    #opt

    mkdir "./out/opt" && cp -rp "/opt/firefox" ./out/opt/firefox

    #Unwanted file removal

    rm -r "./out/.config/dconf"
    rm -r "./out/.config/gtk-3.0"
    rm -r "./out/.config/ibus"
    rm -r "./out/.config/Mousepad"
    rm -r "./out/.config/pulse"    
    sudo rm "./out/etc/apt/sources.list.d/tailscale.list"
    sudo rm "./out/etc/apt/sources.list.d/xanmod-release.list"
    echo "$THEME" >> ./out/Theme/currenttheme
    echo "$ICON" >> ./out/Icons/currenticon
    echo "$CURSOR" >> ./out/Cursor/currentcursor && echo "$CURSORSIZE" >> ./out/Cursor/currentsize
    echo "$VERSION" >> version
    tar --zstd -cf ./MooveNow.tar.zst out version
    rm version
    sudo rm -r ./out/
}

backup() {
    if [ -f "./MooveNow.tar.zst" ] && [ -s "./MooveNow.tar.zst" ]; then
        backupmain
        echo "backup file successfully overwritten!"
        echo "Please check files inside archive to ensure backup files are correct"
    else
        backupmain
        echo "backup file successfully created!"
        echo "Please check files inside the archive to ensure backup files are correct"
    fi
}

restore() {   
    tar --zstd -xf ./MooveNow.tar.zst
    #DOOM THE EXISTING XFCE4 CONF (It causes duplicated launchers)

    rm -r "/$HOME/.config/xfce4/"
    
    #COPY NEW CONF

    cp -rp ./out/.config "$HOME/"

    #Theme stuff

    THEME=$(cat ./Theme/currenttheme)
    ICON=$(cat ./Icons/currenticon)
    CURSOR=$(cat ./Cursor/currentcursor)
    CURSORSIZE=$(cat ./Cursor/currentsize)
    sudo cp -rp "./Theme/$THEME" "/usr/share/themes/"
    sudo cp -rp "./Icons/$ICON" "/usr/share/icons/"
    sudo cp -rp "./Cursor/$CURSOR" "/usr/share/icons/"
    xfconf-query -c xsettings -p /Net/ThemeName -s "$THEME"
    xfconf-query -c xsettings -p /Net/IconThemeName -s "$ICON"
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "$CURSOR"
    xfconf-query -c xsettings -p /Gtk/CursorThemeSize -s "$CURSORSIZE"

    #invididual files

    cp -rp ./out/.bash_history "$HOME/"
    cp -rp ./out/.bashrc "$HOME/"
    cp -rp ./out/.gtkrc-2.0 "$HOME/"
    cp -rp ./out/.gitconfig "$HOME/" 
    cp -rp ./out/cab "$HOME/"
    cp -rp ./out/cab.pub "$HOME/"
    sudo cp -rp ./out/firefox-opt.desktop "/usr/share/applications/"

    #usr

    sudo mkdir -p "/usr/share/code" && sudo cp -rp ./out/code/* "/usr/share/code/"
    sudo mkdir -p "/usr/share/cura/" && sudo cp -rp ./out/cura/* "/usr/share/cura/"
    sudo mkdir -p "/usr/share/filezilla/" && sudo cp -rp ./out/filezilla/* "/usr/share/filezilla/"

    #etc

    sudo cp -rp ./out/etc/apt/* "/etc/apt/"

    opt

    sudo mkdir -p "/opt/firefox/" && sudo cp -rp ./out/opt/firefox/* "/opt/firefox/"

    #cleaning section

    sudo apt autoremove -y
    
    echo "All of the configs successfully restored"
}

# Check for the mode

if [ "$MODE" = backup ]; then
    if [ -d "/$HOME/.config/xfce4/" ]; then
        # create an output file if it isn't exists
        if [ -d "./out/" ]; then
            :
        else
            mkdir out
        fi
        backup
    else
        echo "couldn't find the config"
    fi
elif [ "$MODE" = restore ]; then
    if [ -f "./MooveNow.tar.zst" ]; then
        restore
        flatpak
    else
        echo "couldn't find the config"
    fi
fi

