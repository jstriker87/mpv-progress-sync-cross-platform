lunajson_file = os.getenv("HOME") .. '/.config/mpv/scripts/lunajson/decoder.lua'
newdecoder = loadfile(lunajson_file)()
lunajson_file = os.getenv("HOME") .. '/.config/mpv/scripts/lunajson/encoder.lua'
newencoder = loadfile(lunajson_file)()
lunajson_file = os.getenv("HOME") .. '/.config/mpv/scripts/lunajson/sax.lua'
sax = loadfile(lunajson_file)()
--local newdecoder = require 'lunajson.decoder'
--local newencoder = require 'lunajson.encoder'
--local sax = require 'lunajson.sax'
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
	newparser = sax.newparser,
	newfileparser = sax.newfileparser,
}
