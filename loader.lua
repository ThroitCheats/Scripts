local httpService = game:GetService("HttpService")
local assetService = game:GetService("AssetService")
local placeId = game.PlaceId
local universeId = httpService:JSONDecode(game:HttpGet('https://apis.roblox.com/universes/v1/places/'..tostring(placeId)..'/universe')).universeId
local thumbnail = httpService:JSONDecode(game:HttpGet('https://thumbnails.roblox.com/v1/games/icons?universeIds='..tostring(universeId)..'&size=150x150&format=Png&isCircular=false')).data[1].imageUrl
local levelUpLoader = Instance.new("ScreenGui")
local function loadTrident()
    local fastflag = getfflag and getfflag('DebugRunParallelLuaOnMainThread');
    local transfer = [[getgenv().script_key = "]]..getgenv().script_key..'"\n'

    if run_on_actor and getactors and (getactors()[1] or game.Players.LocalPlayer.PlayerScripts:FindFirstChildWhichIsA("Actor")) then
        run_on_actor(getactors()[1] or game.Players.LocalPlayer.PlayerScripts:FindFirstChildWhichIsA("Actor"),transfer..[[
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/b0de7c4d81201b8837309655e4de6db7.lua"))()
            game.CoreGui.levelUpLoader:Destroy()
        ]])
    elseif tostring(string.lower(fastflag)) == "true" then 
        script_key = getgenv().script_key
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/b0de7c4d81201b8837309655e4de6db7.lua"))()
        levelUpLoader:Destroy()
    end
end

local idToGame = {
    [4620241901] = {name = "Trident v5", desc = "You may need to use Awp.gg in order to run this script, or a similarly strong executor. Report any bugs to the Discord!", load = loadTrident}
}

-- #region UI
local mainFrame = Instance.new("Frame")
local mainCorner = Instance.new("UICorner")
local mainLabel = Instance.new("TextLabel")
local gameImage = Instance.new("ImageLabel")
local descriptionLabel = Instance.new("TextLabel")
local runBG = Instance.new("TextButton")
local runCorner = Instance.new("UICorner")
local runButton = Instance.new("ImageButton")
local infoBG = Instance.new("TextButton")
local infoCorner = Instance.new("UICorner")
local infoButton = Instance.new("ImageButton")
local discordBG = Instance.new("TextButton")
local discordCorner = Instance.new("UICorner")
local discordButton = Instance.new("ImageButton")
local closeButton = Instance.new("ImageButton")
local keyFrame = Instance.new("Frame")
local keyCorner = Instance.new("UICorner")
local keyBox = Instance.new("TextBox")
local underline = Instance.new("TextLabel")
local underlineCorner = Instance.new("UICorner")
local keyRunBG = Instance.new("TextButton")
local keyRunCorner = Instance.new("UICorner")
local keyRunButton = Instance.new("ImageButton")
local keyCloseButton = Instance.new("ImageButton")
local infoFrame = Instance.new("Frame")
local infoCorner_2 = Instance.new("UICorner")
local infoTitleLabel = Instance.new("TextLabel")
local infoLabel = Instance.new("TextLabel")
local infoCloseButton = Instance.new("ImageButton")
levelUpLoader.Name = "levelUpLoader"
levelUpLoader.Parent = game.CoreGui
levelUpLoader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

mainFrame.Name = "mainFrame"
mainFrame.Parent = levelUpLoader
mainFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
mainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(.5, -150, .5, -222)
mainFrame.Size = UDim2.new(0, 300, 0, 444)

mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Name = "mainCorner"
mainCorner.Parent = mainFrame

mainLabel.Name = "mainLabel"
mainLabel.Parent = mainFrame
mainLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainLabel.BackgroundTransparency = 1.000
mainLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
mainLabel.BorderSizePixel = 0
mainLabel.Size = UDim2.new(1, 0, 0, 40)
mainLabel.Font = Enum.Font.Oswald
mainLabel.Text = "Level Up - Universal"
mainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
mainLabel.TextSize = 37.000

gameImage.Name = "gameImage"
gameImage.Parent = mainFrame
gameImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
gameImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
gameImage.BorderSizePixel = 0
gameImage.Position = UDim2.new(0.254166663, 0, 0.167274743, 0)
gameImage.Size = UDim2.new(0, 150, 0, 150)
gameImage.Image = "http://www.roblox.com/asset/?id=18246172257"
gameImage.BackgroundTransparency = 1

descriptionLabel.Name = "descriptionLabel"
descriptionLabel.Parent = mainFrame
descriptionLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
descriptionLabel.BackgroundTransparency = 1.000
descriptionLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
descriptionLabel.BorderSizePixel = 0
descriptionLabel.Position = UDim2.new(0.0900000036, 0, 0.588716269, 0)
descriptionLabel.Size = UDim2.new(0, 244, 0, 119)
descriptionLabel.Font = Enum.Font.Oswald
descriptionLabel.Text = "Level Up doesn't seem to support  this game, but maybe our universal script will work! Check the Discord for a full list"
descriptionLabel.TextColor3 = Color3.fromRGB(178, 178, 178)
descriptionLabel.TextSize = 29.000
descriptionLabel.TextWrapped = true
descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top

runBG.Name = "runBG"
runBG.Parent = mainFrame
runBG.BackgroundColor3 = Color3.fromRGB(23, 176, 0)
runBG.BorderColor3 = Color3.fromRGB(0, 0, 0)
runBG.BorderSizePixel = 0
runBG.Position = UDim2.new(0.5, -26, 0.889999986, 0)
runBG.Size = UDim2.new(0, 52, 0, 32)
runBG.AutoButtonColor = false
runBG.Font = Enum.Font.Oswald
runBG.Text = ""
runBG.TextColor3 = Color3.fromRGB(255, 255, 255)
runBG.TextSize = 35.000
runBG.TextYAlignment = Enum.TextYAlignment.Top

runCorner.CornerRadius = UDim.new(0, 16)
runCorner.Name = "runCorner"
runCorner.Parent = runBG

runButton.Name = "runButton"
runButton.Parent = runBG
runButton.BackgroundTransparency = 1.000
runButton.LayoutOrder = 4
runButton.Position = UDim2.new(1, -36, 0.5, -12)
runButton.Size = UDim2.new(0, 24, 0, 24)
runButton.ZIndex = 2
runButton.Image = "rbxassetid://3926307971"
runButton.ImageRectOffset = Vector2.new(44, 284)
runButton.ImageRectSize = Vector2.new(36, 36)

infoBG.Name = "infoBG"
infoBG.Parent = mainFrame
infoBG.BackgroundColor3 = Color3.fromRGB(255, 191, 0)
infoBG.BorderColor3 = Color3.fromRGB(0, 0, 0)
infoBG.BorderSizePixel = 0
infoBG.Position = UDim2.new(0.779999971, -26, 0.889999986, 0)
infoBG.Size = UDim2.new(0, 52, 0, 32)
infoBG.AutoButtonColor = false
infoBG.Font = Enum.Font.Oswald
infoBG.Text = ""
infoBG.TextColor3 = Color3.fromRGB(255, 255, 255)
infoBG.TextSize = 35.000
infoBG.TextYAlignment = Enum.TextYAlignment.Top

infoCorner.CornerRadius = UDim.new(0, 16)
infoCorner.Name = "infoCorner"
infoCorner.Parent = infoBG

infoButton.Name = "infoButton"
infoButton.Parent = infoBG
infoButton.BackgroundTransparency = 1.000
infoButton.LayoutOrder = 1
infoButton.Position = UDim2.new(0.25, 0, 0.5, -13)
infoButton.Size = UDim2.new(0, 25, 0, 25)
infoButton.ZIndex = 2
infoButton.Image = "rbxassetid://3926305904"
infoButton.ImageRectOffset = Vector2.new(524, 444)
infoButton.ImageRectSize = Vector2.new(36, 36)

discordBG.Name = "discordBG"
discordBG.Parent = mainFrame
discordBG.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBG.BorderColor3 = Color3.fromRGB(0, 0, 0)
discordBG.BorderSizePixel = 0
discordBG.Position = UDim2.new(0.219999999, -26, 0.889999986, 0)
discordBG.Size = UDim2.new(0, 52, 0, 32)
discordBG.AutoButtonColor = false
discordBG.Font = Enum.Font.Oswald
discordBG.Text = ""
discordBG.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBG.TextSize = 35.000
discordBG.TextYAlignment = Enum.TextYAlignment.Top

discordCorner.CornerRadius = UDim.new(0, 16)
discordCorner.Name = "discordCorner"
discordCorner.Parent = discordBG

discordButton.Name = "discordButton"
discordButton.Parent = discordBG
discordButton.BackgroundTransparency = 1.000
discordButton.Position = UDim2.new(0.25, 0, 0.5, -13)
discordButton.Size = UDim2.new(0, 25, 0, 25)
discordButton.ZIndex = 2
discordButton.Image = "rbxassetid://3926305904"
discordButton.ImageRectOffset = Vector2.new(164, 404)
discordButton.ImageRectSize = Vector2.new(36, 36)

closeButton.Name = "closeButton"
closeButton.Parent = mainFrame
closeButton.BackgroundTransparency = 1.000
closeButton.LayoutOrder = 4
closeButton.Position = UDim2.new(0.903333306, 0, 0.0157657657, 0)
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.ZIndex = 2
closeButton.Image = "rbxassetid://3926305904"
closeButton.ImageColor3 = Color3.fromRGB(255, 90, 90)
closeButton.ImageRectOffset = Vector2.new(124, 124)
closeButton.ImageRectSize = Vector2.new(36, 36)

keyFrame.Name = "keyFrame"
keyFrame.Parent = levelUpLoader
keyFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
keyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
keyFrame.BorderSizePixel = 0
keyFrame.Position = UDim2.new(0.5, -243,0.5, 242)
keyFrame.Size = UDim2.new(0, 487, 0, 85)
keyFrame.Visible = false 

keyCorner.CornerRadius = UDim.new(0, 12)
keyCorner.Name = "keyCorner"
keyCorner.Parent = keyFrame

keyBox.Name = "keyBox"
keyBox.Parent = keyFrame
keyBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
keyBox.BackgroundTransparency = 1.000
keyBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
keyBox.BorderSizePixel = 0
keyBox.Position = UDim2.new(0.034907598, 0, 0.200000003, 0)
keyBox.Size = UDim2.new(0, 399, 0, 50)
keyBox.Font = Enum.Font.Oswald
keyBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
keyBox.PlaceholderText = "Paste your key here"
keyBox.Text = ""
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.TextSize = 26.000
keyBox.Text = script_key or ""

underline.Name = "underline"
underline.Parent = keyBox
underline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
underline.BorderColor3 = Color3.fromRGB(0, 0, 0)
underline.BorderSizePixel = 0
underline.Position = UDim2.new(0, 0, 1, 0)
underline.Size = UDim2.new(1, 0, 0, 1)
underline.Font = Enum.Font.Oswald
underline.Text = ""
underline.TextColor3 = Color3.fromRGB(0, 0, 0)
underline.TextSize = 14.000

underlineCorner.CornerRadius = UDim.new(0, 32)
underlineCorner.Name = "underlineCorner"
underlineCorner.Parent = underline

keyRunBG.Name = "keyRunBG"
keyRunBG.Parent = keyBox
keyRunBG.BackgroundColor3 = Color3.fromRGB(23, 176, 0)
keyRunBG.BorderColor3 = Color3.fromRGB(0, 0, 0)
keyRunBG.BorderSizePixel = 0
keyRunBG.Position = UDim2.new(1.09899747, -26, 0.370000005, 0)
keyRunBG.Size = UDim2.new(0, 52, 0, 32)
keyRunBG.AutoButtonColor = false
keyRunBG.Font = Enum.Font.Oswald
keyRunBG.Text = ""
keyRunBG.TextColor3 = Color3.fromRGB(255, 255, 255)
keyRunBG.TextSize = 35.000
keyRunBG.TextYAlignment = Enum.TextYAlignment.Top

keyRunCorner.CornerRadius = UDim.new(0, 16)
keyRunCorner.Name = "keyRunCorner"
keyRunCorner.Parent = keyRunBG

keyRunButton.Name = "keyRunButton"
keyRunButton.Parent = keyRunBG
keyRunButton.BackgroundTransparency = 1.000
keyRunButton.LayoutOrder = 4
keyRunButton.Position = UDim2.new(1, -36, 0.5, -12)
keyRunButton.Size = UDim2.new(0, 24, 0, 24)
keyRunButton.ZIndex = 2
keyRunButton.Image = "rbxassetid://3926307971"
keyRunButton.ImageRectOffset = Vector2.new(44, 284)
keyRunButton.ImageRectSize = Vector2.new(36, 36)

keyCloseButton.Name = "keyCloseButton"
keyCloseButton.Parent = keyFrame
keyCloseButton.BackgroundTransparency = 1.000
keyCloseButton.LayoutOrder = 4
keyCloseButton.Position = UDim2.new(1, -30, 0, 5)
keyCloseButton.Size = UDim2.new(0, 25, 0, 25)
keyCloseButton.ZIndex = 2
keyCloseButton.Image = "rbxassetid://3926305904"
keyCloseButton.ImageColor3 = Color3.fromRGB(255, 90, 90)
keyCloseButton.ImageRectOffset = Vector2.new(124, 124)
keyCloseButton.ImageRectSize = Vector2.new(36, 36)

infoFrame.Name = "infoFrame"
infoFrame.Parent = levelUpLoader
infoFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
infoFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
infoFrame.BorderSizePixel = 0
infoFrame.Position = UDim2.new(0.5, -434, 0.5, -222)
infoFrame.Size = UDim2.new(0, 264, 0, 353)
infoFrame.Visible = false

infoCorner_2.CornerRadius = UDim.new(0, 12)
infoCorner_2.Name = "infoCorner"
infoCorner_2.Parent = infoFrame

infoTitleLabel.Name = "infoTitleLabel"
infoTitleLabel.Parent = infoFrame
infoTitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
infoTitleLabel.BackgroundTransparency = 1.000
infoTitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
infoTitleLabel.BorderSizePixel = 0
infoTitleLabel.Size = UDim2.new(1, 0, 0, 40)
infoTitleLabel.Font = Enum.Font.Oswald
infoTitleLabel.Text = "Information"
infoTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoTitleLabel.TextSize = 37.000

infoLabel.Name = "infoLabel"
infoLabel.Parent = infoFrame
infoLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.BackgroundTransparency = 1.000
infoLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
infoLabel.BorderSizePixel = 0
infoLabel.Position = UDim2.new(0.0369697325, 0, 0.126959875, 0)
infoLabel.Size = UDim2.new(0, 244, 0, 295)
infoLabel.Font = Enum.Font.Oswald
infoLabel.Text = "Today's news: This update took way too long and I'm tired."
infoLabel.TextColor3 = Color3.fromRGB(178, 178, 178)
infoLabel.TextSize = 29.000
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top

infoCloseButton.Name = "infoCloseButton"
infoCloseButton.Parent = infoFrame
infoCloseButton.BackgroundTransparency = 1.000
infoCloseButton.LayoutOrder = 4
infoCloseButton.Position = UDim2.new(1, -30, 0, 5)
infoCloseButton.Size = UDim2.new(0, 25, 0, 25)
infoCloseButton.ZIndex = 2
infoCloseButton.Image = "rbxassetid://3926305904"
infoCloseButton.ImageColor3 = Color3.fromRGB(255, 90, 90)
infoCloseButton.ImageRectOffset = Vector2.new(124, 124)
infoCloseButton.ImageRectSize = Vector2.new(36, 36)
mainFrame.Draggable = true 
keyFrame.Draggable = true 
infoFrame.Draggable = true 
mainFrame.Active = true 
keyFrame.Active = true 
infoFrame.Active = true 

local autoGame = idToGame[universeId]
if autoGame then 
    mainLabel.Text = "Level Up - "..autoGame.name 
    descriptionLabel.Text = autoGame.desc
end
local s,_ pcall(function()local editableImage = assetService:CreateEditableImage()end)
if s then 
local function getPNGLibrary()
    local libraryLink = "https://raw.githubusercontent.com/MaximumADHD/Roblox-PNG-Library/refs/heads/master/"
    local chunkLink = libraryLink.."Chunks/"
    local moduleLink = libraryLink.."Modules/"
    local initScript = game:HttpGet(libraryLink.."init.lua")
    local chuncks = {"IDAT", "IEND", "IHDR", "PLTE", "bKGD","cHRM","gAMA","sRGB","tEXt","tIME","tRNS"}
    local modules = {"BinaryReader","Deflate","Unfilter"}
    for i,v in pairs(chuncks) do writefile('pngLibrary\\Chuncks\\'..v..'.lua', game:HttpGet(chunkLink..v..'.lua')) end
    for i,v in pairs(modules) do writefile('pngLibrary\\Modules\\'..v..'.lua', game:HttpGet(moduleLink..v..'.lua')) end
    local initScript = game:HttpGet(libraryLink.."init.lua")
    --Replacing library requires
    local replaces = {
        ["local chunks = script.Chunks"] = "",
        ["local modules = script.Modules"] = "",
        ["require%(modules.Deflate%)"] = "loadstring(readfile('pngLibrary\\\\Modules\\\\Deflate.lua'))()",
        ["require%(modules.Unfilter%)"] = "loadstring(readfile('pngLibrary\\\\Modules\\\\Unfilter.lua'))()",
        ["require%(modules.BinaryReader%)"] = "loadstring(readfile('pngLibrary\\\\Modules\\\\BinaryReader.lua'))()",
        ["local handler = "]="local handler = loadstring(readfile('".."pngLibrary\\\\Chuncks\\\\".."'..chunkType..'.lua'))() --",
        ["handler = require%(handler%)"]=''
    }
    for i,v in pairs(replaces) do 
    if not string.find(initScript,i) then warn(i) end
        initScript = (string.gsub(initScript,i,v))
    end
    writefile("pngLibrary\\main.lua",initScript)
end
if not isfolder('pngLibrary') then getPNGLibrary() end 
task.wait()
local pngLib = loadstring(readfile("pngLibrary\\main.lua"))() 
local response = game:HttpGetAsync(thumbnail, true) -- Fetch the binary data
local pngFile = pngLib.new(response)
local options = { Size = Vector2.new(pngFile.Width,pngFile.Height) }
local editableImage = assetService:CreateEditableImage(options)
local pixelsBuffer = editableImage:ReadPixelsBuffer(Vector2.zero, editableImage.Size)
for y = 1, editableImage.Size.Y do
    for x = 1, editableImage.Size.X do
        local pixelIndex = ((y - 1) * editableImage.Size.X + (x - 1)) * 4
        local color, alpha = pngFile:GetPixel(x, y)
        buffer.writeu8(pixelsBuffer, pixelIndex, color.R * 255)
        buffer.writeu8(pixelsBuffer, pixelIndex + 1, color.G * 255)
        buffer.writeu8(pixelsBuffer, pixelIndex + 2, color.B * 255)
        buffer.writeu8(pixelsBuffer, pixelIndex + 3, alpha)
    end
end
editableImage:WritePixelsBuffer(Vector2.zero, editableImage.Size, pixelsBuffer)
gameImage.ImageContent = Content.fromObject(editableImage)
end
--#endregion 
--#region UI functions 
closeButton.MouseButton1Click:Connect(function()levelUpLoader:Destroy() end) 
infoButton.MouseButton1Click:Connect(function() infoFrame.Visible = true end)
infoBG.MouseButton1Click:Connect(function() infoFrame.Visible = true end)
infoCloseButton.MouseButton1Click:Connect(function() infoFrame.Visible = false end)
discordButton.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/nxTJs7RV5d") end)
discordBG.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/nxTJs7RV5d") end)
runButton.MouseButton1Click:Connect(function() keyFrame.Visible = true end)
runBG.MouseButton1Click:Connect(function() keyFrame.Visible = true end)
keyCloseButton.MouseButton1Click:Connect(function() keyFrame.Visible = false end) 
local canRun = true 
local function runScript() 
    if not canRun then return end 
    keyRunBG.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    canRun = false 
    if autoGame then 
        getgenv().script_key = keyBox.Text
        autoGame.load()
    else 
        --Universal 
    end
end
keyRunBG.MouseButton1Click:Connect(runScript)
keyRunButton.MouseButton1Click:Connect(runScript)
--#endregion
