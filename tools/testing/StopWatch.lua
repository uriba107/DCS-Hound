do

    StopWatch = {
      name=nil,
      starttime = nil
    }
    StopWatch.__index = StopWatch

    function StopWatch:Start(name)
      local o = setmetatable({}, StopWatch)
      if name ~= nil and type(name) == "string" then
        o.name = name
      end
      if os == nil or os.clock == nil then return o end
      o.starttime = os.clock()
      return o
    end

    function StopWatch:Stop()
      if os == nil or os.clock == nil or self.starttime == nil then return nil end
      local stoptime = os.clock()
      local str = "[ StopWatch ] "
      if self.name ~= nil then
        str = str .. self.name .. " - "
      end
      str = str .. ((stoptime - self.starttime) * 1000) .." ms"
      env.info(str)
    end
end