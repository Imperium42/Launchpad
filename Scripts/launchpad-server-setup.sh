#!/bin/bash
#check if we're running as root - this is required.

bIsRoot=false
if [ $(id -u) -eq 0 ]
then
    bIsRoot=true
else
    bIsRoot=false
    echo "This script needs to be run as root. Please run it with <sudo> or <gksudo>."
    exit 1
fi

#check if vsftpd is installed
#assume it is installed.
bIsVsftpdInstalled=true
echo "Checking for vsftpd..."

#if no, 
#ask user if it should be installed.
hash vsftpd 2>/dev/null || { echo >&2 "vsftpd is required software for this automated setup."; bIsVsftpdInstalled=false; }
if [ "$bIsVsftpdInstalled" = false ]
then
    read -p "Would you like to install it? [y/n] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        apt-get install vsftpd
    fi
else
    echo "Vsftpd was installed, proceeding."
    
#if yes, 
#modify the config options, uncommenting each
    echo "Allowing anonymous downloading of files..."
    sed -i "s/^#anonymous_enable/anonymous_enable/" /etc/vsftpd.conf
    sed -i "s/\(anonymous_enable *= *\).*/\1YES/" /etc/vsftpd.conf
    
    echo "Allowing local accounts to log in and write files..."
    sed -i "s/^#write_enable/write_enable/" /etc/vsftpd.conf
    sed -i "s/\(write_enable *= *\).*/\1YES/" /etc/vsftpd.conf
    
    echo "Setting local umask..."
    sed -i "s/^#local_umask/local_umask/" /etc/vsftpd.conf
    sed -i "s/\(local_umask *= *\).*/\1022/" /etc/vsftpd.conf

    echo "Prohibiting anonymous uploading of files..."
    sed -i "s/^#anon_upload_enable/anon_upload_enable/" /etc/vsftpd.conf
    sed -i "s/\(anon_upload_enable *= *\).*/\1NO/" /etc/vsftpd.conf

    
#create folders

    echo "Creating folder structure in /srv/ftp..."

    cd /srv/ftp
    mkdir game
    mkdir game/Win64
    mkdir game/Win32
    mkdir game/Linux
    mkdir game/Mac
    mkdir launcher

    chown -R root:ftp game
    chown root:ftp launcher

    chmod -R g+rwX game
    chmod -R o+r game
    chmod g+rwX launcher
    chmod o+r launcher

    read -p "You will need an account in the ftp group to upload files to the server. Would you like to use an existing account, or create a new one? [Create - y/ Existing - n] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        useradd -M --comment Launchpad-system -G ftp launchpad
        passwd launchpad
    else
        read -p "Input account name: " -r
        usermod -a -G ftp $REPLY
    fi
#/launcher
#/game/Win64
#/game/Linux
#/game/
    
    echo "Setup successful. You can now start uploading your game and/or launcher via your selected accounts."
fi

    




