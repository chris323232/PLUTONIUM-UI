local CUSTOMGUI = {
	Window = nil,
	Theme = nil,
	Creator = require("./modules/Creator"),
	LocalizationModule = require("./modules/Localization"),
	NotificationModule = require("./components/Notification"),
	Themes = nil,
	Transparent = false,

	TransparencyValue = 0.15,

	UIScale = 1,

	ConfigManager = nil,
	Version = "0.0.0",

	Services = require("./utils/services/Init"),

	OnThemeChangeFunction = nil,

	cloneref = nil,
	UIScaleObj = nil,

	CreateWindow = nil,

	CurrentInput = nil,
}

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

CUSTOMGUI.cloneref = cloneref

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

function CUSTOMGUI.GenerateGUID()
	return HttpService:GenerateGUID(false)
end

local CurInput = CUSTOMGUI.GenerateGUID()

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	--[[if GameProcessed then
		return
	end]]

	task.defer(function()
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			if CUSTOMGUI.CurrentInput and CUSTOMGUI.CurrentInput ~= CurInput then
				return
			end

			CUSTOMGUI.CurrentInput = CurInput
			--print(CurInput)
			--CUSTOMGUI.InputStartedOnUI = false
		end
	end)
end)
UserInputService.InputEnded:Connect(function(Input, GameProcessed)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		if CUSTOMGUI.CurrentInput and CUSTOMGUI.CurrentInput ~= CurInput then
			return
		end

		CUSTOMGUI.CurrentInput = nil
	end
end)

local LocalPlayer = Players.LocalPlayer or nil

local Package = HttpService:JSONDecode(require("../build/package"))
if Package then
	CUSTOMGUI.Version = Package.version
end

local KeySystem = require("./components/KeySystem")

local Creator = CUSTOMGUI.Creator

local New = Creator.New

--local Tween = Creator.Tween
--local ServicesModule = CUSTOMGUI.Services

local Acrylic = require("./utils/Acrylic/Init")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local GUIParent = gethui and gethui() or (CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

local UIScaleObj = New("UIScale", {
	Scale = CUSTOMGUI.UIScale,
})

CUSTOMGUI.UIScaleObj = UIScaleObj

CUSTOMGUI.ScreenGui = New("ScreenGui", {
	Name = "CUSTOMGUI",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = -99999,
}, {

	New("Folder", {
		Name = "Window",
	}),
	-- New("Folder", {
	--     Name = "Notifications"
	-- }),
	-- New("Folder", {
	--     Name = "Dropdowns"
	-- }),
	New("Folder", {
		Name = "KeySystem",
	}),
	New("Folder", {
		Name = "Popups",
	}),
	New("Folder", {
		Name = "ToolTips",
	}),
})

CUSTOMGUI.NotificationGui = New("ScreenGui", {
	Name = "CUSTOMGUI/Notifications",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
CUSTOMGUI.DropdownGui = New("ScreenGui", {
	Name = "CUSTOMGUI/Dropdowns",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
CUSTOMGUI.TooltipGui = New("ScreenGui", {
	Name = "CUSTOMGUI/Tooltips",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
ProtectGui(CUSTOMGUI.ScreenGui)
ProtectGui(CUSTOMGUI.NotificationGui)
ProtectGui(CUSTOMGUI.DropdownGui)
ProtectGui(CUSTOMGUI.TooltipGui)

Creator.Init(CUSTOMGUI)

function CUSTOMGUI:SetParent(parent)
	if CUSTOMGUI.ScreenGui then
		CUSTOMGUI.ScreenGui.Parent = parent
	end
	if CUSTOMGUI.NotificationGui then
		CUSTOMGUI.NotificationGui.Parent = parent
	end
	if CUSTOMGUI.DropdownGui then
		CUSTOMGUI.DropdownGui.Parent = parent
	end
	if CUSTOMGUI.TooltipGui then
		CUSTOMGUI.TooltipGui.Parent = parent
	end
end
math.clamp(CUSTOMGUI.TransparencyValue, 0, 1)

local Holder = CUSTOMGUI.NotificationModule.Init(CUSTOMGUI.NotificationGui)

function CUSTOMGUI:Notify(Config)
	Config.Holder = Holder.Frame
	Config.Window = CUSTOMGUI.Window
	--Config.CUSTOMGUI = CUSTOMGUI
	return CUSTOMGUI.NotificationModule.New(Config)
end

function CUSTOMGUI:SetNotificationLower(Val)
	Holder.SetLower(Val)
end

function CUSTOMGUI:SetFont(FontId)
	Creator.UpdateFont(FontId)
end

function CUSTOMGUI:OnThemeChange(func)
	CUSTOMGUI.OnThemeChangeFunction = func
end

function CUSTOMGUI:AddTheme(LTheme)
	CUSTOMGUI.Themes[LTheme.Name] = LTheme
	return LTheme
end

function CUSTOMGUI:SetTheme(Value)
	if CUSTOMGUI.Themes[Value] then
		CUSTOMGUI.Theme = CUSTOMGUI.Themes[Value]
		Creator.SetTheme(CUSTOMGUI.Themes[Value])

		if CUSTOMGUI.OnThemeChangeFunction then
			CUSTOMGUI.OnThemeChangeFunction(Value)
		end

		return CUSTOMGUI.Themes[Value]
	end
	return nil
end

function CUSTOMGUI:GetThemes()
	return CUSTOMGUI.Themes
end
function CUSTOMGUI:GetCurrentTheme()
	return CUSTOMGUI.Theme.Name
end
function CUSTOMGUI:GetTransparency()
	return CUSTOMGUI.Transparent or false
end
function CUSTOMGUI:GetWindowSize()
	return CUSTOMGUI.Window.UIElements.Main.Size
end
function CUSTOMGUI:Localization(LocalizationConfig)
	return CUSTOMGUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function CUSTOMGUI:SetLanguage(Value)
	if Creator.Localization then
		return Creator.SetLanguage(Value)
	end
	return false
end

function CUSTOMGUI:ToggleAcrylic(Value)
	if CUSTOMGUI.Window and CUSTOMGUI.Window.AcrylicPaint and CUSTOMGUI.Window.AcrylicPaint.Model then
		CUSTOMGUI.Window.Acrylic = Value
		CUSTOMGUI.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end

function CUSTOMGUI:Gradient(stops, props)
	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)

			local color = stop.Color
			if typeof(color) == "string" and string.sub(color, 1, 1) == "#" then
				color = Color3.fromHex(color)
			end

			local transparency = stop.Transparency or 0

			table.insert(colorSequence, ColorSequenceKeypoint.new(position, color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, transparency))
		end
	end

	table.sort(colorSequence, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(transparencySequence, function(a, b)
		return a.Time < b.Time
	end)

	if #colorSequence < 2 then
		table.insert(colorSequence, ColorSequenceKeypoint.new(1, colorSequence[1].Value))
		table.insert(transparencySequence, NumberSequenceKeypoint.new(1, transparencySequence[1].Value))
	end

	local gradientData = {
		Color = ColorSequence.new(colorSequence),
		Transparency = NumberSequence.new(transparencySequence),
	}

	if props then
		for k, v in pairs(props) do
			gradientData[k] = v
		end
	end

	return gradientData
end

function CUSTOMGUI:Popup(PopupConfig)
	PopupConfig.CUSTOMGUI = CUSTOMGUI
	return require("./components/popup/Init").new(PopupConfig, CUSTOMGUI.ScreenGui.Popups)
end

CUSTOMGUI.Themes = require("./themes/Init")(CUSTOMGUI, Creator)

Creator.Themes = CUSTOMGUI.Themes

CUSTOMGUI:SetTheme("Dark")
CUSTOMGUI:SetLanguage(Creator.Language)

function CUSTOMGUI:CreateWindow(Config)
	local CreateWindow = require("./components/window/Init")

	if not RunService:IsStudio() and writefile then
		if not isfolder("CUSTOMGUI") then
			makefolder("CUSTOMGUI")
		end
		if Config.Folder then
			makefolder(Config.Folder)
		else
			makefolder(Config.Title)
		end
	end

	Config.CUSTOMGUI = CUSTOMGUI
	Config.Window = CUSTOMGUI.Window
	Config.Parent = CUSTOMGUI.ScreenGui.Window

	if CUSTOMGUI.Window then
		warn("You cannot create more than one window")
		return
	end

	local CanLoadWindow = true

	local Theme = CUSTOMGUI.Themes[Config.Theme or "Dark"]

	--CUSTOMGUI.Theme = Theme
	Creator.SetTheme(Theme)

	local hwid = gethwid or function()
		return Players.LocalPlayer.UserId
	end

	local Filename = hwid()

	if Config.KeySystem then
		CanLoadWindow = false

		local function loadKeysystem()
			KeySystem.new(Config, Filename, function(c)
				CanLoadWindow = c
			end)
		end

		local keyPath = (Config.Folder or "Temp") .. "/" .. Filename .. ".key"

		if Config.KeySystem.KeyValidator then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isValid = Config.KeySystem.KeyValidator(savedKey)

				if isValid then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		elseif not Config.KeySystem.API then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isKey = (type(Config.KeySystem.Key) == "table") and table.find(Config.KeySystem.Key, savedKey)
					or tostring(Config.KeySystem.Key) == tostring(savedKey)

				if isKey then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		else
			if isfile(keyPath) then
				local fileKey = readfile(keyPath)
				local isSuccess = false

				for _, i in next, Config.KeySystem.API do
					local serviceData = CUSTOMGUI.Services[i.Type]
					if serviceData then
						local args = {}
						for _, argName in next, serviceData.Args do
							table.insert(args, i[argName])
						end

						local service = serviceData.New(table.unpack(args))
						local success = service.Verify(fileKey)
						if success then
							isSuccess = true
							break
						end
					end
				end

				CanLoadWindow = isSuccess
				if not isSuccess then
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		end

		repeat
			task.wait()
		until CanLoadWindow
	end

	local Window = CreateWindow(Config)

	CUSTOMGUI.Transparent = Config.Transparent
	CUSTOMGUI.Window = Window

	if Config.Acrylic then
		Acrylic.init()
	end

	-- function Window:ToggleTransparency(Value)
	--     CUSTOMGUI.Transparent = Value
	--     CUSTOMGUI.Window.Transparent = Value

	--     Window.UIElements.Main.Background.BackgroundTransparency = Value and CUSTOMGUI.TransparencyValue or 0
	--     Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and CUSTOMGUI.TransparencyValue or 0
	--     Window.UIElements.Main.Gradient.UIGradient.Transparency = NumberSequence.new{
	--         NumberSequenceKeypoint.new(0, 1),
	--         NumberSequenceKeypoint.new(1, Value and 0.85 or 0.7),
	--     }
	-- end

	return Window
end

return CUSTOMGUI
