# mpv-save-position
A cross platform script to save a files position when using mpv or mpv android


# [mpv Save Position]

A cross platform script to save a files position when using mpv or mpv android cross devices
A simple utility that uses MD5 hashing to process filenames (or other strings) for purposes like caching, unique identification, or obfuscation.

## Features

- Generate MD5 hashes from filenames or strings
- Easy-to-use script with minimal dependencies
- Useful for cache keys, data deduplication, or anonymized identifiers

## Requirements

- mpv or mpv-android

## 🚀 Usage

### Save location
- You can specify the location of where the save positions of files are stored by editing the locations in 'saveposition.lua' below
    - linux_folder
    - windows_folder
    - android_folder

### Linux
Copy all lua files to  /home/username/.config/mpv/scripts

### Android 
- NOTE: Since Android version 12 Google has restricted access to the data folder where the files need to be placed so please see the guide below



### Installation guide (non-rooted)

- In the Google Play Store install the files app 

[Files app (Play Store)](/sdcard/Android/data/is.xyz.mpv/files/.config/mpv/scripts/)


- Open the files App and navigate to /sdcard/Android/data/is.xyz.mpv/files/
- In this folder create the folders .config->mpv->scripts
- Copy the Lua files for this script to your phone (any location)
- NOTE: Using the Files App you will only be able to copy the files initially to the 'Android' foldeer
- For each Lua file open the Files app and select each file, select the three dots on the top right and select 'copy to'
- Copy each file to the 'Android' folder
- Then in the Files app open the Android folder
- You should now be able to see the 'data' folder
- Drag each Lua file into data->is.xyz.mpv->files->.config->mpv->scripts

- Open mpv-android
    - Press back button once
    - Go to Settings->Advanced - edit mpv.conf
    - add the following: script="/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/saveposition.lua"

### Installation guide (Rooted)
- Copy each Lua file into data->is.xyz.mpv->files->.config->mpv->scripts
- Open mpv-android
    - Press back button once
    - Go to Settings->Advanced - edit mpv.conf
    - add the following: script="/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/saveposition.lua"

## Dependencies / Acknowledgements
This project uses [**md5.lua**](https://github.com/kikito/md5.lua) by [@kikito](https://github.com/kikito), a pure Lua implementation of the MD5 message-digest algorithm.
> md5.lua is licensed under the MIT License.  
> https://github.com/kikito/md5.lua
