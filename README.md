This script is made for save and load all of my Debian 12 (Xfce) packages, configs, themes and icons.

Usage:
1. bash xfce-backup.sh prepare (it will get the requirements with apt)
2. bash xfce-backup.sh backup (Wait for the compressing watch the filesize)
3. bash xfce-backup.sh prepare (on the new machine)
4. bash xfce-backup.sh restore
5. All done!


Requirements 

GNU bash

Sudo

Coreutils

Gsettings

Xfconf-query

Tar & Gzip/Gunzip

