
    --- dump Intel Brief to json
    -- will dump intel summery to CSV in the DCS saved games folder
    -- requires desanitization of lfs and io modules
    -- @param[opt] filename target filename. (default: hound_contacts_%d.csv)
    function HoundElint:dumpIntelBrief(filename)
        if lfs == nil or io == nil then
            HOUND.Logger.info("cannot write file. please desanitize lfs and io")
            return
        end
        if not filename then
            filename = string.format("hound_contacts_%d.json",self:getId())
        end
        local report = {
            ReportGenerated = HoundUtils.Text.getTime(),
            ReportData = {}
        }
        for _,site in pairs(self.contacts:listAllSitesByRange()) do
            local siteItems = site:generateIntelBrief()
            table.insert(report.ReportData, siteItems)
        end
        local jsonFile = io.open(lfs.writedir() .. filename, "w+")
        jsonFile:write(net.lua2json(report))
        jsonFile:flush()
        jsonFile:close()
    end

