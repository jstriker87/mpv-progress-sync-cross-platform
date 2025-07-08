filepath = ''
folder = ''
duration = 0
position = 0
dkjson = nil
isPlaying = true


mp.register_event("file-loaded", function()
    myos = getOS()
    filename = getFilename(myos)
    filename = string.gsub(filename, "[^%w%.%-_]", "_")
    duration = mp.get_property_number("duration")
    if myos == 'GNU/Linux' or myos == 'OSX' or myos == 'Darwin' then
        linux_mac_folder = os.getenv("HOME") .. "/Documents/mpv-positions/"
        dkjson_file = os.getenv("HOME") .. '/.config/mpv/scripts/dkjson.lua'
        dkjson = loadfile(dkjson_file)()
        folder = linux_mac_folder
    end
    if myos == "Android" or myos == "Toybox" then
        android_folder = "/storage/emulated/0/Android/media/is.xyz.mpv/mpv-positions/"
        dkjson = loadfile('/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/dkjson.lua')()
        folder = android_folder
    end
    if myos == "Windows" then
		dkjson_file = os.getenv("USERPROFILE") .. '\\scoop\\apps\\mpv\\current\\portable_config\\scripts\\dkjson.lua'
        dkjson = loadfile(dkjson_file)()
        windows_folder = os.getenv("USERPROFILE") .. '\\Documents\\mpv-positions\\'
        folder = windows_folder
    end
    filepath = folder .. filename .. ".json"
    filepath = folder .. filename .. ".json"
    local positionFile, err = io.open(filepath, "r")
    if not positionFile then
        print("Could not open position file for reading:", err)
        return
    else
        local content, err = positionFile:read("*all")
        local data, pos, err = dkjson.decode(content, 1, nil)
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
        cur_position = mp.get_property_number("time-pos")
        if cur_position ~= nil then
            position = cur_position
        end
    end
end)

mp.register_event("shutdown", function()
    isPlaying = false
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
    local str = dkjson.encode(data, { indent = true })
    positionFile:write(str)
    positionFile:close()
end)


function getFilename(myos)
    md5 = nil
    if myos == 'GNU/Linux' or myos == 'OSX' or myos == 'Darwin' then
        md5_file = os.getenv("HOME") .. '/.config/mpv/scripts/md5.lua'
        md5 = loadfile(md5_file)()
    end
    if myos == "Android" or myos == "Toybox" then
        md5 = loadfile('/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/md5.lua')()
    end
	if myos == "Windows" then
		md5_file = os.getenv("USERPROFILE") .. '\\scoop\\apps\\mpv\\current\\portable_config\\scripts\\md5.lua'
        md5 = loadfile(md5_file)()
	end

    title = mp.get_property("media-title")
    local file_format = mp.get_property("file-format")
    if string.find(file_format, "mp4") then
        file_format = ".mp4"
    end
    local title = title .. file_format
    title = md5.sumhexa(title)
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
