local loader = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/vumrexe/roblox-loader/main/pixelbladeloader.lua"))()'

if queue_on_teleport then
    queue_on_teleport(loader)
end

-- Auto Rejoin Logic
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

GuiService.ErrorMessageChanged:Connect(function()
    task.wait(5)
    TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

loadstring(game:HttpGet("https://qweenhub.netlify.app/loader/pixelblade.lua"))()
