--// Services                                                                  --stupid upd made by Rukuu [discord: goc2v]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local lp = Players.LocalPlayer

--// Notify once on script load
StarterGui:SetCore("SendNotification", {
	Title = "Crouch Bot",
	Text = "Loaded. Say 'start' to begin.",
	Duration = 3
})

--// State
local isActive: boolean = false
local isSpamMode: boolean = false
local crouchSpeed: number = 0.2
local runningLoop: boolean = false

--// Crouch Loop
local function crouchBotLoop(): nil
	if runningLoop then return end
	runningLoop = true

	while isActive do
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
		task.wait(0.05)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)

		if not isActive then break end

		if isSpamMode then
			task.wait(0.05)
		else
			local t = tick()
			while tick() - t < crouchSpeed do
				if not isActive then break end
				task.wait(0.01)
			end
		end
	end

	runningLoop = false
end

--// Commands
local function startCommand(): nil
	if isActive then return end
	isActive = true
	isSpamMode = false
	task.spawn(crouchBotLoop)
end

local function stopCommand(): nil
	isActive = false
	isSpamMode = false
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end

local function speedCommand(value: string): nil
	local speedNum = tonumber(value)
	if speedNum and speedNum > 0 then
		crouchSpeed = speedNum
		isSpamMode = false
	end
end

local function spamCommand(): nil
	if not isActive then
		isActive = true
		isSpamMode = true
		task.spawn(crouchBotLoop)
	elseif not isSpamMode then
		isSpamMode = true
	end
end

local function normalCommand(): nil
	if not isActive then
		isActive = true
		isSpamMode = false
		task.spawn(crouchBotLoop)
	elseif isSpamMode then
		isSpamMode = false
	end
end

--// Command Handler
local function processCommand(msg: string): nil
	msg = msg:lower():gsub("^%s+", ""):gsub("%s+$", "")
	if msg == "start" then
		startCommand()
	elseif msg == "stop" then
		stopCommand()
	elseif msg == "spam" then
		spamCommand()
	elseif msg == "normal" then
		normalCommand()
	elseif msg:match("^speed%s+[%d%.]+$") then
		local val = msg:match("speed%s+([%d%.]+)")
		if val then speedCommand(val) end
	end
end

--// Chat Listener
local function setupChatListener(): nil
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		TextChatService.OnIncomingMessage = function(msg)
			if msg.TextSource and Players:GetPlayerByUserId(msg.TextSource.UserId) == lp then
				processCommand(msg.Text)
			end
		end
	else
		lp.Chatted:Connect(processCommand)
	end
end

setupChatListener()
