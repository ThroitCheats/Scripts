local fastflag = getfflag and getfflag('DebugRunParallelLuaOnMainThread');
local transfer = [[getgenv().script_key = "]]..getgenv().script_key..'"\n'

if run_on_actor and getactors and (getactors()[1] or game.Players.LocalPlayer.PlayerScripts:FindFirstChildWhichIsA("Actor")) then
    run_on_actor(getactors()[1] or game.Players.LocalPlayer.PlayerScripts:FindFirstChildWhichIsA("Actor"),transfer..[[
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/b0de7c4d81201b8837309655e4de6db7.lua"))()
    ]])
elseif tostring(string.lower(fastflag)) == "true" then 
    script_key = getgenv().script_key
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/b0de7c4d81201b8837309655e4de6db7.lua"))()
end
