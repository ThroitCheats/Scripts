--[==[Init UI]==]--
local levelUpLoader = Instance.new("ScreenGui")
local loaderFrame = Instance.new("Frame")
local loaderCorner = Instance.new("UICorner")
local DropShadowHolder = Instance.new("Frame")
local DropShadow = Instance.new("ImageLabel")
local mainLabel = Instance.new("TextLabel")
local keyBox = Instance.new("TextBox")
local keyUnderline = Instance.new("Frame")
local checkBtn = Instance.new("ImageButton")
local logsBorder = Instance.new("Frame")
local logsFrame = Instance.new("ScrollingFrame")
local logsLabel = Instance.new("TextLabel")
local close = Instance.new("ImageButton")
levelUpLoader.Name = "levelUpLoader"
levelUpLoader.Parent = game.CoreGui
levelUpLoader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loaderFrame.Name = "loaderFrame"
loaderFrame.Parent = levelUpLoader
loaderFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
loaderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
loaderFrame.BorderSizePixel = 0
loaderFrame.Position = UDim2.new(0.457841843, 0, 0.384381324, 0)
loaderFrame.Size = UDim2.new(0, 371, 0, 244)
loaderFrame.Active = true 
loaderFrame.Draggable = true
loaderCorner.Name = "loaderCorner"
loaderCorner.Parent = loaderFrame
DropShadowHolder.Name = "DropShadowHolder"
DropShadowHolder.Parent = loaderFrame
DropShadowHolder.BackgroundTransparency = 1.000
DropShadowHolder.BorderSizePixel = 0
DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
DropShadowHolder.ZIndex = 0
DropShadow.Name = "DropShadow"
DropShadow.Parent = DropShadowHolder
DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency = 1.000
DropShadow.BorderSizePixel = 0
DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
DropShadow.Size = UDim2.new(1, 47, 1, 47)
DropShadow.ZIndex = 0
DropShadow.Image = "rbxassetid://6014261993"
DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
DropShadow.ImageTransparency = 0.500
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
mainLabel.Name = "mainLabel"
mainLabel.Parent = loaderFrame
mainLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainLabel.BackgroundTransparency = 1.000
mainLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainLabel.BorderSizePixel = 0
mainLabel.Size = UDim2.new(0, 371, 0, 50)
mainLabel.Font = Enum.Font.Oswald
mainLabel.Text = "Level Up"
mainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
mainLabel.TextSize = 40.000
keyBox.Name = "keyBox"
keyBox.Parent = loaderFrame
keyBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
keyBox.BackgroundTransparency = 1.000
keyBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
keyBox.BorderSizePixel = 0
keyBox.Position = UDim2.new(0.0350404307, 0, 0.233606562, 0)
keyBox.Size = UDim2.new(0, 293, 0, 26)
keyBox.Font = Enum.Font.Oswald
keyBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
keyBox.PlaceholderText = "Paste Key Here"
keyBox.Text = script_key or ""
keyBox.TextColor3 = Color3.fromRGB(178, 178, 178)
keyBox.TextSize = 20.000
keyBox.ClearTextOnFocus = false
keyUnderline.Name = "keyUnderline"
keyUnderline.Parent = keyBox
keyUnderline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
keyUnderline.BorderColor3 = Color3.fromRGB(0, 0, 0)
keyUnderline.BorderSizePixel = 0
keyUnderline.Position = UDim2.new(0, 0, 1, 1)
keyUnderline.Size = UDim2.new(1.00687289, 0, 0, 1)
checkBtn.Name = "checkBtn"
checkBtn.Parent = loaderFrame
checkBtn.BackgroundTransparency = 1.000
checkBtn.LayoutOrder = 4
checkBtn.Position = UDim2.new(0.882132053, 0, 0.238196701, 0)
checkBtn.Size = UDim2.new(0, 25, 0, 25)
checkBtn.ZIndex = 2
checkBtn.Image = "rbxassetid://3926305904"
checkBtn.ImageRectOffset = Vector2.new(312, 4)
checkBtn.ImageRectSize = Vector2.new(24, 24)
logsBorder.Name = "logsBorder"
logsBorder.Parent = loaderFrame
logsBorder.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
logsBorder.BorderColor3 = Color3.fromRGB(255, 255, 255)
logsBorder.Position = UDim2.new(0.0350404307, 0, 0.389344275, 0)
logsBorder.Size = UDim2.new(0, 347, 0, 138)
logsFrame.Name = "logsFrame"
logsFrame.Parent = logsBorder
logsFrame.Active = true
logsFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
logsFrame.BackgroundTransparency = 1.000
logsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
logsFrame.BorderSizePixel = 0
logsFrame.Position = UDim2.new(0.0172910672, 0, 0, 0)
logsFrame.Size = UDim2.new(0, 340, 0, 138)
logsFrame.CanvasSize = UDim2.new(0, 0, 1, 0)
logsFrame.ScrollBarThickness = 3
logsLabel.Name = "logsLabel"
logsLabel.Parent = logsFrame
logsLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
logsLabel.BackgroundTransparency = 1.000
logsLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
logsLabel.BorderSizePixel = 0
logsLabel.Size = UDim2.new(0.982352912, 0, 1, 0)
logsLabel.Font = Enum.Font.Oswald
logsLabel.Text = "Level Up Loader launched...\n"
logsLabel.RichText = true
logsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logsLabel.TextSize = 20.000
logsLabel.TextXAlignment = Enum.TextXAlignment.Left
logsLabel.TextYAlignment = Enum.TextYAlignment.Top
close.Name = "close"
close.Parent = loaderFrame
close.BackgroundTransparency = 1.000
close.Position = UDim2.new(0.933000028, -5, 0, 5)
close.Size = UDim2.new(0, 25, 0, 25)
close.ZIndex = 2
close.Image = "rbxassetid://3926305904"
close.ImageRectOffset = Vector2.new(284, 4)
close.ImageRectSize = Vector2.new(24, 24)
local function updateLogSize()
    local textHeight = logsLabel.TextBounds.Y
    logsFrame.CanvasSize = UDim2.new(0, 0, 0, textHeight)
end
close.MouseButton1Click:connect(function() levelUpLoader:Destroy() end)

--[==[Init API]==]--
local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
local scriptId = "b0de7c4d81201b8837309655e4de6db7" -- Auto detect later  
api.script_id = scriptId
local gameName = "Trident Survival" -- Auto detect later
function secondsToTime(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    local parts = {}
    if days > 0 then table.insert(parts, days .. "d") end
    if hours > 0 then table.insert(parts, hours .. "h") end
    if minutes > 0 then table.insert(parts, minutes .. "m") end
    if seconds > 0 then table.insert(parts, seconds .. "s") end
    return #parts > 0 and table.concat(parts, " ") or "0s"
end

--[==[Loading Scripts]==]--
local function checkLoaded() 
    local gui = game.CoreGui:FindFirstChild("LevelUpUi")
    local ui = gui and gui:FindFirstChild("ui")
    local main = ui and ui:FindFirstChild("main")
    local top = main and main:FindFirstChild("top")
    return (top and top.Visible)
end
local function loadTrident() 
    local transfer = [[getgenv().script_key = "]]..getgenv().script_key..'"\n'
    if run_on_actor and ((getactors and getactors()[1]) or game.Players.LocalPlayer.PlayerScripts:FindFirstChildWhichIsA("Actor")) then
        run_on_actor(getactors()[1] or game.Players.LocalPlayer.PlayerScripts:FindFirstChildWhichIsA("Actor"),transfer..[[
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/b0de7c4d81201b8837309655e4de6db7.lua"))()
        ]])
        repeat wait(); until checkLoaded() 
        wait(1)
        levelUpLoader:Destroy()
    elseif tostring(string.lower(fastflag or "false")) == "true" then 

        script_key = getgenv().script_key
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/b0de7c4d81201b8837309655e4de6db7.lua"))()
        repeat wait(); until checkLoaded() 
        wait(1)
        levelUpLoader:Destroy()
    end
end

--[==[Check Key]==]--
local checking = false 
checkBtn.MouseButton1Click:connect(function()
    if checking then return end 
    checking = true 
    logsLabel.Text = logsLabel.Text .. 'Communicating with Luarmor...\n';wait(.1);updateLogSize();
    getgenv().script_key = keyBox.Text
    local script_key = keyBox.Text
    local status = api.check_key(script_key)
    if (status.code == "KEY_VALID") then
        local secondsLeft = status.data.auth_expire - os.time()
        logsLabel.Text = logsLabel.Text .. 'User key is <font color="#00FF00">valid</font>!\n'
        wait(.1)
        logsLabel.Text = logsLabel.Text .. 'Time remaining: <font color="#00ffff">'..(secondsToTime(secondsLeft))..'</font>\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Total Executions: <font color="#00ffff">'..tostring(status.data.total_executions)..'</font>\n'; wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Payment Method: <font color="#00ffff">'..(status.data.note)..'</font>\n'; wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Launching script for "<font color="#ff00c8">'..(gameName)..'</font>"\n'; wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. '(<font color="#00ffff">'..(scriptId)..'</font>)\n'; wait(.1);updateLogSize();
        loadTrident()
    elseif (status.code == "KEY_HWID_LOCKED") then
        logsLabel.Text = logsLabel.Text .. '<font color="#ff0000">Error</font> checking key!\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Reason: <font color="#00ffff">HWID Mismatch</font>\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Try resetting your HWID in the Discord server and then trying again\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. '(<font color="#ff00c8">/resethwid</font>)\n'; wait(.1);updateLogSize();
        checking = false
    elseif (status.code == "KEY_INCORRECT") then
        logsLabel.Text = logsLabel.Text .. '<font color="#ff0000">Error</font> checking key!\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Reason: <font color="#00ffff">Key is wrong or deleted</font>\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Double check your key in the Discord server and try again\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. '(<font color="#ff00c8">/license</font>)\n'; wait(.1);updateLogSize();
        checking = false
    else
        logsLabel.Text = logsLabel.Text .. '<font color="#ff0000">Error</font> checking key!\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Reason: <font color="#00ffff">'..status.message..'</font>\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. 'Code: <font color="#00ffff">'..tostring(status.code)..'</font>\n';wait(.1);updateLogSize();
        logsLabel.Text = logsLabel.Text .. '(<font color="#ff00c8">If you believe this is a bug, ask in the Discord</font>)\n'; wait(.1);updateLogSize();
        checking = false
    end
end)

