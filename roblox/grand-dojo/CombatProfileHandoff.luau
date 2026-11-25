-- The profile worker owns saving. Arena callbacks run before its queue closes.
local Handoff = {}
local beforeClose = {}
local receivers = {}

function Handoff.setReceiptReceiver(kind, receiver)
    receivers[kind] = receiver
end

function Handoff.queueReceipt(kind, player, ...)
    local receiver = receivers[kind]
    return receiver ~= nil and receiver(player, ...)
end

function Handoff.onProfileClose(settle)
    table.insert(beforeClose, settle)
end

function Handoff.close(player, now)
    for _, settle in beforeClose do
        local ok, message = pcall(settle, player, now)
        if not ok then
            warn("[Beast Dojo] Combat settlement failed before profile close: " .. tostring(message))
        end
    end
end

return table.freeze(Handoff)
