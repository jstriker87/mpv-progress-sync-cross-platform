# [mpv Save Position]

A cross platform script to save a files position when using mpv or mpv android across devices

## Background

- mpv does have save position option which can be set by adding '--save-position-on-quit' to mpv.conf
- However the issue is that the way in which this is carried out is specific to where the location was stored.
- If you have 'file.mp4' in your /home/Downloads folder and you also have 'file.mp4' in /home/Documents when you play the first file and then re-open the second file the progress will not be up to date
  - The progress is stored for each of these two files
- This also means that saving the location across devices will not work (due to the hashing process mpv uses to store the file location and name)

- This script solves this problem by only using the filename being opened
- The script stores the names of the files being opened using a hashing process so the names of the saved location files are private
- Note: To sync across devices you need to use an appropriate sync program. You can synchronise your different devices folders that store your media files progress in mpv that store your save positions using sync services such as [Syncthing](https://syncthing.net/)
  - This allows you to sync your progress of a media file in mpv very easily

## Requirements

- mpv or mpv-android

## Usage

- This script currently works on:
- Linux
- Android
- Windows

### Save location

- The script should work without any changes, however you can specify the location of where the save positions of files are stored by editing the locations in 'main.lua' below
  - linux_mac_positions_folder (default: /home/USERNAME/.config/mpv/mpv-positions
  - windows_positions_folder (default: C:\Users\USERNAME\scoop\apps\mpv\current\portable_config\mpv-positions
  - android_positions_folder (default: /storage/emulated/0/Android/media/is.xyz.mpv/mpv-positions/)

### Linux or Mac

Copy the folder 'mpv-progress-sync' to /hom:e/USERNAME/.config/mpv/scripts

### Windows

- mpv can be installed in a number of different ways
- The easiest way generally is to use a package manager
- This guide uses the package manager scoop

[Install Scoop](https://scoop.sh)
[Install mpv using Scoop](https://scoop.sh/#/apps?q=mpv&id=b05b47128464d8969416289383fbfc69a47353e3)

- If you are using scoop you will need to make the 'scripts' folder. To do this:

  - Open the folder: C:\Users\USERNAME\scoop\apps\mpv\current\portable_config\
  - Create a new folder called 'scripts'
  - Either clone this repository or copy the 'mpv-progress-sync' folder into this folder

- If you use an alternate package manager or method or installing mpv manually, you can edit the location of the two variables in 'main.lua' to the location where mpv's scripts folder should be:
  - dkjson_file
  - md5_file
  - The location of the mpv scripts folder when installing manually (e.g. not using Scoop) is normally: C:\Users\USERNAME\AppData\Roaming\mpv\scripts\

### Android

- NOTE: Since Android version 12 Google has restricted access to the data folder where the files need to be placed so please see the guide below

#### Installation guide (non-rooted)

- In the Google Play Store install the files app by Marc apps & software [Files app (Play Store)](https://play.google.com/store/apps/details?id=com.marc.files)

- Open the files App and navigate to /storage/emulated/0/Android/data/is.xyz.mpv/files/
- In this folder create the folders .config->mpv->scripts

  - The folder structure will look like this:
    Android
    data
    is.xyz.mpv
    files
    .config
    mpv
    scripts

- Clone this repository or Copy the folder 'mpv-progress-sync' to your phone (any location)
- NOTE: Using the Files App you will only be able to copy the files initially to the 'Android' folder
- Open the Files app and select the 'mpv-sync-progress' folder. Select the three dots on the top right and select 'copy to'
- Copy the folder to the 'Android' folder
- Then in the Files app open the Android folder
- You should now be able to see the 'data' folder
- Drag each Lua file from the 'Android' folder into data->is.xyz.mpv->files->.config->mpv->scripts
- [General video tutorial of using the Files app with the data folder](https://www.youtube.com/watch?v=HGzRx_HxrmQ)

- Open mpv-android
  - Press back button once
  - Go to Settings -> Advanced -> edit mpv.conf
  - add the following: script="/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/mpv-progress-sync/main.lua"

#### Installation guide (Rooted)

- Copy the folder mpv-progress-sync' to Android->data->is.xyz.mpv->files->.config->mpv->scripts
- Open mpv-android
  - Press back button once
  - Go to Settings->Advanced - edit mpv.conf
  - add the following: script="/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/mpv-progress-sync/main.lua"

## Dependencies / Acknowledgements

This project uses [**md5.lua**](https://github.com/kikito/md5.lua) by [@kikito](https://github.com/kikito), a pure Lua implementation of the MD5 message-digest algorithm.

> md5.lua is licensed under the MIT License.  
> https://github.com/kikito/md5.lua

This project uses [**lunajson**](https://github.com/grafi-tt/lunajson) from [@grafi-tt](https://github.com/grafi-tt), A strict and fast JSON parser/decoder/encoder written in pure Lua.

> lunajson is licensed under the MIT License.  
> https://github.com/grafi-tt/lunajson
