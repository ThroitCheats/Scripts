--[[ Variables ]]--

local httpservice = game:GetService("HttpService")
local textservice = game:GetService("TextService")
local tweenservice = game:GetService("TweenService")
local guiservice = game:GetService("GuiService")
local coregui = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")

local library = {
    settings = {
        created = false,
        open = false,
        dragging = false
    },
    theme = {
		gradient1 = Color3.fromRGB(46, 46, 46), 
		gradient2 = Color3.fromRGB(61, 61, 61),
		gamecolor = Color3.fromRGB(61, 61, 61)
	},
    tabs = {},
    flags = {},
    items = {}
}

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

--[[ Functions ]]--

local function create(class, properties, children)
	local inst = Instance.new(class)
	for i, v in next, properties do
        if i ~= "Parent" then
	       	inst[i] = v
	    end
	end
	if children then
		for i, v in next, children do
			v.Parent = inst
		end
	end
	inst.Parent = properties.Parent
	return inst
end

local function secureparent(gui)
    gui.Parent = getgenv().game.CoreGui
end

local function tween(instance, duration, properties, style, ...)
	local t = tweenservice:Create(instance, TweenInfo.new(duration, style or Enum.EasingStyle.Sine, ...), properties)
	t:Play()
	return t
end

local function makedraggable(frame)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and library.settings.dragging == false then
			library.settings.dragging = true
			local offset = Vector2.new(frame.AbsoluteSize.X * frame.AnchorPoint.X, frame.AbsoluteSize.Y * frame.AnchorPoint.Y)
			local pos = Vector2.new(mouse.X - (frame.AbsolutePosition.X + offset.X), mouse.Y - (frame.AbsolutePosition.Y + offset.Y))
            local mouseconn = mouse.Move:Connect(function()
				if library.settings.open == false then
					library.settings.open = true
				end
				tween(frame, 0.15, { Position = UDim2.new(0, mouse.X - pos.X, 0, mouse.Y - pos.Y) })
			end)
			local inputconn; inputconn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
                    mouseconn:Disconnect()
                    inputconn:Disconnect()
					library.settings.dragging = false
				end
			end)
		end
	end)
end

local function round(val, nearest)
	local mul = 1 / nearest
    return math.round(val * mul) / mul
end

local function mergetables(base, edit)
    if typeof(edit) == "table" then
        for i, v in next, edit do
            if typeof(base[i]) == typeof(v) then
				base[i] = v
            end
        end
    end
    return base
end

local function autocanvasresize(layout, frame, func)
	local function resize()
		frame.CanvasSize = func(layout, frame)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
	resize()
	return resize
end

local function ismouseoverobject(obj)
	local posx = obj.AbsolutePosition.X
	local posy = obj.AbsolutePosition.Y
	return mouse.X >= posx and mouse.Y >= posy and mouse.X <= posx + obj.AbsoluteSize.X and mouse.Y <= posy + obj.AbsoluteSize.Y
end

local function organisenotifs()
	local offset, notifs = -30, library.dir.notifications:GetChildren()
	for i = #notifs, 1, -1 do
		local v = notifs[i]
		tween(v, 0.35, { Position = UDim2.new(1, -330, 1, offset) })
		offset = offset - (v.AbsoluteSize.Y + 10)
	end
end

local function deepclone(tab)
	local clone = {}
	for i, v in next, tab do
		clone[i] = type(v) == "table" and deepclone(v) or v
	end
	return clone
end

local function hextocolour(hex)
	local r, g, b = string.match(hex, "^#?(%w%w)(%w%w)(%w%w)$")
	return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end

local function colourtohex(colour)
	return string.format("#%02X%02X%02X", colour.R * 0xFF, colour.G * 0xFF, colour.B * 0xFF)
end

--[[ Setup ]]--
local rainbowSpeed = 15
game:GetService("RunService").Heartbeat:Connect(function()
    local hue = tick() % rainbowSpeed / rainbowSpeed
    for i, v in next, library.items do
        local flag = library.flags[v.flag]
        if v.class == "picker" and typeof(flag) == "table" and flag.rainbow then
			local _, sat, val = flag.colour:ToHSV()
            task.spawn(v.set, v, Color3.fromHSV(hue, sat, val))
        end
    end
end)

--[[ Card ]]--

local card = {}
card.__index = card

function card.new(title, right)
    return setmetatable({
        title = title or "Untitled",
		right = right or false,
		items = {}
    }, card)
end

function card:addlabel(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided"
    }, options)

	settings.card = self
    settings.class = "label"
    settings.frame = create("TextLabel", { 
		Font = Enum.Font.GothamMedium, 
		FontSize = Enum.FontSize.Size12, 
		Text = settings.title, 
		TextColor3 = Color3.new(1, 1, 1), 
		TextSize = 12, 
		TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
		TextStrokeTransparency = 0.5, 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 20), 
		Name = settings.title
	})

	local labelvec = Vector2.new(settings.frame.AbsoluteSize.X, math.huge)
    function settings:set(txt)
		self.frame.Text = txt
		self.frame.Size = UDim2.new(1, 0, 0, textservice:GetTextSize(txt, 12, Enum.Font.GothamMedium, labelvec).Y + 8)
    end

	table.insert(self.items, settings)
    library.items[settings.flag] = settings
    return settings
end

function card:addstatuslabel(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
		content = "No Status Provided",
		colour = Color3.new(1, 1, 1)
    }, options)

	settings.card = self
    settings.class = "statuslabel"
    settings.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 20), 
		Name = settings.title
	}, {
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, -4, 1, 0), 
			Name = "label"
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.content, 
			TextColor3 = settings.colour, 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Right, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, -4, 1, 0), 
			Name = "status"
		})
	})

    function settings:set(txt, colour)
		if self.frame:FindFirstChild('status') then 
			self.frame.status.Text = txt
			if colour then
				self.frame.status.TextColor3 = colour
			end
		end
    end

	table.insert(self.items, settings)
    library.items[settings.flag] = settings
    return settings
end

function card:addclipboard(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
		callback = function()
			return "No Content Provided"
		end
    }, options)

	settings.card = self
    settings.class = "clipboard"
    settings.frame = create("TextButton", { 
		Font = Enum.Font.Gotham, 
		FontSize = Enum.FontSize.Size12, 
		Text = "", 
		TextColor3 = Color3.new(1, 1, 1), 
		TextSize = 12, 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 24), 
		Name = settings.title
	}, {
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0, 2, 0.5, 0), 
			Size = UDim2.new(1, -29, 1, 0), 
			Name = "label"
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
			Position = UDim2.new(1, -1, 0.5, 0), 
			Size = UDim2.new(0, 22, 0, 22), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0431373, 0.0431373, 0.0431373), 
				Name = "stroke"
			}),
			create("ImageLabel", { 
				Image = "rbxassetid://10156036701", 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(0, 18, 0, 18), 
				Name = "icon"
			})
		})
	})

	settings.frame.MouseButton1Click:Connect(function()
		setclipboard(settings.callback())
	end)

	table.insert(self.items, settings)
    library.items[settings.flag] = settings
    return settings
end

function card:addbutton(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
        callback = function() end
    }, options)

	settings.card = self
    settings.class = "button"
    settings.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 24), 
		Name = settings.title
	}, {
		create("TextButton", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = "", 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			AutoButtonColor = false, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, -2, 1, -2), 
			Name = "click"
		}, {
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
				Name = "stroke"
			}),
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("TextLabel", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				Text = settings.title, 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
				TextStrokeTransparency = 0.5, 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, 0, 1, 0), 
				Name = "label"
			}),
			create("UIGradient", { 
				Color = ColorSequence.new({ 
					ColorSequenceKeypoint.new(0, library.theme.gradient1), 
					ColorSequenceKeypoint.new(1, library.theme.gradient2)
				}), 
				Rotation = 35, 
				Name = "gradient"
			})
		})
	})
    
	settings.frame.click.MouseButton1Click:Connect(settings.callback)
	settings.frame.click.MouseButton1Click:Connect(function()
		settings.frame.click.label.TextSize = 0
		tween(settings.frame.click.label, 0.15, { TextSize = 12 })
	end)

	table.insert(self.items, settings)
    library.items[settings.flag] = settings
    return settings
end

function card:addcheckbox(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
        callback = function() end,
        ignore = false,
        default = false
    }, options)

	settings.card = self
    settings.class = "checkbox"
    settings.frame = create("TextButton", { 
		Font = Enum.Font.Gotham, 
		FontSize = Enum.FontSize.Size12, 
		Text = "", 
		TextColor3 = Color3.new(1, 1, 1), 
		TextSize = 12, 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 24), 
		Name = settings.title
	}, {
		create("Frame", { 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
			Position = UDim2.new(1, -1, 0.5, 0), 
			Size = UDim2.new(0, 22, 0, 22), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
				Name = "stroke"
			}),
			create("ImageLabel", { 
				Image = "rbxassetid://10138918728", 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				ZIndex = 2, 
				Name = "check"
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, 0, 1, 0), 
				Name = "colour"
			}, {
				create("UIGradient", { 
					Color = ColorSequence.new({ 
						ColorSequenceKeypoint.new(0, library.theme.gradient1), 
						ColorSequenceKeypoint.new(1, library.theme.gradient2)
					}), 
					Rotation = 35, 
					Name = "gradient"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
					Name = "stroke"
				}),
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				})
			})
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0, 2, 0.5, 0), 
			Size = UDim2.new(1, -29, 1, 0), 
			Name = "label"
		})
	})

    function settings:set(bool)
        library.flags[self.flag] = bool
		tween(self.frame.indicator.colour, 0.15, { BackgroundTransparency = bool and 0 or 1 })
		tween(self.frame.indicator.check, 0.15, { Size = bool and UDim2.new(0, 18, 0, 18) or UDim2.new() })
        settings.callback(bool)
    end

	settings.frame.MouseButton1Click:Connect(function()
		settings:set(not library.flags[settings.flag])
	end)

	table.insert(self.items, settings)
    library.flags[settings.flag] = false
    library.items[settings.flag] = settings
	if settings.default then
        task.spawn(settings.set, settings, true)
    end
    return settings
end

function card:addtextfield(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
        callback = function() end,
        ignore = false,
        default = ""
    }, options)

	settings.card = self
    settings.class = "textfield"
    settings.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 42), 
		Name = settings.title
	}, {
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Size = UDim2.new(1, -4, 0, 20), 
			Name = "label"
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 1), 
			BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
			ClipsDescendants = true, 
			Position = UDim2.new(0.5, 0, 1, -1), 
			Size = UDim2.new(1, -2, 1, -22), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 2), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
				Name = "stroke"
			}),
			create("TextBox", { 
				CursorPosition = -1, 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				PlaceholderText = "Enter Value...", 
				Text = "", 
				TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
				TextSize = 12, 
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left, 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(1, -8, 0.5, 0), 
				Size = UDim2.new(1, -16, 1, 0), 
				Name = "input"
			})
		})
	})

	function settings:set(txt)
        library.flags[self.flag] = txt
		self.frame.indicator.input.Text = txt
        self.callback(txt)
    end

	local boxvec = Vector2.new(settings.frame.indicator.input.AbsoluteSize.X, math.huge)
	settings.frame.indicator.input:GetPropertyChangedSignal("Text"):Connect(function()
		settings.frame.Size = UDim2.new(1, -2, 0, textservice:GetTextSize(settings.frame.indicator.input.Text, 12, Enum.Font.Gotham, boxvec).Y + 30)
	end)

	settings.frame.indicator.input.FocusLost:Connect(function(enterpressed)
		if enterpressed then
			settings:set(settings.frame.indicator.input.Text)
		else
			settings.frame.indicator.input.Text = library.flags[settings.flag]
		end
	end)

	table.insert(self.items, settings)
    library.flags[settings.flag] = ""
    library.items[settings.flag] = settings
    if settings.default ~= "" then
        task.spawn(settings.set, settings, settings.default)
    end
    return settings
end

function card:addslider(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
        callback = function() end,
        ignore = false,
        min = 0,
        max = 100,
        float = 1,
        default = 0,
        prefix = "",
        suffix = ""
    }, options)

	settings.card = self
    settings.class = "slider"
    settings.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 31), 
		Name = settings.title
	}, {
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Size = UDim2.new(1, -4, 0, 20), 
			Name = "label"
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = string.format("%s%s%s", settings.prefix, settings.min, settings.suffix), 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Right, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Size = UDim2.new(1, -4, 0, 20), 
			Name = "value"
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 1), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			ClipsDescendants = true, 
			Position = UDim2.new(0.5, 0, 1, -1), 
			Size = UDim2.new(1, -2, 0, 9), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 2), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
				Name = "stroke"
			}),
			create("UIGradient", { 
				Color = ColorSequence.new({ 
					ColorSequenceKeypoint.new(0, library.theme.gradient1), 
					ColorSequenceKeypoint.new(1, library.theme.gradient2)
				}), 
				Name = "gradient"
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
				BorderSizePixel = 0, 
				Position = UDim2.new(1, 0, 0.5, 0), 
				Size = UDim2.new(1, 0, 1, 0), 
				Name = "cover"
			})
		})
	})

    function settings:set(value)
        local val = math.clamp(round(value, self.float), self.min, self.max)
		tween(self.frame.indicator.cover, 0.25, { Size = UDim2.new(1 - math.clamp((value - self.min) / (self.max - self.min), 0, 1), 0, 1, 0) })
        if val ~= library.flags[self.flag] then
            library.flags[self.flag] = val
            self.frame.value.Text = string.format("%s%s%s", self.prefix, tostring(val), self.suffix)
            self.callback(val)
        end
    end

    settings.frame.indicator.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            library.settings.dragging = true
			local mouseconn = mouse.Move:Connect(function()
				settings:set(settings.min + ((settings.max - settings.min) * ((mouse.X - settings.frame.indicator.AbsolutePosition.X) / settings.frame.indicator.AbsoluteSize.X)))
			end)
			local inputconn; inputconn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
                    mouseconn:Disconnect()
                    inputconn:Disconnect()
					library.settings.dragging = false
				end
			end)
        end
    end)

	table.insert(self.items, settings)
    library.flags[settings.flag] = settings.min
    library.items[settings.flag] = settings
    if settings.default > settings.min then
        task.spawn(settings.set, settings, settings.default)
    end
    return settings
end


function card:addpickertoggle(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
        callback = function() end,
        ignore = false,
        defaultColor = Color3.new(1, 1, 1),
        defaultToggle = false,
        rainbow = false
    }, options)

	settings.card = self
    settings.class = "picker"
    settings.frame = create("TextButton", { 
		Font = Enum.Font.Gotham, 
		FontSize = Enum.FontSize.Size12, 
		Text = "", 
		TextColor3 = Color3.new(1, 1, 1), 
		TextSize = 12, 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 20), 
		Name = settings.title
	}, {
		create("TextButton", { 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 0, 0), 
			Position = UDim2.new(1, -33, 0.5, 0), 
			Size = UDim2.new(0, 30, 0, 18), 
			Name = "colorIndicator",
			Text = "", 
			AutoButtonColor = false
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
				Name = "stroke"
			})
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
			Position = UDim2.new(1, -1, 0.5, 0), 
			Size = UDim2.new(0, 22, 0, 22), 
			Name = "toggleIndicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
				Name = "stroke"
			}),
			create("ImageLabel", { 
				Image = "rbxassetid://10138918728", 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				ZIndex = 2, 
				Name = "check"
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, 0, 1, 0), 
				Name = "colour"
			}, {
				create("UIGradient", { 
					Color = ColorSequence.new({ 
						ColorSequenceKeypoint.new(0, library.theme.gradient1), 
						ColorSequenceKeypoint.new(1, library.theme.gradient2)
					}), 
					Rotation = 35, 
					Name = "gradient"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
					Name = "stroke"
				}),
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				})
			})
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0, 2, 0.5, 0), 
			Size = UDim2.new(1, -41, 1, 0), 
			Name = "label"
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882), 
			Position = UDim2.new(0.5, 0, 1, 4), 
			Size = UDim2.new(1, 0, 0, 140), 
			Name = "drop",
			Visible = false,
			ZIndex = 2
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
				Name = "stroke"
			}),
			create("Frame", { 
				BackgroundColor3 = Color3.new(1, 0, 0), 
				Position = UDim2.new(0, 6, 0, 6), 
				Size = UDim2.new(0, 116, 0, 78), 
				Name = "base", 
				ZIndex = 2
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 0.5), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					Position = UDim2.new(0.5, 0, 0.5, 0), 
					Size = UDim2.new(1, 0, 1, 0), 
					Name = "sat", 
					ZIndex = 2
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
						Name = "stroke"
					}),
					create("UIGradient", { 
						Transparency = NumberSequence.new({ 
							NumberSequenceKeypoint.new(0, 0), 
							NumberSequenceKeypoint.new(1, 1)
						}), 
						Name = "gradient"
					}),
					create("Frame", { 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(0, 0, 0), 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Size = UDim2.new(1, 0, 1, 0), 
						Name = "val", 
						ZIndex = 2
					}, {
						create("UICorner", { 
							CornerRadius = UDim.new(0, 3), 
							Name = "corner"
						}),
						create("UIStroke", { 
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
							Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
							Name = "stroke"
						}),
						create("UIGradient", { 
							Rotation = 270, 
							Transparency = NumberSequence.new({ 
								NumberSequenceKeypoint.new(0, 0), 
								NumberSequenceKeypoint.new(1, 1)
							}), 
							Name = "gradient"
						})
					})
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 0.5), 
					BackgroundColor3 = Color3.new(1, 0, 0), 
					Position = UDim2.new(1, 0, 0, 0), 
					Size = UDim2.new(0, 12, 0, 12), 
					ZIndex = 3, 
					Name = "indicator"
				}, {
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
						Name = "stroke"
					}),
					create("UICorner", { 
						CornerRadius = UDim.new(1, 0), 
						Name = "corner"
					})
				})
			}),
			create("TextBox", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				PlaceholderText = "Red", 
				Text = "255", 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				AnchorPoint = Vector2.new(1, 0), 
				BackgroundColor3 = Color3.new(0.101961, 0.101961, 0.101961), 
				Position = UDim2.new(1, -6, 0, 6), 
				Size = UDim2.new(0, 48, 0, 22), 
				Name = "red", 
				ZIndex = 2
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 2), 
					Name = "corner"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				})
			}),
			create("TextBox", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				PlaceholderText = "Green", 
				Text = "255", 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				AnchorPoint = Vector2.new(1, 0), 
				BackgroundColor3 = Color3.new(0.101961, 0.101961, 0.101961), 
				Position = UDim2.new(1, -6, 0, 34), 
				Size = UDim2.new(0, 48, 0, 22), 
				Name = "green", 
				ZIndex = 2
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 2), 
					Name = "corner"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				})
			}),
			create("TextBox", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				PlaceholderText = "Blue", 
				Text = "255", 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				AnchorPoint = Vector2.new(1, 0), 
				BackgroundColor3 = Color3.new(0.101961, 0.101961, 0.101961), 
				Position = UDim2.new(1, -6, 0, 62), 
				Size = UDim2.new(0, 48, 0, 22), 
				Name = "blue", 
				ZIndex = 2
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 2), 
					Name = "corner"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				})
			}),
			create("TextButton", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				Text = "", 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				AnchorPoint = Vector2.new(0.5, 1), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 1, -5), 
				Size = UDim2.new(1, -10, 0, 24), 
				Name = "rainbow", 
				ZIndex = 2
			}, {
				create("Frame", { 
					AnchorPoint = Vector2.new(1, 0.5), 
					BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
					Position = UDim2.new(1, -1, 0.5, 0), 
					Size = UDim2.new(0, 22, 0, 22), 
					Name = "indicator", 
					ZIndex = 2
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
						Name = "stroke"
					}),
					create("ImageLabel", { 
						Image = "rbxassetid://10138918728", 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						ZIndex = 3, 
						Name = "check"
					}),
					create("Frame", { 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Size = UDim2.new(1, 0, 1, 0), 
						Name = "colour", 
						ZIndex = 2
					}, {
						create("UIGradient", { 
							Color = ColorSequence.new({ 
								ColorSequenceKeypoint.new(0, library.theme.gradient1), 
								ColorSequenceKeypoint.new(1, library.theme.gradient2)
							}), 
							Rotation = 35, 
							Name = "gradient"
						}),
						create("UIStroke", { 
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
							Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
							Name = "stroke"
						}),
						create("UICorner", { 
							CornerRadius = UDim.new(0, 3), 
							Name = "corner"
						})
					})
				}),
				create("TextLabel", { 
					Font = Enum.Font.GothamMedium, 
					FontSize = Enum.FontSize.Size12, 
					Text = "Rainbow", 
					TextColor3 = Color3.new(1, 1, 1), 
					TextSize = 12, 
					TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
					TextStrokeTransparency = 0.5, 
					TextXAlignment = Enum.TextXAlignment.Left, 
					AnchorPoint = Vector2.new(0, 0.5), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					BackgroundTransparency = 1, 
					Position = UDim2.new(0, 2, 0.5, 0), 
					Size = UDim2.new(1, -29, 1, 0), 
					Name = "label", 
					ZIndex = 2
				})
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(0.5, 0), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				Position = UDim2.new(0.5, 0, 0, 90), 
				Size = UDim2.new(1, -12, 0, 16), 
				Name = "hue", 
				ZIndex = 2
			}, {
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				}),
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("UIGradient", { 
					Color = ColorSequence.new({ 
						ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)), 
						ColorSequenceKeypoint.new(0.16666659712791443, Color3.new(1, 1, 0)), 
						ColorSequenceKeypoint.new(0.33333298563957214, Color3.new(0, 1, 0)), 
						ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)), 
						ColorSequenceKeypoint.new(0.6660000085830688, Color3.new(0, 0, 1)), 
						ColorSequenceKeypoint.new(0.8333330154418945, Color3.new(1, 0, 1)), 
						ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0.01568627543747425))
					}), 
					Name = "gradient"
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 0.5), 
					BackgroundColor3 = Color3.new(1, 0, 0), 
					Position = UDim2.new(0, 0, 0.5, 0), 
					Size = UDim2.new(0, 8, 1, 0), 
					Name = "indicator", 
					ZIndex = 2
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 2), 
						Name = "corner"
					}),
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
						Name = "stroke"
					})
				})
			})
		})
	})

    function settings:set(colour)
		local h, s, v = colour:ToHSV()
		library.flags[self.flag].colour = colour
		self.frame.colorIndicator.BackgroundColor3 = colour
		self.frame.drop.base.indicator.BackgroundColor3 = colour
		self.frame.drop.base.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		self.frame.drop.hue.indicator.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		self.frame.drop.red.Text = math.round(colour.R * 255)
		self.frame.drop.green.Text = math.round(colour.G * 255)
		self.frame.drop.blue.Text = math.round(colour.B * 255)
		tween(self.frame.drop.base.indicator, 0.25, { Position = UDim2.new(s, 0, 1 - v, 0) })
		if library.flags[self.flag].rainbow then
			self.frame.drop.hue.indicator.Position = UDim2.new(h, 0, 0.5, 0)
		else
			tween(self.frame.drop.hue.indicator, 0.25, { Position = UDim2.new(h, 0, 0.5, 0) })
		end
		self.callback(colour)
    end

    function settings:toggle(bool)
        library.flags[self.flag].rainbow = bool
		tween(self.frame.drop.rainbow.indicator.colour, 0.15, { BackgroundTransparency = bool and 0 or 1 })
		tween(self.frame.drop.rainbow.indicator.check, 0.15, { Size = bool and UDim2.new(0, 18, 0, 18) or UDim2.new() })
    end

    local function openColor() 
        local opendrop = self.tab.opendrop
		if opendrop and ismouseoverobject(opendrop.frame.drop) then
			return
		end
		local vis = not settings.frame.drop.Visible
		if opendrop then
			opendrop.frame.drop.Visible = false
			self.tab.opendrop = nil
		end
		if vis then
			settings.frame.drop.Visible = true
			self.tab.opendrop = settings
		end
		self.tab:resize()
    end

    settings.frame.colorIndicator.MouseButton1Click:Connect(openColor)

    settings.frame.drop.rainbow.MouseButton1Click:Connect(function()
        settings:toggle(not library.flags[settings.flag].rainbow)
    end)

    settings.frame.drop.hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
			library.settings.dragging = true
            if library.flags[settings.flag].rainbow then
                settings:toggle(false)
            end
            local mouseconn = mouse.Move:Connect(function()
				local h, s, v = library.flags[settings.flag].colour:ToHSV()
                settings:set(Color3.fromHSV(math.clamp((mouse.X - settings.frame.drop.hue.AbsolutePosition.X) / settings.frame.drop.hue.AbsoluteSize.X, 0, 1), s, v))
            end)
            local inputconn; inputconn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mouseconn:Disconnect()
                    inputconn:Disconnect()
					library.settings.dragging = false
                end
            end)
        end
    end)

    settings.frame.drop.base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
			library.settings.dragging = true
            local mouseconn = mouse.Move:Connect(function()
				local h, s, v = library.flags[settings.flag].colour:ToHSV()
                settings:set(Color3.fromHSV(h, math.clamp((mouse.X - settings.frame.drop.base.AbsolutePosition.X) / settings.frame.drop.base.AbsoluteSize.X, 0, 1), 1 - math.clamp((mouse.Y - settings.frame.drop.base.AbsolutePosition.Y) / settings.frame.drop.base.AbsoluteSize.Y, 0, 1)))
            end)
            local inputconn; inputconn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mouseconn:Disconnect()
                    inputconn:Disconnect()
					library.settings.dragging = false
                end
            end)
        end
    end)

    settings.frame.drop.red.FocusLost:Connect(function()
        local num = tonumber(settings.frame.drop.red.Text)
        local colour = library.flags[settings.flag].colour
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            settings:set(Color3.new(num / 255, colour.G, colour.B))
        else
            settings.frame.drop.red.Text = math.round(colour.R * 255)
        end
    end)

    settings.frame.drop.green.FocusLost:Connect(function()
        local num = tonumber(settings.frame.drop.green.Text)
        local colour = library.flags[settings.flag].colour
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            settings:set(Color3.new(colour.R, num / 255, colour.B))
        else
            settings.frame.drop.green.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)

    settings.frame.drop.blue.FocusLost:Connect(function()
        local num = tonumber(settings.frame.drop.blue.Text)
        local colour = library.flags[settings.flag].colour
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            settings:set(Color3.new(colour.R, colour.G, num / 255))
        else
            settings.frame.drop.blue.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)

	table.insert(self.items, settings)
	library.flags[settings.flag] = { colour = Color3.new(1, 1, 1), rainbow = false, toggle = false }
    library.items[settings.flag] = settings
	if settings.defaultColor ~= Color3.new(1, 1, 1) then
        task.spawn(settings.set, settings, settings.defaultColor)
    end
	if settings.rainbow then
        settings:toggle(true)
	end

    --Toggle stuff 
    
    function settings:setToggle(bool)
        library.flags[self.flag].toggled = bool
		tween(self.frame.toggleIndicator.colour, 0.15, { BackgroundTransparency = bool and 0 or 1 })
		tween(self.frame.toggleIndicator.check, 0.15, { Size = bool and UDim2.new(0, 18, 0, 18) or UDim2.new() })
        settings.callback(bool)
    end
    
    settings:setToggle(settings.defaultToggle)
	settings.frame.MouseButton1Click:Connect(function()
	    if settings.frame.drop.Visible then 
    		openColor() 
	    else
    		settings:setToggle(not library.flags[settings.flag].toggled)
		end
	end)
    




    return settings
end


function card:addpicker(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
        callback = function() end,
        ignore = false,
        default = Color3.new(1, 1, 1),
        rainbow = false
    }, options)

	settings.card = self
    settings.class = "picker"
    settings.frame = create("TextButton", { 
		Font = Enum.Font.Gotham, 
		FontSize = Enum.FontSize.Size12, 
		Text = "", 
		TextColor3 = Color3.new(1, 1, 1), 
		TextSize = 12, 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 20), 
		Name = settings.title
	}, {
		create("Frame", { 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 0, 0), 
			Position = UDim2.new(1, -1, 0.5, 0), 
			Size = UDim2.new(0, 30, 0, 18), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
				Name = "stroke"
			})
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0, 2, 0.5, 0), 
			Size = UDim2.new(1, -41, 1, 0), 
			Name = "label"
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882), 
			Position = UDim2.new(0.5, 0, 1, 4), 
			Size = UDim2.new(1, 0, 0, 140), 
			Name = "drop",
			Visible = false,
			ZIndex = 2
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
				Name = "stroke"
			}),
			create("Frame", { 
				BackgroundColor3 = Color3.new(1, 0, 0), 
				Position = UDim2.new(0, 6, 0, 6), 
				Size = UDim2.new(0, 116, 0, 78), 
				Name = "base", 
				ZIndex = 2
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 0.5), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					Position = UDim2.new(0.5, 0, 0.5, 0), 
					Size = UDim2.new(1, 0, 1, 0), 
					Name = "sat", 
					ZIndex = 2
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
						Name = "stroke"
					}),
					create("UIGradient", { 
						Transparency = NumberSequence.new({ 
							NumberSequenceKeypoint.new(0, 0), 
							NumberSequenceKeypoint.new(1, 1)
						}), 
						Name = "gradient"
					}),
					create("Frame", { 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(0, 0, 0), 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Size = UDim2.new(1, 0, 1, 0), 
						Name = "val", 
						ZIndex = 2
					}, {
						create("UICorner", { 
							CornerRadius = UDim.new(0, 3), 
							Name = "corner"
						}),
						create("UIStroke", { 
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
							Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
							Name = "stroke"
						}),
						create("UIGradient", { 
							Rotation = 270, 
							Transparency = NumberSequence.new({ 
								NumberSequenceKeypoint.new(0, 0), 
								NumberSequenceKeypoint.new(1, 1)
							}), 
							Name = "gradient"
						})
					})
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 0.5), 
					BackgroundColor3 = Color3.new(1, 0, 0), 
					Position = UDim2.new(1, 0, 0, 0), 
					Size = UDim2.new(0, 12, 0, 12), 
					ZIndex = 3, 
					Name = "indicator"
				}, {
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
						Name = "stroke"
					}),
					create("UICorner", { 
						CornerRadius = UDim.new(1, 0), 
						Name = "corner"
					})
				})
			}),
			create("TextBox", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				PlaceholderText = "Red", 
				Text = "255", 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				AnchorPoint = Vector2.new(1, 0), 
				BackgroundColor3 = Color3.new(0.101961, 0.101961, 0.101961), 
				Position = UDim2.new(1, -6, 0, 6), 
				Size = UDim2.new(0, 48, 0, 22), 
				Name = "red", 
				ZIndex = 2
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 2), 
					Name = "corner"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				})
			}),
			create("TextBox", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				PlaceholderText = "Green", 
				Text = "255", 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				AnchorPoint = Vector2.new(1, 0), 
				BackgroundColor3 = Color3.new(0.101961, 0.101961, 0.101961), 
				Position = UDim2.new(1, -6, 0, 34), 
				Size = UDim2.new(0, 48, 0, 22), 
				Name = "green", 
				ZIndex = 2
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 2), 
					Name = "corner"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				})
			}),
			create("TextBox", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				PlaceholderText = "Blue", 
				Text = "255", 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				AnchorPoint = Vector2.new(1, 0), 
				BackgroundColor3 = Color3.new(0.101961, 0.101961, 0.101961), 
				Position = UDim2.new(1, -6, 0, 62), 
				Size = UDim2.new(0, 48, 0, 22), 
				Name = "blue", 
				ZIndex = 2
			}, {
				create("UICorner", { 
					CornerRadius = UDim.new(0, 2), 
					Name = "corner"
				}),
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				})
			}),
			create("TextButton", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				Text = "", 
				TextColor3 = Color3.new(1, 1, 1), 
				TextSize = 12, 
				AnchorPoint = Vector2.new(0.5, 1), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 1, -5), 
				Size = UDim2.new(1, -10, 0, 24), 
				Name = "rainbow", 
				ZIndex = 2
			}, {
				create("Frame", { 
					AnchorPoint = Vector2.new(1, 0.5), 
					BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
					Position = UDim2.new(1, -1, 0.5, 0), 
					Size = UDim2.new(0, 22, 0, 22), 
					Name = "indicator", 
					ZIndex = 2
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
						Name = "stroke"
					}),
					create("ImageLabel", { 
						Image = "rbxassetid://10138918728", 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						ZIndex = 3, 
						Name = "check"
					}),
					create("Frame", { 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Size = UDim2.new(1, 0, 1, 0), 
						Name = "colour", 
						ZIndex = 2
					}, {
						create("UIGradient", { 
							Color = ColorSequence.new({ 
								ColorSequenceKeypoint.new(0, library.theme.gradient1), 
								ColorSequenceKeypoint.new(1, library.theme.gradient2)
							}), 
							Rotation = 35, 
							Name = "gradient"
						}),
						create("UIStroke", { 
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
							Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
							Name = "stroke"
						}),
						create("UICorner", { 
							CornerRadius = UDim.new(0, 3), 
							Name = "corner"
						})
					})
				}),
				create("TextLabel", { 
					Font = Enum.Font.GothamMedium, 
					FontSize = Enum.FontSize.Size12, 
					Text = "Rainbow", 
					TextColor3 = Color3.new(1, 1, 1), 
					TextSize = 12, 
					TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
					TextStrokeTransparency = 0.5, 
					TextXAlignment = Enum.TextXAlignment.Left, 
					AnchorPoint = Vector2.new(0, 0.5), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					BackgroundTransparency = 1, 
					Position = UDim2.new(0, 2, 0.5, 0), 
					Size = UDim2.new(1, -29, 1, 0), 
					Name = "label", 
					ZIndex = 2
				})
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(0.5, 0), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				Position = UDim2.new(0.5, 0, 0, 90), 
				Size = UDim2.new(1, -12, 0, 16), 
				Name = "hue", 
				ZIndex = 2
			}, {
				create("UIStroke", { 
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
					Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
					Name = "stroke"
				}),
				create("UICorner", { 
					CornerRadius = UDim.new(0, 3), 
					Name = "corner"
				}),
				create("UIGradient", { 
					Color = ColorSequence.new({ 
						ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)), 
						ColorSequenceKeypoint.new(0.16666659712791443, Color3.new(1, 1, 0)), 
						ColorSequenceKeypoint.new(0.33333298563957214, Color3.new(0, 1, 0)), 
						ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)), 
						ColorSequenceKeypoint.new(0.6660000085830688, Color3.new(0, 0, 1)), 
						ColorSequenceKeypoint.new(0.8333330154418945, Color3.new(1, 0, 1)), 
						ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0.01568627543747425))
					}), 
					Name = "gradient"
				}),
				create("Frame", { 
					AnchorPoint = Vector2.new(0.5, 0.5), 
					BackgroundColor3 = Color3.new(1, 0, 0), 
					Position = UDim2.new(0, 0, 0.5, 0), 
					Size = UDim2.new(0, 8, 1, 0), 
					Name = "indicator", 
					ZIndex = 2
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 2), 
						Name = "corner"
					}),
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
						Name = "stroke"
					})
				})
			})
		})
	})

    function settings:set(colour)
		local h, s, v = colour:ToHSV()
		library.flags[self.flag].colour = colour
		self.frame.indicator.BackgroundColor3 = colour
		self.frame.drop.base.indicator.BackgroundColor3 = colour
		self.frame.drop.base.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		self.frame.drop.hue.indicator.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		self.frame.drop.red.Text = math.round(colour.R * 255)
		self.frame.drop.green.Text = math.round(colour.G * 255)
		self.frame.drop.blue.Text = math.round(colour.B * 255)
		tween(self.frame.drop.base.indicator, 0.25, { Position = UDim2.new(s, 0, 1 - v, 0) })
		if library.flags[self.flag].rainbow then
			self.frame.drop.hue.indicator.Position = UDim2.new(h, 0, 0.5, 0)
		else
			tween(self.frame.drop.hue.indicator, 0.25, { Position = UDim2.new(h, 0, 0.5, 0) })
		end
		self.callback(colour)
    end

    function settings:toggle(bool)
        library.flags[self.flag].rainbow = bool
		tween(self.frame.drop.rainbow.indicator.colour, 0.15, { BackgroundTransparency = bool and 0 or 1 })
		tween(self.frame.drop.rainbow.indicator.check, 0.15, { Size = bool and UDim2.new(0, 18, 0, 18) or UDim2.new() })
    end

    settings.frame.MouseButton1Click:Connect(function()
		local opendrop = self.tab.opendrop
		if opendrop and ismouseoverobject(opendrop.frame.drop) then
			return
		end
		local vis = not settings.frame.drop.Visible
		if opendrop then
			opendrop.frame.drop.Visible = false
			self.tab.opendrop = nil
		end
		if vis then
			settings.frame.drop.Visible = true
			self.tab.opendrop = settings
		end
		self.tab:resize()
    end)

    settings.frame.drop.rainbow.MouseButton1Click:Connect(function()
        settings:toggle(not library.flags[settings.flag].rainbow)
    end)

    settings.frame.drop.hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
			library.settings.dragging = true
            if library.flags[settings.flag].rainbow then
                settings:toggle(false)
            end
            local mouseconn = mouse.Move:Connect(function()
				local h, s, v = library.flags[settings.flag].colour:ToHSV()
                settings:set(Color3.fromHSV(math.clamp((mouse.X - settings.frame.drop.hue.AbsolutePosition.X) / settings.frame.drop.hue.AbsoluteSize.X, 0, 1), s, v))
            end)
            local inputconn; inputconn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mouseconn:Disconnect()
                    inputconn:Disconnect()
					library.settings.dragging = false
                end
            end)
        end
    end)

    settings.frame.drop.base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
			library.settings.dragging = true
            local mouseconn = mouse.Move:Connect(function()
				local h, s, v = library.flags[settings.flag].colour:ToHSV()
                settings:set(Color3.fromHSV(h, math.clamp((mouse.X - settings.frame.drop.base.AbsolutePosition.X) / settings.frame.drop.base.AbsoluteSize.X, 0, 1), 1 - math.clamp((mouse.Y - settings.frame.drop.base.AbsolutePosition.Y) / settings.frame.drop.base.AbsoluteSize.Y, 0, 1)))
            end)
            local inputconn; inputconn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mouseconn:Disconnect()
                    inputconn:Disconnect()
					library.settings.dragging = false
                end
            end)
        end
    end)

    settings.frame.drop.red.FocusLost:Connect(function()
        local num = tonumber(settings.frame.drop.red.Text)
        local colour = library.flags[settings.flag].colour
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            settings:set(Color3.new(num / 255, colour.G, colour.B))
        else
            settings.frame.drop.red.Text = math.round(colour.R * 255)
        end
    end)

    settings.frame.drop.green.FocusLost:Connect(function()
        local num = tonumber(settings.frame.drop.green.Text)
        local colour = library.flags[settings.flag].colour
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            settings:set(Color3.new(colour.R, num / 255, colour.B))
        else
            settings.frame.drop.green.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)

    settings.frame.drop.blue.FocusLost:Connect(function()
        local num = tonumber(settings.frame.drop.blue.Text)
        local colour = library.flags[settings.flag].colour
        if num and math.floor(num) == num and num >= 0 and num <= 255 then
            settings:set(Color3.new(colour.R, colour.G, num / 255))
        else
            settings.frame.drop.blue.Text = math.floor(colour.R * 255 + 0.5)
        end
    end)

	table.insert(self.items, settings)
	library.flags[settings.flag] = { colour = Color3.new(1, 1, 1), rainbow = false }
    library.items[settings.flag] = settings
	if settings.default ~= Color3.new(1, 1, 1) then
        task.spawn(settings.set, settings, settings.default)
    end
	if settings.rainbow then
        settings:toggle(true)
    end
    return settings
end

function card:adddropdown(options)
    local settings = mergetables({
        title = "No Title Provided",
        flag = "No Flag Provided",
        callback = function() end,
        ignore = false,
        items = {},
        multi = false,
        default = ""
    }, options)

    local itemstore = {}

	settings.card = self
    settings.class = "dropdown"
    settings.frame = create("TextButton", { 
		Font = Enum.Font.SourceSans, 
		FontSize = Enum.FontSize.Size14, 
		Text = "", 
		TextColor3 = Color3.new(0, 0, 0), 
		TextSize = 14, 
		AutoButtonColor = false, 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.frame.container,
		Size = UDim2.new(1, 0, 0, 42), 
		Name = settings.title
	}, {
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 1), 
			BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
			ClipsDescendants = true, 
			Position = UDim2.new(0.5, 0, 1, -1), 
			Size = UDim2.new(1, -2, 0, 20), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 2), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0627451, 0.0627451, 0.0627451), 
				Name = "stroke"
			}),
			create("TextLabel", { 
				Font = Enum.Font.Gotham, 
				FontSize = Enum.FontSize.Size12, 
				Text = "", 
				TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
				TextSize = 12, 
				TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
				TextStrokeTransparency = 0.5, 
				TextXAlignment = Enum.TextXAlignment.Left, 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -16, 1, 0), 
				Name = "label"
			}),
			create("ImageLabel", { 
				Image = "rbxassetid://10156126326", 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(1, -4, 0.5, 0), 
				Size = UDim2.new(0, 16, 0, 16), 
				Name = "icon"
			})
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.title, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Size = UDim2.new(1, -4, 0, 20), 
			Name = "label"
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882), 
			Position = UDim2.new(0.5, 0, 1, 4), 
			Size = UDim2.new(1, 0, 0, 102), 
			Name = "drop",
			Visible = false, 
			ZIndex = 2
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0470588, 0.0470588, 0.0470588), 
				Name = "stroke"
			}),
			create("ScrollingFrame", { 
				BottomImage = "rbxassetid://10156215470", 
				MidImage = "rbxassetid://10156215211", 
				ScrollBarImageColor3 = Color3.new(0.0470588, 0.0470588, 0.0470588), 
				ScrollBarThickness = 4, 
				TopImage = "rbxassetid://10156214878", 
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar, 
				Active = true, 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				BorderSizePixel = 0, 
				Position = UDim2.new(1, 0, 0.5, 0), 
				Size = UDim2.new(1, -4, 1, -8), 
				Name = "container", 
				ZIndex = 2
			}, {
				create("UIListLayout", { 
					Padding = UDim.new(0, 4), 
					SortOrder = Enum.SortOrder.LayoutOrder, 
					Name = "list"
				}),
				create("UIPadding", { 
					PaddingBottom = UDim.new(0, 1), 
					PaddingLeft = UDim.new(0, 1), 
					PaddingRight = UDim.new(0, 1), 
					PaddingTop = UDim.new(0, 1), 
					Name = "padding"
				})
			})
		})
	})
    local selected = {}
    function settings:set(value)
        if library.flags[self.flag] ~= value then
			local items = self.frame.drop.container:GetChildren()
            for i = 1, #items do
                local item = items[i]
                if item.ClassName == "TextButton" then
                    if item.Name == library.flags[self.flag] and not options.multi then
                        tween(item.stroke, 0.25, { Transparency = 1 })
                    elseif item.Name == value then
                        tween(item.stroke, 0.25, { Transparency = 0 })
                    end
                end
            end
            library.flags[self.flag] = value
            self.frame.indicator.label.Text = value
            self.callback(value)
        end
    end

    function settings:add(value)
        local strvalue = tostring(value)        table.insert(itemstore, strvalue)

        local item = create("TextButton", { 
			Font = Enum.Font.Gotham, 
			FontSize = Enum.FontSize.Size12, 
			Text = strvalue, 
			TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			AutoButtonColor = false, 
			BackgroundColor3 = Color3.new(0.113725, 0.113725, 0.113725), 
			Parent = self.frame.drop.container,
			Size = UDim2.new(1, -4, 0, 20), 
			Name = strvalue, 
			ZIndex = 2
		}, {
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(1, 1, 1), 
				Transparency = 1, 
				Name = "stroke"
			}, {
				create("UIGradient", { 
					Color = ColorSequence.new({ 
						ColorSequenceKeypoint.new(0, library.theme.gradient1), 
						ColorSequenceKeypoint.new(1, library.theme.gradient2)
					}), 
					Rotation = 35, 
					Name = "gradient"
				})
			}),
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			})
		})
        local x = false
        item.MouseButton1Click:Connect(function()
            x = not x 
            if x then 
                table.insert(selected,strvalue)
            else
                table.remove(selected,table.find(selected,strvalue))
                tween(item.stroke, 0.25, { Transparency = 1 })
            end
            self:set(strvalue)
        end)
    end

    function settings:remove(value)
        local idx = table.find(itemstore, value)
        if idx then
            table.remove(itemstore, idx)
        end
        local item = self.frame.drop.container:FindFirstChild(value)
        if item then
            item:Destroy()
        end
    end

    function settings:clear()
        local children = self.frame.drop.container:GetChildren()
        for i = 1, #children do
            local v = children[i]
            if v.ClassName == "TextButton" then
                v:Destroy()
            end
        end
        table.clear(itemstore)
    end

    autocanvasresize(settings.frame.drop.container.list, settings.frame.drop.container, function(layout, frame)
		return UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 2)
	end)

    for i = 1, #settings.items do
        settings:add(settings.items[i])
    end
    settings.items = itemstore

    settings.frame.MouseButton1Click:Connect(function()
		local opendrop = self.tab.opendrop
		if opendrop and ismouseoverobject(opendrop.frame.drop) then
			return
		end
		local vis = not settings.frame.drop.Visible
		if opendrop then
			opendrop.frame.drop.Visible = false
			self.tab.opendrop = nil
		end
		if vis then
			settings.frame.drop.Visible = true
			self.tab.opendrop = settings
		end
		self.tab:resize()
	end)

	table.insert(self.items, settings)
    library.flags[settings.flag] = ""
    library.items[settings.flag] = settings
	if settings.default ~= "" then
        task.spawn(settings.set, settings, settings.default)
    end
    return settings
end

--[[ Tab ]]--

local tab = {}
tab.__index = tab

function tab.new(title)
    return setmetatable({
        title = title or "Untitled",
        cards = {}
    }, tab)
end

function tab:addcard(title, right)
    local newcard = card.new(title, right)
	newcard.tab = self

    newcard.frame = create("Frame", { 
		BackgroundColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
		Parent = self.frame[newcard.right and "right" or "left"],
		Size = UDim2.new(1, 0, 0, 41), 
		Name = newcard.title
	}, {
		create("UICorner", { 
			CornerRadius = UDim.new(0, 3), 
			Name = "corner"
		}),
		create("UIStroke", { 
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
			Color = Color3.new(0.0431373, 0.0431373, 0.0431373), 
			Name = "stroke"
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size14, 
			Text = newcard.title, 
			TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
			TextSize = 14, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 0), 
			Size = UDim2.new(1, -16, 0, 28), 
			Name = "title"
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 1), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 1, -6), 
			Size = UDim2.new(1, -12, 1, -41), 
			Name = "container"
		}, {
			create("UIListLayout", { 
				Padding = UDim.new(0, 4), 
				SortOrder = Enum.SortOrder.LayoutOrder, 
				Name = "list"
			})
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(0.25098, 0.25098, 0.25098), 
			BorderSizePixel = 0, 
			Position = UDim2.new(0.5, 0, 0, 28), 
			Size = UDim2.new(1, -12, 0, 1), 
			Name = "separator"
		}, {
			create("UIGradient", { 
				Transparency = NumberSequence.new({ 
					NumberSequenceKeypoint.new(0, 1), 
					NumberSequenceKeypoint.new(0.15046297013759613, 0), 
					NumberSequenceKeypoint.new(0.8495370149612427, 0), 
					NumberSequenceKeypoint.new(1, 1)
				}), 
				Name = "gradient"
			})
		})
	})

	newcard.container = create("Folder", {
		Name = newcard.title,
		Parent = self.container
	})

    newcard.frame.container.list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        newcard.frame.Size = UDim2.new(1, 0, 0, newcard.frame.container.list.AbsoluteContentSize.Y + 41)
    end)

	self.cards[title] = newcard
    return newcard
end

--[[ Library ]]--

function library:create(title)
    if self.settings.created then
        return
    end
    self.settings.created = true
    self.settings.open = true
    self.title = title

    self.dir = create("Folder", {
        Name = "LevelUpUi"
    }, {
        create("Folder", {
            Name = "containers"
        }),
		create("ScreenGui", {
			DisplayOrder = 1,
			Name = "notifications"
		})
    })

    self.gui = create("ScreenGui", { 
		ZIndexBehavior = Enum.ZIndexBehavior.Global, 
		Name = "ui", 
		Parent = self.dir
	}, {
		create("Frame", { 
			BackgroundColor3 = Color3.new(0.054902, 0.054902, 0.054902), 
			Position = UDim2.new(0, 15, 0, 565), 
			Size = UDim2.new(0, 565*1.2, 0, 400*1.2), -- sizeX/Y
			Name = "main"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("ImageLabel", { 
				Image = "rbxassetid://9795030819", 
				ImageColor3 = Color3.new(0.054902, 0.054902, 0.054902), 
				ScaleType = Enum.ScaleType.Slice, 
				SliceCenter = Rect.new(10, 10, 118, 118), 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, 10, 1, 10), 
				ZIndex = 0, 
				Name = "blur"
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(0, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				BorderSizePixel = 0, 
				Position = UDim2.new(0, 0, 0.5, 0), 
				Size = UDim2.new(0, 152, 1, 0), 
				Name = "left"
			}, {
				create("ScrollingFrame", { 
					CanvasSize = UDim2.new(0, 0, 0, 0), 
					ScrollBarImageColor3 = Color3.new(0, 0, 0), 
					ScrollBarThickness = 0, 
					ScrollingDirection = Enum.ScrollingDirection.X, 
					Active = true, 
					AnchorPoint = Vector2.new(0.5, 1), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					BackgroundTransparency = 1, 
					BorderSizePixel = 0, 
					Position = UDim2.new(0.5, 0, 1, -8), 
					Size = UDim2.new(1, -16, 1, -82), 
					Name = "container"
				}, {
					create("UIListLayout", { 
						Padding = UDim.new(0, 4), 
						SortOrder = Enum.SortOrder.LayoutOrder, 
						Name = "list"
					})
				}),
				create("TextLabel", { 
					Font = Enum.Font.GothamBold, 
					FontSize = Enum.FontSize.Size18, 
					RichText = true, 
					Text = title, 
					TextColor3 = library.theme.gamecolor, 
					TextSize = 16, 
					TextWrap = true, 
					TextWrapped = true, 
					TextXAlignment = Enum.TextXAlignment.Left, 
					TextYAlignment = Enum.TextYAlignment.Top, 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					BackgroundTransparency = 1, 
					Position = UDim2.new(0, 12, 0, 36), 
					Size = UDim2.new(1, -12, 0, 26), 
					Name = "game"
				}),
				create("TextLabel", { 
					Font = Enum.Font.GothamBlack, 
					FontSize = Enum.FontSize.Size24, 
					Text = "LevelUp", 
					TextColor3 = Color3.new(1, 1, 1), 
					TextSize = 22, 
					TextWrap = true, 
					TextWrapped = true, 
					TextXAlignment = Enum.TextXAlignment.Left, 
					TextYAlignment = Enum.TextYAlignment.Bottom, 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					BackgroundTransparency = 1, 
					Position = UDim2.new(0, 12, 0, 10), 
					Size = UDim2.new(1, -12, 0, 26), 
					Name = "title"
				})
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(0, 0.5), 
				BackgroundColor3 = Color3.new(0.109804, 0.109804, 0.109804), 
				BorderSizePixel = 0, 
				Position = UDim2.new(0, 152, 0.5, 0), 
				Size = UDim2.new(0, 1, 1, 0), 
				Name = "separator"
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(1, 0), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				BorderSizePixel = 0, 
				Position = UDim2.new(1, 0, 0, 0), 
				Size = UDim2.new(1, -153, 0, 42), 
				Name = "top"
			}, {
				create("Frame", { 
					AnchorPoint = Vector2.new(0, 0.5), 
					BackgroundColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
					BorderSizePixel = 0, 
					Position = UDim2.new(0, 7, 0.5, 0), 
					Size = UDim2.new(1, -82, 0, 28), 
					Name = "search"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("TextBox", { 
						Font = Enum.Font.Gotham, 
						FontSize = Enum.FontSize.Size14, 
						PlaceholderText = "Search...", 
						Text = "", 
						TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
						TextSize = 13, 
						TextXAlignment = Enum.TextXAlignment.Left, 
						AnchorPoint = Vector2.new(1, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(1, -8, 0.5, 0), 
						Size = UDim2.new(1, -38, 1, 0), 
						Name = "input"
					}),
					create("UIStroke", { 
						Color = Color3.new(0.0431373, 0.0431373, 0.0431373), 
						Name = "stroke"
					}),
					create("ImageLabel", { 
						Image = "rbxassetid://10145609478", 
						AnchorPoint = Vector2.new(0, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(0, 4, 0.5, 0), 
						Size = UDim2.new(0, 20, 0, 20), 
						Name = "icon"
					})
				}),
				create("TextButton", { 
					Font = Enum.Font.SourceSans, 
					FontSize = Enum.FontSize.Size14, 
					Text = "", 
					TextColor3 = Color3.new(0, 0, 0), 
					TextSize = 14, 
					AutoButtonColor = false, 
					AnchorPoint = Vector2.new(1, 0.5), 
					BackgroundColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
					Position = UDim2.new(1, -7, 0.5, 0), 
					Size = UDim2.new(0, 28, 0, 28), 
					Name = "close"
				}, {
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("ImageLabel", { 
						Image = "rbxassetid://10145570075", 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Size = UDim2.new(0, 24, 0, 24), 
						Name = "icon"
					}),
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0431373, 0.0431373, 0.0431373), 
						Name = "stroke"
					})
				}),
				create("TextButton", { 
					Font = Enum.Font.SourceSans, 
					FontSize = Enum.FontSize.Size14, 
					Text = "", 
					TextColor3 = Color3.new(0, 0, 0), 
					TextSize = 14, 
					AutoButtonColor = false, 
					AnchorPoint = Vector2.new(1, 0.5), 
					BackgroundColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
					Position = UDim2.new(1, -41, 0.5, 0), 
					Size = UDim2.new(0, 28, 0, 28), 
					Name = "hide"
				}, {
					create("UIStroke", { 
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
						Color = Color3.new(0.0431373, 0.0431373, 0.0431373), 
						Name = "stroke"
					}),
					create("UICorner", { 
						CornerRadius = UDim.new(0, 3), 
						Name = "corner"
					}),
					create("ImageLabel", { 
						Image = "rbxassetid://10145580358", 
						AnchorPoint = Vector2.new(0.5, 0.5), 
						BackgroundColor3 = Color3.new(1, 1, 1), 
						BackgroundTransparency = 1, 
						Position = UDim2.new(0.5, 0, 0.5, 0), 
						Size = UDim2.new(0, 20, 0, 20), 
						Name = "icon"
					})
				})
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(0.109804, 0.109804, 0.109804), 
				BorderSizePixel = 0, 
				Position = UDim2.new(1, 0, 0, 42), 
				Size = UDim2.new(1, -153, 0, 1), 
				Name = "separator"
			}),
			create("Folder", { 
				Name = "container"
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(1, 0.5), 
				BackgroundColor3 = Color3.new(0.109804, 0.109804, 0.109804), 
				BorderSizePixel = 0, 
				Position = UDim2.new(1, 0, 1, -29), 
				Size = UDim2.new(1, -153, 0, 1), 
				Name = "separator"
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(1, 1), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				BorderSizePixel = 0, 
				Position = UDim2.new(1, 0, 1, 0), 
				Size = UDim2.new(1, -153, 0, 28), 
				Name = "bottom"
			}, {
				create("TextLabel", { 
					Font = Enum.Font.GothamMedium, 
					FontSize = Enum.FontSize.Size14, 
					RichText = true, 
					Text = "Version 0.5", 
					TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
					TextSize = 13, 
					TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
					TextStrokeTransparency = 0.5, 
					TextWrap = true, 
					TextWrapped = true, 
					TextXAlignment = Enum.TextXAlignment.Right, 
					AnchorPoint = Vector2.new(0.5, 0.5), 
					BackgroundColor3 = Color3.new(1, 1, 1), 
					BackgroundTransparency = 1, 
					Position = UDim2.new(0.5, 0, 0.5, 0), 
					Size = UDim2.new(1, -14, 1, 0), 
					Name = "version"
				})
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(0, 0.5), 
				BackgroundColor3 = Color3.new(0.109804, 0.109804, 0.109804), 
				BorderSizePixel = 0, 
				Position = UDim2.new(0, 0, 0, 65), 
				Size = UDim2.new(0, 152, 0, 1), 
				Name = "separator"
			})
		})
	})

    makedraggable(self.gui.main)
    secureparent(self.dir)

    local paths = { "Darl", "LevelUp\\Configs", "LevelUp\\Configs\\" .. title, "LevelUp\\Themes" }
    for i = 1, #paths do
        local path = paths[i]
        if isfolder(path) == false then
            makefolder(path)
        end
    end

	self.gui.main.top.hide.MouseButton1Click:Connect(function()
		self.settings.open = not self.settings.open
		tween(self.gui.main, 0.25, { Position = self.settings.open and UDim2.new(0, 75, 0, 150) or UDim2.new(0, self.gui.main.AbsolutePosition.X, 0, camera.ViewportSize.Y - (56 + guiservice:GetGuiInset().Y)) })
	end)

	self.gui.main.top.close.MouseButton1Click:Connect(function()
		library.gui.main.Visible = not library.gui.main.Visible
	end)
   
	self.gui.main.top.search.input:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(self.gui.main.top.search.input.Text)
		for _, tab in next, self.tabs do
			for _, card in next, tab.cards do
				for i = 1, #card.items do
					local v = card.items[i]
					v.frame.Parent = card.container
					if string.find(string.lower(v.title), query) then
						v.frame.Parent = card.frame.container
					end
				end
			end
		end
    end)
end

function library:addtab(title)
    local newtab = tab.new(title)

    newtab.selection = create("Frame", { 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.gui.main.left.container,
		Size = UDim2.new(1, 0, 0, 30), 
		Name = newtab.title
	}, {
		create("TextButton", { 
			Font = Enum.Font.SourceSans, 
			FontSize = Enum.FontSize.Size14, 
			Text = "", 
			TextColor3 = Color3.new(0, 0, 0), 
			TextSize = 14, 
			AutoButtonColor = false, 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, -2, 1, -2), 
			Name = "button"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0823529, 0.0823529, 0.0823529), 
				Transparency = 1, 
				Name = "stroke"
			}),
			create("UIGradient", { 
				Color = ColorSequence.new({ 
					ColorSequenceKeypoint.new(0, library.theme.gradient1), 
					ColorSequenceKeypoint.new(1, library.theme.gradient2)
				}), 
				Rotation = 35, 
				Name = "gradient"
			})
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamBold, 
			FontSize = Enum.FontSize.Size14, 
			Text = newtab.title, 
			TextColor3 = Color3.new(0.705882, 0.705882, 0.705882), 
			TextSize = 13, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(1, -10, 1, 0), 
			Name = "title"
		})
	})

    newtab.frame = create("Frame", { 
		AnchorPoint = Vector2.new(1, 1), 
		BackgroundColor3 = Color3.new(1, 1, 1), 
		BackgroundTransparency = 1, 
		Parent = self.gui.main.container,
		Position = UDim2.new(1, -8, 1, -36), 
		Size = UDim2.new(1, -168, 1, -86), 
		Name = newtab.title,
		Visible = false
	}, {
		create("ScrollingFrame", { 
			ScrollBarImageColor3 = Color3.new(0, 0, 0), 
			ScrollBarThickness = 0, 
			Active = true, 
			AnchorPoint = Vector2.new(0, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			BorderSizePixel = 0, 
			Position = UDim2.new(0, 0, 0.5, 0), 
			Size = UDim2.new(0.5, -2, 1, 0), 
			Name = "left"
		}, {
			create("UIListLayout", { 
				Padding = UDim.new(0, 6), 
				SortOrder = Enum.SortOrder.LayoutOrder, 
				Name = "list"
			}),
			create("UIPadding", { 
				PaddingBottom = UDim.new(0, 1), 
				PaddingLeft = UDim.new(0, 1), 
				PaddingRight = UDim.new(0, 1), 
				PaddingTop = UDim.new(0, 1), 
				Name = "padding"
			})
		}),
		create("ScrollingFrame", { 
			ScrollBarImageColor3 = Color3.new(0, 0, 0), 
			ScrollBarThickness = 0, 
			Active = true, 
			AnchorPoint = Vector2.new(1, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			BorderSizePixel = 0, 
			Position = UDim2.new(1, 0, 0.5, 0), 
			Size = UDim2.new(0.5, -2, 1, 0), 
			Name = "right"
		}, {
			create("UIListLayout", { 
				Padding = UDim.new(0, 6), 
				SortOrder = Enum.SortOrder.LayoutOrder, 
				Name = "list"
			}),
			create("UIPadding", { 
				PaddingBottom = UDim.new(0, 1), 
				PaddingLeft = UDim.new(0, 1), 
				PaddingRight = UDim.new(0, 1), 
				PaddingTop = UDim.new(0, 1), 
				Name = "padding"
			})
		})
	})

	newtab.container = create("Folder", {
		Name = newtab.title,
		Parent = self.dir.containers
	})

	local resizeleft = autocanvasresize(newtab.frame.left.list, newtab.frame.left, function(layout, frame)
		local top = newtab.frame.AbsolutePosition.Y
		local bottom = layout.AbsoluteContentSize.Y + 2
		local opendrop = newtab.opendrop
		if opendrop and opendrop.card.right == false then
			local drop = opendrop.frame.drop
			local y = ((drop.AbsolutePosition.Y + frame.CanvasPosition.Y) - top) + drop.AbsoluteSize.Y + 1
			if y > bottom then
				bottom = y
			end
		end
		return UDim2.new(0, 0, 0, bottom)
	end)

	local resizeright = autocanvasresize(newtab.frame.right.list, newtab.frame.right, function(layout, frame)
		local top = newtab.frame.AbsolutePosition.Y
		local bottom = layout.AbsoluteContentSize.Y + 2
		local opendrop = newtab.opendrop
		if opendrop and opendrop.card.right == true then
			local drop = opendrop.frame.drop
			local y = ((drop.AbsolutePosition.Y + frame.CanvasPosition.Y) - top) + drop.AbsoluteSize.Y + 12
			if y > bottom then
				bottom = y
			end
		end
		return UDim2.new(0, 0, 0, bottom)
	end)

	function newtab:resize()
		resizeleft()
		resizeright()
	end

    newtab.selection.button.MouseButton1Click:Connect(function()
        if self.settings.selected ~= title then
            self:select(title)
        end
    end)

    self.tabs[title] = newtab
	if self.settings.selected == nil then
        self:select(title)
    end
    return newtab
end

function library:select(title)
    local selected = assert(self.tabs[title])
    if self.settings.selected then
        if self.settings.selected == title then
            return
        end
		local tab = self.tabs[self.settings.selected]
        tab.frame.Visible = false
		tween(tab.selection.button, 0.25, { BackgroundTransparency = 1 })
		tween(tab.selection.button.stroke, 0.25, { Transparency = 1 })
		tween(tab.selection.title, 0.25, { TextColor3 = Color3.fromRGB(180, 180, 180) })
    end
    self.settings.selected = title
    selected.frame.Visible = true
	tween(selected.selection.button, 0.25, { BackgroundTransparency = 0 })
	tween(selected.selection.button.stroke, 0.25, { Transparency = 0 })
	tween(selected.selection.title, 0.25, { TextColor3 = Color3.new(1, 1, 1) })
end

function library:notify(options)
	local settings = mergetables({
        title = "No Title Provided",
        content = "No Content Provided",
        callback = function() end,
		duration = 10
    }, options)

	local called = false

	local frame = create("Frame", { 
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.new(0.054902, 0.054902, 0.054902), 
		Position = UDim2.new(1, 10, 1, -30), 
		Size = UDim2.new(0, 320, 0, textservice:GetTextSize(settings.content, 12, Enum.Font.GothamMedium, Vector2.new(288, math.huge)).Y + 58), 
		Name = "main", 
		Parent = self.dir.notifications
	}, {
		create("UICorner", { 
			CornerRadius = UDim.new(0, 3), 
			Name = "corner"
		}),
		create("ImageLabel", { 
			Image = "rbxassetid://9795030819", 
			ImageColor3 = Color3.new(0.054902, 0.054902, 0.054902), 
			ScaleType = Enum.ScaleType.Slice, 
			SliceCenter = Rect.new(10, 10, 118, 118), 
			AnchorPoint = Vector2.new(0.5, 0.5), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0.5, 0), 
			Size = UDim2.new(1, 10, 1, 10), 
			ZIndex = 0, 
			Name = "blur"
		}),
		create("TextButton", { 
			Font = Enum.Font.SourceSans, 
			FontSize = Enum.FontSize.Size14, 
			Text = "", 
			TextColor3 = Color3.new(0, 0, 0), 
			TextSize = 14, 
			AutoButtonColor = false, 
			AnchorPoint = Vector2.new(1, 0), 
			BackgroundColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			Position = UDim2.new(1, -7, 0, 7), 
			Size = UDim2.new(0, 22, 0, 22), 
			Name = "no"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("ImageLabel", { 
				Image = "rbxassetid://10260767473", 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -4, 1, -4), 
				Name = "icon"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0431373, 0.0431373, 0.0431373), 
				Name = "stroke"
			})
		}),
		create("TextButton", { 
			Font = Enum.Font.SourceSans, 
			FontSize = Enum.FontSize.Size14, 
			Text = "", 
			TextColor3 = Color3.new(0, 0, 0), 
			TextSize = 14, 
			AutoButtonColor = false, 
			AnchorPoint = Vector2.new(1, 0), 
			BackgroundColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			Position = UDim2.new(1, -34, 0, 7), 
			Size = UDim2.new(0, 22, 0, 22), 
			Name = "yes"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(0, 3), 
				Name = "corner"
			}),
			create("ImageLabel", { 
				Image = "rbxassetid://10138918728", 
				AnchorPoint = Vector2.new(0.5, 0.5), 
				BackgroundColor3 = Color3.new(1, 1, 1), 
				BackgroundTransparency = 1, 
				Position = UDim2.new(0.5, 0, 0.5, 0), 
				Size = UDim2.new(1, -4, 1, -4), 
				Name = "icon"
			}),
			create("UIStroke", { 
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border, 
				Color = Color3.new(0.0431373, 0.0431373, 0.0431373), 
				Name = "stroke"
			})
		}),
		create("Frame", { 
			AnchorPoint = Vector2.new(0, 1), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			Position = UDim2.new(0, 0, 1, 0), 
			Size = UDim2.new(0, 0, 0, 6), 
			Name = "indicator"
		}, {
			create("UICorner", { 
				CornerRadius = UDim.new(1, 0), 
				Name = "corner"
			}),
			create("Frame", { 
				AnchorPoint = Vector2.new(0.5, 0), 
				BackgroundColor3 = Color3.new(0.054902, 0.054902, 0.054902), 
				BorderSizePixel = 0, 
				Position = UDim2.new(0.5, 0, 0, 0), 
				Size = UDim2.new(1, 0, 0.5, 0), 
				Name = "cover"
			}),
			create("UIGradient", { 
				Color = ColorSequence.new({ 
					ColorSequenceKeypoint.new(0, library.theme.gradient1), 
					ColorSequenceKeypoint.new(1, library.theme.gradient2)
				}), 
				Rotation = 35, 
				Name = "gradient"
			})
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size14, 
			Text = settings.title, 
			TextColor3 = Color3.new(0.882353, 0.882353, 0.882353), 
			TextSize = 14, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0, 10, 0, 7), 
			Size = UDim2.new(1, -20, 0, 22), 
			Name = "title"
		}),
		create("TextLabel", { 
			Font = Enum.Font.GothamMedium, 
			FontSize = Enum.FontSize.Size12, 
			Text = settings.content, 
			TextColor3 = Color3.new(1, 1, 1), 
			TextSize = 12, 
			TextStrokeColor3 = Color3.new(0.0823529, 0.0823529, 0.0823529), 
			TextStrokeTransparency = 0.5, 
			TextWrap = true, 
			TextWrapped = true, 
			TextXAlignment = Enum.TextXAlignment.Left, 
			AnchorPoint = Vector2.new(0.5, 0), 
			BackgroundColor3 = Color3.new(1, 1, 1), 
			BackgroundTransparency = 1, 
			Position = UDim2.new(0.5, 0, 0, 33), 
			Size = UDim2.new(1, -32, 1, -45), 
			Name = "content"
		})
	})

	local function closenotif(option)
		called = true
		tween(frame, 0.25, { Position = UDim2.new(1, 10, frame.Position.Y.Scale, frame.Position.Y.Offset) }).Completed:Connect(function()
			frame:Destroy()
			organisenotifs()
		end)
		settings.callback(option)
	end

	frame.yes.MouseButton1Click:Connect(function()
		closenotif(true)
	end)

	frame.no.MouseButton1Click:Connect(function()
		closenotif(false)
	end)

	organisenotifs()

	tween(frame.indicator, settings.duration, { Size = UDim2.new(1, 0, 0, 6) }, Enum.EasingStyle.Linear).Completed:Connect(function()
		if not called then
			closenotif(false)
		end
	end)
end

function library:getconfigs()
    local configs = {}
    local path = "LevelUp\\Configs\\" .. self.title
    if isfolder(path) then
        local files = listfiles(path)
        for i = 1, #files do
            local name = string.gsub(files[i], ".*\\", "")
            if name and string.sub(name, #name - 4) == ".json" then
                table.insert(configs, string.sub(name, 1, #name - 5))
            end
        end
    end
    return configs
end

function library:loadconfig(name)
    local path = string.format("LevelUp\\Configs\\%s\\%s.json", self.title, name)
    if isfile(path) then
        local succ, res = pcall(httpservice.JSONDecode, httpservice, readfile(path))
        if succ then
            for i, v in next, res do
                local item = self.items[i]
                if item ~= nil then
                    task.spawn(function()
                        if item.class == "picker" then
                            item:toggle(v.rainbow)
                            if item.setToggle then 
                                item:setToggle(v.toggled)
                            end
                            item:set(hextocolour(v.colour))
                        else
                            item:set(v)
                        end
                    end)
                end
            end
        end
    end
end

function library:saveconfig(name)
    local flags = {}
    for i, v in next, library.flags do
		local item = library.items[i]
        if item and not item.ignore then
			if item.class == "picker" then
				local value = deepclone(v)
				value.colour = colourtohex(value.colour)
				flags[i] = value
            else
				flags[i] = v
			end
        end
    end
	writefile(string.format("LevelUp\\Configs\\%s\\%s.json", self.title, name), httpservice:JSONEncode(flags))
end

function library:addsettings()
    local settings = self:addtab("Settings")
    
	local uiSettings = settings:addcard("Ui", false)
    local configs = settings:addcard("Configs",true)
	local server = settings:addcard("Server", true)

    configs:adddropdown({ title = "Config List", ignore = true, flag = "configlist", items = self:getconfigs(), callback = function(value)
        self.items.configname:set(value)
    end })
    configs:addtextfield({ title = "Config Name", ignore = true, flag = "configname" })
    configs:addbutton({ title = "Load Config", flag = "loadconfig", callback = function()
        self:loadconfig(self.flags.configname)
    end })
    configs:addbutton({ title = "Save Config", flag = "saveconfig", callback = function()
        self:saveconfig(self.flags.configname)
		self.items.refreshconfiglist.callback()
    end })
	configs:addbutton({ title = "Refresh Config List", flag = "refreshconfiglist", callback = function()
        self.items.configlist:clear()
		local configs = self:getconfigs()
		for i = 1, #configs do
			self.items.configlist:add(configs[i])
		end
    end })

	server:adddropdown({ title = "Server Type", flag = "servertype", items = { "Most Players", "Least Players" }, callback = function(value)

	end })
	 
	server:addbutton({ title = "Hop Server", flag = "serverhop", callback = function()

	end })
	
	server:addcheckbox({ title = "Anti Afk", flag = "anti afk", callback = function(state)
		if state then
			game:GetService("Players").LocalPlayer.Idled:connect(function()
				local virtualuser = game:GetService("VirtualUser")
				virtualuser:CaptureController()
				virtualuser:ClickButton2(Vector2.new())
			end)
		end
	end })
    
    uiSettings:addslider({ min=1,max=15, title = "Rainbow Speed", flag = "rainbowSpeed", suffix = "", callback = function(x)rainbowSpeed = 16-x end })
    return settings
end
uis.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode.Name == "RightShift" then 
        library.gui.main.Visible = not library.gui.main.Visible
	end
end)  

return library
