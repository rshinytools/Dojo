-- The profile worker owns saving. Arena callbacks run before its queue closes.
local Handoff = {}
local beforeClose = {}
local receiveReceipt

function Handoff.setReceiptReceiver(receiver)
    receiveReceipt = receiver
end

function Handoff.queueReceipt(player, window, completionId, matchId, raidId)
    return receiveReceipt ~= nil and receiveReceipt(player, window, completionId, matchId, raidId)
end

function Handoff.onProfileClose(settle)
    table.insert(beforeClose, settle)
end

function Handoff.close(player, now)
    for _, settle in beforeClose do
        local ok, message = pcall(settle, player, now)
        if not ok then
            warn("[Beast Dojo] Raid settlement failed before profile close: " .. tostring(message))
        end
    end
end

return table.freeze(Handoff)
