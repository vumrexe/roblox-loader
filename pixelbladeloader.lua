local loader = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/vumrexe/roblox-loader/main/pixelbladeloader.lua"))()'

if queue_on_teleport then
    queue_on_teleport(loader)
end

loadstring(game:HttpGet("https://qweenhub.netlify.app/loader/pixelblade.lua"))()
