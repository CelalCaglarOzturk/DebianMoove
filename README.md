This script is made for save and load all of my Debian 12 (Xfce) packages, configs, themes and icons.

Usage:
1. sudo bash postinstall.sh (it will get the requirements with apt)
2. bash xfce-backup.sh backup (to backup configs)
3. Wait for the compressing (wathc the filesize)
4. bash xfce-backup.sh restore (to install it on the new machine if it installs libglib redo this step)
5. All done!


Requirements 

GNU bash

Sudo

Coreutils

Gsettings

Xfconf-query

Tar & Gzip/Gunzip

