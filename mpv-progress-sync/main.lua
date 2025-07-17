-- Global variables ysed in different functions, so have to be declared globally
filepath = ''
folder = ''
duration = 0
position = 0
isPlaying = true
encode = nil


-- This function is called when mpv loads a file
mp.register_event("file-loaded", function()
    -- Decode is used to un-marshall JSON data
    decode = nil
    -- Call function to get users operating system
    myos = getOS()
    -- Call function to get current file
    filename = getFilename(myos)
    -- Strip filename of any escape characters
    filename = string.gsub(filename, "[^%w%.%-_]", "_")
    -- Get files duration from pv 
    duration = mp.get_property_number("duration")
    -- If the operating system is either Linux or Mac
    if myos == 'GNU/Linux' or myos == 'OSX' or myos == 'Darwin' then
        -- Set folder to save position of files and the script folder location itself
        linux_mac_position_folder = os.getenv("HOME") .. '/.config/mpv/mpv-positions/'
        linux_script_folder       = os.getenv("HOME") .. '/.config/mpv/scripts/mpv-progress-sync/lib/'
        -- Import decoder from from lunajson , call loadFile to open the file and then create a new decoder object
        decoder_file              = linux_script_folder .. 'decoder.lua'
        newdecoder                = loadfile(decoder_file)()
        decode                    = newdecoder()
        -- Import encoder from from lunajson , call loadFile to open the file and then create a new encoder object
        encoder_file              = linux_script_folder .. 'encoder.lua'
        newencoder                = loadfile(encoder_file)()
        encode                    = newencoder()
        -- Set global 'folder' where the position file is saved to the linux and mac location
        folder                    = linux_mac_position_folder
    end
    if myos == "Android" or myos == "Toybox" then

        -- Set folder to save position of files and the script folder location itself
        android_position_folder = "/storage/emulated/0/Android/media/is.xyz.mpv/mpv-positions/"
        android_script_folder =
        '/storage/emulated/0/Android/data/is.xyz.mpv/files/.config/mpv/scripts/mpv-progress-sync/lib/'
        -- Import decoder from from lunajson , call loadFile to open the file and then create a new decoder object
        decoder_file = android_script_folder .. 'decoder.lua'
        newdecoder = loadfile(decoder_file)()
        decode = newdecoder()
        -- Import encoder from from lunajson , call loadFile to open the file and then create a new encoder object
        encoder_file = android_script_folder .. 'encoder.lua'
        newencoder = loadfile(encoder_file)()
        encode = newencoder()
        -- Set global 'folder' where the position file is saved to the android location
        folder = android_position_folder
    end
    if myos == "Windows" then
        -- Set folder to save position of files and the script folder location itself
        windows_position_folder = os.getenv("USERPROFILE") ..
            '\\scoop\\apps\\mpv\\current\\portable_config\\mpv-positions\\'
        folder = windows_position_folder
        windows_script_folder = os.getenv("USERPROFILE") ..
            '\\scoop\\apps\\mpv\\current\\portable_config\\scripts\\mpv-progress-sync\\lib\\'
        -- Import decoder from from lunajson , call loadFile to open the file and then create a new decoder object
        decoder_file = windows_script_folder .. "decoder.lua"
        newdecoder = loadfile(decoder_file)()
        decode = newdecoder()
        -- Import encoder from from lunajson , call loadFile to open the file and then create a new encoder object
        encoder_file = windows_script_folder .. "encoder.lua"
        newencoder = loadfile(encoder_file)()
        encode = newencoder()
    end
    -- Set the filepath of the json file to be the combination of the folder and finelname with .json extension
    filepath = folder .. filename .. ".json"
    -- Attempt to open the 'positionFile' using the filepath
    local positionFile, err = io.open(filepath, "r")
    -- If the pssitionFile json is not present
    if not positionFile then
        print("Could not open position file for reading:", err)
        return
    -- Otherwise read the file and use lunajson's decode to un-marshall the Json
    else
        local content, err = positionFile:read("*all")
        local data = decode(content)
        if err then
            mp.osd_message(err .. " when opening the file " .. filepath .. ". Try deleting the file", "8")

            print(err)
        end
        -- Use the 'loc' (location) saved in the Json file and ask mpv to seek to that location in the opened file
        mp.commandv("seek", data.loc, "absolute+exact")
        -- Close the positionFile
        positionFile:close()
    end
end)

-- Create a periodic timer in mpv for every one second
timer = mp.add_periodic_timer(1, function()
    -- If the file is playing 
    if isPlaying then
        -- Set the position to the position that mpv has for the open file
        position = mp.get_property_number("time-pos")
    end
end)

mp.register_event("shutdown", function()
    -- Set isPlaying to false. This is because when existing mpv sets the 'time-pos' to nil so this stops the wrong position from being saved 
    isPlaying = false

    -- If the position is not nill and it is greater than 2 seconds 
    if position ~= nil and position > 2 then
        -- Sanitise the filename to remove escape characters
        filename = string.gsub(filename, "[^%w%.%-_]", "_")
        -- Get current OS
        myos = getOS()

        -- Create the folder to save the positions of open files
        if myos == "Windows" then
            os.execute("mkdir " .. folder)
        else
            os.execute("mkdir -p " .. folder)
        end
        -- Create the filepath to save the position 
        filepath = folder .. filename .. ".json"
        -- Open tthe file 
        positionFile, err = io.open(filepath, "w")
        if not positionFile then
            print("Error opening file to write:", err)
            return
        end

        -- Get the number of seconds left of the open file. If it is less than five seconds remaining then set the position of the file to zero
        local finalPosition = duration - position
        if finalPosition <= 5 then
            position = 0
        end
        -- Crete a table with the key 'loc'. The value is the opened files position 
        local data = {
            loc = position
        }

        -- Use lunajson's encode function to marshal Json data 
        local str = encode(data)
        -- Write the marshalled Json to the file
        positionFile:write(str)
        positionFile:close()
    end
end)


-- Helper function to load a file 
function loadFile(path)
    return assert(loadfile(path))()
end


-- Help function to get the filename of a file. Parameter is the operating system of the user
function getFilename(myos)

    -- Open the md5 function from kikito, dependent on the operating system being used, This function is used to create a hash of the opened files filename
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
    -- Get the title of the opened file in mpv
    title = mp.get_property("media-title")
    -- Use the md5 function to create a hash of the filename 
    title = md5.sumhexa(title)
    -- Return the hashed title
    return title
end


-- Heleer function to get the users operating system
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
