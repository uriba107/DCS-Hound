--- HOUND.ElintWorker
-- @module HOUND.ElintWorker
do
    local HoundUtils = HOUND.Utils

    --- Query functions
    -- @section Query

    --- list all contacts is a sector
    -- @param[type=?string] sectorName name or sector to filter by
    function HOUND.ElintWorker:listContactsInSector(sectorName)
        local emitters = {}
        for _,emitter in ipairs(self.contacts) do
            if emitter:isInSector(sectorName) then
                table.insert(emitters,emitter)
            end
        end
        table.sort(emitters,HoundUtils.Sort.ContactsByRange)
        return emitters
    end

    --- Return all contacts managed by this instance regardless of sectors
    -- @param[type=?string] sectorName name or sector to filter by
    function HOUND.ElintWorker:listAllContacts(sectorName)
        if sectorName then
            local contacts = {}
            for _,emitter in pairs(self.contacts) do
                if emitter:isInSector(sectorName) then
                        table.insert(contacts,emitter)
                end
            end
            return contacts
        end
        return self.contacts
    end

    --- Return all contacts managed by this instance sorted by range
    function HOUND.ElintWorker:listAllContactsByRange(sectorName)
        return self:sortContacts(HoundUtils.Sort.ContactsByRange,sectorName)
    end

    --- return number of contacts tracked
    -- @param[type=?string] sectorName name or sector to filter by
    function HOUND.ElintWorker:countContacts(sectorName)
        if sectorName then
            local contacts = 0
            for _,contact in pairs(self.contacts) do
                if contact:isInSector(sectorName) then
                    contacts = contacts + 1
                end
            end
            return contacts
        end
        return HOUND.Length(self.contacts)
    end

    --- return list of contacts
    -- @param[type=?string] sectorName sector to filter by
    -- @return list of @{HOUND.Contact.Emitter}
    function HOUND.ElintWorker:getContacts(sectorName)
        local contacts = {}
        for _,emitter in pairs(self.contacts) do
            if sectorName then
                if emitter:isInSector(sectorName) then
                    table.insert(contacts,emitter)
                end
            else
                table.insert(contacts,emitter)
            end
        end
        return contacts
    end

    --- return a sorted list of contacts
    -- @param sortFunc Function to sort by
    -- @param[type=?string] sectorName sector to filter by
    -- @return sorted list of @{HOUND.Contact.Emitter}
    function HOUND.ElintWorker:sortContacts(sortFunc,sectorName)
        if type(sortFunc) ~= "function" then return end
        local sorted = self:getContacts(sectorName)
        table.sort(sorted, sortFunc)
        return sorted
    end

    --- return number of contacts tracked
    -- @param[type=?string] sectorName name or sector to filter by
    function HOUND.ElintWorker:countSites(sectorName)
        if sectorName then
            local sites = 0
            for _,site in pairs(self.sites) do
                if site:isInSector(sectorName) then
                    sites = sites + 1
                end
            end
            return sites
        end
        return HOUND.Length(self.sites)
    end

    --- return list of contacts
    -- @param[type=?string] sectorName sector to filter by
    -- @return list of @{HOUND.Contact.Site}
    function HOUND.ElintWorker:getSites(sectorName)
        local sites = {}
        for _,site in pairs(self.sites) do
            if sectorName then
                if site:isInSector(sectorName) then
                    table.insert(sites,site)
                end
            else
                table.insert(sites,site)
            end
        end
        return sites
    end

    --- return a sorted list of contacts
    -- @param sortFunc Function to sort by
    -- @param[type=?string] sectorName sector to filter by
    -- @return sorted list of @{HOUND.Contact.Emitter}
    function HOUND.ElintWorker:sortSites(sortFunc,sectorName)
        if type(sortFunc) ~= "function" then return end
        local sorted = self:getSites(sectorName)
        table.sort(sorted, sortFunc)
        return sorted
    end

    --- Return all contacts managed by this instance regardless of sector
    -- @param[type=?string] sectorName name or sector to filter by
    function HOUND.ElintWorker:listAllSites(sectorName)
        if sectorName then
            local sites = {}
            for _,site in pairs(self.sites) do
                if site:isInSector(sectorName) then
                        table.insert(sites,site)
                end
            end
            return sites
        end
        return self.sites
    end

    --- return all contacts managed by this instance sorted by range
    function HOUND.ElintWorker:listAllSitesByRange(sectorName)
        return self:sortSites(HoundUtils.Sort.ContactsByRange,sectorName)
    end

end