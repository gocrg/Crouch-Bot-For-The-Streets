-- Made by Rukuu (2y)
-- Discord: goc2v

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer

-- Notify script execution
StarterGui:SetCore("SendNotification", {
    Title = "Crouch Bot Status",
    Text = "Crouch Bot Script Loaded!",
    Duration = 5,
})

local function sendChatMessage(msg)
    msg = tostring(msg)
    local isLegacy = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService

    if isLegacy then
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local sayMsg = chatEvents and chatEvents:FindFirstChild("SayMessageRequest")
        if sayMsg then
            sayMsg:FireServer(msg, "All")
        end
    else
        local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(msg)
        end
    end
end

local function sendCommandList()
    sendChatMessage("Commands: start, stop, speed [value], spam, normal, help")
end

local isActive = false
local spamMode = false
local speedDelay = 0.2
local crouchCoroutine

local function crouchLoop()
    while isActive do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)

        if spamMode then
            task.wait() -- spam (0 seconds)
        else
            task.wait(speedDelay)
        end
    end
end

local function startCrouchBot()
    if isActive then
        sendChatMessage("Crouch Bot is already running!")
        return
    end

    isActive = true

    sendChatMessage("Crouch Bot Made By 2y/Rukuu")
    task.wait(2)
    sendChatMessage("bluey: goc2v")
    task.wait(1)
    sendCommandList()

    crouchCoroutine = coroutine.create(crouchLoop)
    coroutine.resume(crouchCoroutine)
end

local function stopCrouchBot()
    if not isActive and not spamMode then
        sendChatMessage("Crouch Bot is not running!")
        return
    end

    -- Stop crouching and disable spam mode
    isActive = false
    spamMode = false

    sendChatMessage("Crouch Bot Stopped (All modes disabled)")
    -- Coroutine will stop naturally because isActive = false
end

local function normalMode()
    if not isActive then
        isActive = true
        spamMode = false
        crouchCoroutine = coroutine.create(crouchLoop)
        coroutine.resume(crouchCoroutine)
        sendChatMessage("Crouch Bot started in Normal Mode (speed: " .. tostring(speedDelay) .. ")")
    else
        spamMode = false
        sendChatMessage("Crouch Bot switched to Normal Mode (speed: " .. tostring(speedDelay) .. ")")
    end
end

lp.Chatted:Connect(function(msg)
    local command = msg:lower()

    if command == "start" then
        startCrouchBot()
    elseif command == "stop" then
        stopCrouchBot()
    elseif command:match("^speed %d+%.?%d*$") then
        local val = tonumber(command:match("%d+%.?%d*"))
        if val then
            speedDelay = val
            spamMode = false
            sendChatMessage("Crouch speed set to " .. tostring(val))
        else
            sendChatMessage("Invalid speed value!")
        end
    elseif command == "spam" then
        spamMode = true
        isActive = true -- make sure crouching is active
        if not crouchCoroutine or coroutine.status(crouchCoroutine) == "dead" then
            crouchCoroutine = coroutine.create(crouchLoop)
            coroutine.resume(crouchCoroutine)
        end
        sendChatMessage("Spam mode enabled")
    elseif command == "normal" then
        normalMode()
    elseif command == "help" then
        sendCommandList()
    end
end)
