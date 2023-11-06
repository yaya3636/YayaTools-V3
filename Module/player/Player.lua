Player = {
    singleton = true,
    initCallback = true
}

Player.isInDialog = false

function Player:init(params)
    params = params or {}
    Logger = self.logger
end

-- Function

function Player:IsInDialog()
    return self.isInDialog
end

function Player:SetIsInDialog(isInDialog)
    --self.logger:debug("isInDialog = " .. tostring(isInDialog))
    self.isInDialog = isInDialog
end

-- Callback

function Player.cb_CharacterStatsListMessage(msg)
    --global:printMessage(tostring(msg))
end

function Player.cb_LeaveDialogMessage()
    Player:SetIsInDialog(false)
end

function Player.cb_ExchangeLeaveMessage()
    Player:SetIsInDialog(false)
end

function Player.cb_ExchangeStartedBidBuyerMessage()
    Player:SetIsInDialog(true)
end

function Player.cb_NpcDialogCreationMessage()
    Player:SetIsInDialog(true)
end

function Player.cb_ExchangeStartedWithStorageMessage()
    Player:SetIsInDialog(true)
end

function Player.cb_ZaapDestinationsMessage()
    Player:SetIsInDialog(true)
end

return Player