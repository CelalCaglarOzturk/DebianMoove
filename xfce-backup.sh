 #!/bin/bash
# usage of this script
# for backup use "./xfce-backup.sh backup"
# for restore from backup use "./xfce-backup.sh restore"
# while using restore, xfce4-backup.tar.gz have to be in the same directory with this script
MODE=$1 # mode
VERSION="0.1.5"

exists() {
  command -v "$1" >/dev/null 2>&1
}

if exists gsettings; then
    :
else
  echo 'Cannot detect gsettings'
  echo "Enabling 32bit repos"
  echo "Installing libglib2.0-bin"
  sudo dpkg --add-architecture i386
  sudo apt update
  sudo apt remove -y libreoffice*
  sudo apt upgrade -y
  sudo apt-get install -y libglib2.0-bin
  exit
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
    cp -rp "/usr/share/applications/firefox-opt.desktop" ./out/firefox-opt.desktop

    #Home

    cp -rp "$HOME/.config" ./out/.config

    #usr

    cp -rp "/usr/share/code/" ./out/code
    cp -rp "/usr/share/cura/" ./out/cura
    cp -rp "/usr/share/filezilla/" ./out/filezilla

    #etc

    sudo cp -rp "/etc/nala" ./out/etc/
    sudo cp -rp "/etc/apt/" ./out/etc/apt

    #opt

    mkdir "./out/opt" && cp -rp "/opt/firefox" ./out/opt/firefox

    #Unwanted file removal

    rm -r "./out/.config/dconf"
    rm -r "./out/.config/gtk-3.0"
    rm -r "./out/.config/ibus"
    rm -r "./out/.config/Mousepad"
    rm -r "./out/.config/pulse"    
    sudo rm "./out/etc/apt/sources.list.d/amdgpu.list"
    sudo rm "./out/etc/apt/sources.list.d/docker.list"
    sudo rm "./out/etc/apt/sources.list.d/element-io.list"
    sudo rm "./out/etc/apt/sources.list.d/ookla_speedtest-cli.list"
    sudo rm "./out/etc/apt/sources.list.d/rocm.list"
    sudo rm "./out/etc/apt/sources.list.d/tailscale.list"
    sudo rm "./out/etc/apt/sources.list.d/xanmod-release.list"
    echo "$THEME" >> ./out/Theme/currenttheme
    echo "$ICON" >> ./out/Icons/currenticon
    echo "$CURSOR" >> ./out/Cursor/currentcursor && echo "$CURSORSIZE" >> ./out/Cursor/currentsize
    echo "$VERSION" >> version
    tar --zstd -cf ./MooveNow.tar.zst out version
    rm version
}

backup() {
    if [ -f "./MooveNow.tar.zst" ]; then
        backupmain
        echo "backup file successfully overwritten!"
        echo "Please check files inside archive to ensure backup files are correct"
        echo "IF YOU SEE THIS MESSAGE IGNORE ERRORS"
    else
        backupmain
        echo "backup file successfully created!"
        echo "Please check files inside the archive to ensure backup files are correct"
        echo "IF YOU SEE THIS MESSAGE IGNORE ERRORS"
    fi
}

restore() {   
    tar --zstd -xf ./MooveNow.tar.zst
    #DOOM THE EXISTING XFCE4 CONF (It causes duplicated launchers)

    rm -rf "/$HOME/.config/xfce4"
    
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
    sudo cp -rp ./out/firefox-opt.desktop "/usr/share/applications/"

    #usr

    sudo mkdir -p "/usr/share/code" && sudo cp -rp ./out/code/* "/usr/share/code/"
    sudo mkdir -p "/usr/share/cura/" && sudo cp -rp ./out/cura/* "/usr/share/cura/"
    sudo mkdir -p "/usr/share/filezilla/" && sudo cp -rp ./out/filezilla/* "/usr/share/filezilla/"

    #etc

    sudo mkdir -p "/etc/nala" && sudo cp -rp ./out/etc/nala "/etc/"
    sudo cp -rp ./out/etc/apt/* "/etc/apt/"

    #opt

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
    else
        echo "couldn't find the config"
    fi
else
    echo "error '$MODE' is not an argument use 'backup' or 'restore'"
fi
