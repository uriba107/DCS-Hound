    --- HOUND.ContactManager
    -- Wrapper for HOUND.ElintWorker
    -- @module HOUND.ContactManager
do
    --- HOUND.ElintWorker#Wrapper
    -- @type HOUND.ContactManager
    -- @within HOUND.ContactManager
    HOUND.ContactManager = {
        _workers = {}
    }

    HOUND.ContactManager.__index = HOUND.ContactManager

    --- returns ELINT worker for HoundId
    -- @param HoundInstanceId Hound Id
    -- @return @{HOUND.ElintWorker} for specified HoundInstanceId
    -- @within HOUND.ContactManager
    function HOUND.ContactManager.get(HoundInstanceId)
        if HOUND.ContactManager._workers[HoundInstanceId] then
            return HOUND.ContactManager._workers[HoundInstanceId]
        end

        local worker = HOUND.ElintWorker.create(HoundInstanceId)
        HOUND.ContactManager._workers[HoundInstanceId] = worker

        return HOUND.ContactManager._workers[HoundInstanceId]
    end
end
