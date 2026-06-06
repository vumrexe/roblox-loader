-- 1. CRASH PROTECTION: Wait for the game to fully load before doing anything
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(5) -- Safe cushion time for character physics to settle down

-- Rejoin queue persistence (auto-runs on next server)
local loader = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/vumrexe/roblox-loader/main/pixelbladeloader.lua"))()'

if queue_on_teleport then
    queue_on_teleport(loader)
end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Automatically active on launch
local isFarming = true
local holdDuration = 0.5 

-- ALL YOUR COORDINATES (With Image Corrections)
local locations = {
    -- --- FIRST IMAGE COORDINATES ---
    Vector3.new(1018.21, 56.67, -209.44),
    Vector3.new(1071.09, 54.91, -209.44),
    Vector3.new(1052.93, 63.67, -146.07),
    Vector3.new(1015.05, 63.67, -157.23),
    Vector3.new(972.14, 76.85, -158.37),
    Vector3.new(952.04, 71.79, -242.24),
    Vector3.new(919.15, 76.85, -159.94),
    Vector3.new(951.52, 201.50, -107.49),
    Vector3.new(750.44, 170.34, -132.99),
    Vector3.new(742.49, 148.50, -161.70),
    Vector3.new(761.72, 149.47, -286.10),
    Vector3.new(735.41, 101.89, -287.23),
    Vector3.new(684.74, 64.05, -287.04),
    Vector3.new(398.15, 106.50, -3.45),
    Vector3.new(173.22, 154.18, 44.29),
    Vector3.new(-15.02, 82.86, -31.10),
    Vector3.new(-46.34, 149.86, -48.67),
    Vector3.new(169.21, 133.90, -340.14),
    Vector3.new(1.00, 80.80, -284.77),
    Vector3.new(-186.54, 57.23, -310.07),
    Vector3.new(-457.46, 54.20, -728.41),
    Vector3.new(-598.84, 54.28, -555.69),
    Vector3.new(-801.30, 55.42, -505.09),
    Vector3.new(-991.18, 53.80, -542.98),
    Vector3.new(-1120.64, 74.53, -1185.00),
    Vector3.new(-1155.18, 73.28, -1277.87),
    Vector3.new(-661.62, 76.69, -910.18),
    Vector3.new(-713.68, 68.62, -871.95),
    Vector3.new(-1437.72, 54.85, -504.94),
    Vector3.new(-1634.18, 83.59, -467.57), -- CORRECTED POINT FROM IMAGE 3
    Vector3.new(-1496.71, 57.37, -316.70),
    Vector3.new(-1434.27, 56.55, -177.59),
    Vector3.new(-1693.16, 62.49, -138.77),
    Vector3.new(-1765.35, 119.63, -393.18),
    Vector3.new(-1692.01, 62.49, -138.06),
    Vector3.new(-1938.00, 75.26, -29.66),
    Vector3.new(-1935.41, 170.97, -418.69),
    Vector3.new(-1850.01, 82.94, -485.79),
    Vector3.new(-2017.57, 168.49, -431.34),
    Vector3.new(-2053.96, 168.06, -422.76),
    Vector3.new(-2138.80, 53.04, -432.00),
    Vector3.new(-2152.67, 52.50, -373.43),
    Vector3.new(-2123.63, 148.57, -222.43),
    Vector3.new(-1311.02, 59.24, 449.54),
    Vector3.new(-1247.40, 59.24, 488.26),
    Vector3.new(-793.84, 50.36, 820.53),
    Vector3.new(-840.63, 50.36, 790.61),
    Vector3.new(-821.49, 50.47, 852.75),
    Vector3.new(-834.00, 50.47, 882.60),
    Vector3.new(-650.62, 50.47, 800.69),

    -- --- SECOND IMAGE COORDINATES ---
    Vector3.new(-2621.20, 51.16, -2227.69),
    Vector3.new(-2482.85, 163.08, -2159.14),
    Vector3.new(-2421.59, 167.79, -2179.54),
    Vector3.new(-2367.62, 171.26, -2218.78),
    Vector3.new(-2444.48, 67.07, -2414.26),
    Vector3.new(-2398.10, 200.92, -2527.54),
    Vector3.new(-2322.92, 191.09, -2552.69),
    Vector3.new(-2262.09, 177.41, -2546.52),
    Vector3.new(-2599.91, 157.95, -2719.82),
    Vector3.new(-3063.68, 175.41, -2448.11),
    Vector3.new(-3049.69, 52.52, -2425.85),
    Vector3.new(-2959.03, 353.63, -2132.21),
    Vector3.new(-2998.69, 296.44, -2179.37),
    Vector3.new(-2941.30, 341.33, -2062.68),
    Vector3.new(-2868.74, 357.27, -2240.92),
    Vector3.new(-2709.81, 426.07, -2104.79),
    Vector3.new(-2664.34, 359.84, -2080.12),
    Vector3.new(-2635.84, 390.47, -2135.64),
    Vector3.new(-2630.32, 335.74, -3065.23),
    Vector3.new(-2541.88, 351.91, -3017.52)
}

-- Proximity prompt identifier
local function getPromptAtPosition(position)
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local parent = desc.Parent
            if parent and parent:IsA("BasePart") then
                local distance = (parent.Position - position).Magnitude
                if distance < 10 then 
                    return desc
                end
            end
        end
    end
    return nil
end

-- Main automated loop execution
local function runFarmLoop()
    while isFarming do
        for i, targetPos in ipairs(locations) do
            if not isFarming then break end
            
            if not rootPart or not rootPart.Parent then
                character = player.Character or player.CharacterAdded:Wait()
                rootPart = character:WaitForChild("HumanoidRootPart")
            end
            
            rootPart.CFrame = CFrame.new(targetPos) * CFrame.new(0, 3, 0)
            task.wait(0.3) 
            
            if not isFarming then break end
            
            local prompt = getPromptAtPosition(targetPos)
            if prompt then
                prompt:InputHoldBegin()
                task.wait(holdDuration)
                prompt:InputHoldEnd()
                task.wait(0.2)
            end
        end
        task.wait(1) 
    end
end

-- Safe Server Hopper (filters out full servers completely)
local function serverHop()
    isFarming = false
    print("[FARM] 2 minutes complete. Fetching empty server list...")
    
    local proxyUrl = "https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(proxyUrl))
    end)
    
    if success and result and result.data then
        local safeServers = {}
        for _, server in ipairs(result.data) do
            -- Buffer Check: Must leave at least 3 open slots to avoid GameFull kicks
            if server.id ~= game.JobId and server.playing < (server.maxPlayers - 3) then
                table.insert(safeServers, server)
            end
        end
        
        if #safeServers > 0 then
            -- Randomly pick a safe server from the list so we don't follow other exploiters
            local chosenServer = safeServers[math.random(1, #safeServers)]
            print("[FARM] Found safe server with space. Teleporting...")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, chosenServer.id, player)
            return
        end
    end
    
    print("[FARM] Proxy list failed or no safe servers found. Using backup matchmaking...")
    TeleportService:Teleport(game.PlaceId, player)
end

-- ANTI-KICK CORE: If a teleport fails, instantly find another server instead of disconnecting
TeleportService.TeleportInitFailed:Connect(function(failedPlayer, teleportResult, errorMessage)
    print("[FARM] Teleport failed: " .. tostring(errorMessage) .. ". Searching for a different server...")
    task.wait(3)
    serverHop()
end)

-- 2-Minute (120 seconds) Countdown to hop
task.delay(120, serverHop)

-- Ignite loop instantly on run
task.spawn(runFarmLoop)
