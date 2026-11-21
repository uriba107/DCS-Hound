    --- HOUND
    -- @module HOUND
do
    local version = (type(HOUND) == "table" and HOUND.VERSION) or "unknown"
    trigger.action.outText("Hound ELINT ("..version..") is loaded.", 15)
    env.info("[Hound] - finished loading (".. version ..")")
end
