    --- HoundContactManager
    -- Wrapper for HoundElintWorker
    -- @module HoundContactManager
do
    --- HoundElintWorker#Wrapper
    -- @type HoundContactManager
    -- @within HoundContactManager
    HoundContactManager = {
        _workers = {}
    }

    HoundContactManager.__index = HoundContactManager

    --- returns ELINT worker for HoundId
    -- @param HoundInstanceId Hound Id
    -- @return HoundElintWorker for specified HoundInstanceId
    -- @within HoundContactManager
    function HoundContactManager.get(HoundInstanceId)
        if HoundContactManager._workers[HoundInstanceId] then
            return HoundContactManager._workers[HoundInstanceId]
        end

        local worker = HoundElintWorker.create(HoundInstanceId)
        HoundContactManager._workers[HoundInstanceId] = worker

        return HoundContactManager._workers[HoundInstanceId]
    end
end
