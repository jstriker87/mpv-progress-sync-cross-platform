filepath = ''
folder = ''
duration = 0
position = 0
isPlaying = true
encode = nil
mp.register_event("file-loaded", function()
    decode = nil
    myos = getOS()
    filename = getFilename(myos)
    filename = string.gsub(filename, "[^%w%.%-_]", "_")
    duration = mp.get_property_number("duration")
    if myos == 'GNU/Linux' or myos == 'OSX' or myos == 'Darwin' then
        linux_mac_position_folder = os.getenv("HOME") .. '/.config/mpv/mpv-postions/'
        linux_script_folder       = os.getenv("HOME") .. '/.config/mpv/scripts/mpv-progress-sync/lib/'
        decoder_file              = linux_script_folder .. 'decoder.lua'
        newdecoder                = loadfile(decoder_file)()
        decode                    = newdecoder()
        encoder_file              = linux_script_folder .. 'encoder.lua'
        newencoder                = loadfile(encoder_file)()
        encode                    = newencoder()
        folder                    = linux_mac_position_folder
    end
    if myos == "Android" or myos == "Toybox" then
        android_position_folder = "/storage/emulated/0/Android/media/is.xyz.mpv/mpv-positions/"
        android_script_folder =
        '/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/mpv-progress-sync/lib/'
        decoder_file = android_script_folder .. 'decoder.lua'
        newdecoder = loadfile(decoder_file)()
        decode = newdecoder()
        encoder_file = android_script_folder .. 'encoder.lua'
        newencoder = loadfile(encoder_file)()
        encode = newencoder()
        folder = android_position_folder
    end
    if myos == "Windows" then
        windows_position_folder = os.getenv("USERPROFILE") ..
            '\\scoop\\apps\\mpv\\current\\portable_config\\mpv-positions\\'
        folder = windows_position_folder
        windows_script_folder = os.getenv("USERPROFILE") ..
            '\\scoop\\apps\\mpv\\current\\portable_config\\scripts\\mpv-progress-sync\\lib\\'
        decoder_file = windows_script_folder .. "decoder.lua"
        newdecoder = loadfile(decoder_file)()
        decode = newdecoder()
        encoder_file = windows_script_folder .. "encoder.lua"
        newencoder = loadfile(encoder_file)()
        encode = newencoder()
    end
    filepath = folder .. filename .. ".json"
    filepath = folder .. filename .. ".json"
    local positionFile, err = io.open(filepath, "r")

    if not positionFile then
        print("Could not open position file for reading:", err)
        return
    else
        local content, err = positionFile:read("*all")
        local data = decode(content)
        if err then
            mp.osd_message(err .. " when opening the file " .. filepath .. ". Try deleting the file", "8")

            print(err)
        end
        mp.commandv("seek", data.loc, "absolute+exact")
        positionFile:close()
    end
end)


timer = mp.add_periodic_timer(1, function()
    if isPlaying then
        position = mp.get_property_number("time-pos")
    end
end)

mp.register_event("shutdown", function()
    isPlaying = false

    if position ~= nil and position > 2 then
        filename = string.gsub(filename, "[^%w%.%-_]", "_")
        myos = getOS()

        if myos == "Windows" then
            os.execute("mkdir" .. folder)
        else
            os.execute("mkdir -p " .. folder)
        end
        filepath = folder .. filename .. ".json"
        positionFile, err = io.open(filepath, "w")
        if not positionFile then
            print("Error opening file to write:", err)
            return
        end

        local finalPosition = duration - position
        if finalPosition <= 5 then
            position = 0
        end
        local data = {
            loc = position
        }

        local str = encode(data)
        positionFile:write(str)
        positionFile:close()
    end
end)


function loadFile(path)
    return assert(loadfile(path))()
end

function getFilename(myos)
    md5 = nil
    if myos == 'GNU/Linux' or myos == 'OSX' or myos == 'Darwin' then
        md5 = loadFile(os.getenv("HOME") .. '/.config/mpv/scripts/mpv-progress-sync/lib/md5.lua')
    end
    if myos == "Android" or myos == "Toybox" then
        md5 = loadFile(
            '/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/mpv-progress-sync/lib/md5.lua')
    end
    if myos == "Windows" then
        md5 = loadFile(os.getenv("USERPROFILE") ..
            '\\scoop\\apps\\mpv\\current\\portable_config\\scripts\\mpv-progress-sync\\lib\\md5.lua')
    end

    title = mp.get_property("media-title")
    print("Oroginal title: ", title)
    local file_format = mp.get_property("file-format")
    title = md5.sumhexa(title)
    print("Hashed title: ", title)
    return title
end

function getOS()
    if jit then
        return jit.os
    end

    local fh, err = assert(io.popen("uname -o 2>/dev/null", "r"))
    if fh then
        osname = fh:read()
    end

    myos = osname or "Windows"
    return myos
end
