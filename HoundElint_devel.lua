env.info("Loading Hound Scripts dynamicly")
-- local Loaderlfs=require('lfs')
-- env.info(Loaderlfs.currentdir())
local currentDir = "F:\\Dropbox\\uri\\Dropbox\\DCS\\Mission Building\\HoundElint\\"
assert(loadfile(currentDir..'test\\StopWatch.lua'))()
-- assert(loadfile(currentDir..'test\\luaunit.lua'))()

assert(loadfile(currentDir..'include\\DCS-SimpleTextToSpeech.lua'))()
assert(loadfile(currentDir..'src\\00 - HoundDBs.lua'))()
assert(loadfile(currentDir..'src\\01 - HoundGlobals.lua'))()
assert(loadfile(currentDir..'src\\02 - HoundUtils.lua'))()
assert(loadfile(currentDir..'src\\03 - HoundContact.lua'))()
assert(loadfile(currentDir..'src\\04 - HoundCommsManager.lua'))()
assert(loadfile(currentDir..'src\\05 - HoundElint.lua'))()

assert(loadfile(currentDir..'demo_mission\\HoundElint_demo.lua'))()
-- assert(loadfile(currentDir..'demo_mission\\Syria_POC\\Hound_Demo_SyADFGCI.lua'))()


env.info("Loading Done")

