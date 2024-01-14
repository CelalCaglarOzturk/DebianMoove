This script is made for save and load all of my Debian 12 (Xfce) packages, configs, themes and icons.

Usage:
1. bash xfce-backup.sh backup (it will get the requirements with apt and back it up)
2. Wait for the compressing (watch the filesize)
3. bash xfce-backup.sh restore (to install it on the new machine it will get the requirements with apt and restore your configs)
4. All done!


Requirements 

GNU bash

Sudo

Coreutils

Gsettings

Xfconf-query

Tar & Gzip/Gunzip

