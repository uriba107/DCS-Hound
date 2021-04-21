env.info("Loading Hound Scripts dynamicly")
-- local Loaderlfs=require('lfs')
-- env.info(Loaderlfs.currentdir())
local currentDir = "F:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
assert(loadfile(currentDir..'include\\DCS-SimpleTextToSpeech_extend.lua'))()
assert(loadfile(currentDir..'src\\00 - HoundDBs.lua'))()
assert(loadfile(currentDir..'src\\01 - HoundGlobals.lua'))()
assert(loadfile(currentDir..'src\\02 - HoundUtils.lua'))()
assert(loadfile(currentDir..'src\\03 - HoundContact.lua'))()
assert(loadfile(currentDir..'src\\04 - HoundCommsManager.lua'))()
assert(loadfile(currentDir..'src\\05 - HoundElint.lua'))()

-- assert(loadfile(currentDir..'HoundElint_test.lua'))()
env.info("Loading Done")