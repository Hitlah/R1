repeat task.wait() until game:IsLoaded()

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local LOBBY_PLACEID = 12886143095
local isInLobby = game.PlaceId == LOBBY_PLACEID

-- Initialize global variables
getgenv().AutoEventEnabled = false
getgenv().AutoAbilitiesEnabled = false
getgenv().CardSelectionEnabled = false
getgenv().BossRushEnabled = false
getgenv().WebhookEnabled = false
getgenv().SeamlessLimiterEnabled = false
getgenv().BingoEnabled = false
getgenv().CapsuleEnabled = false
getgenv().RemoveEnemiesEnabled = false
getgenv().AntiAFKEnabled = false
getgenv().BlackScreenEnabled = false
getgenv().FPSBoostEnabled = false
getgenv().WebhookURL = ""
getgenv().MaxSeamlessRounds = 4
getgenv().UnitAbilities = {}

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "ALS Halloween Event",
    Author = "Anime Last Stand Script",
    Folder = "ALSHalloweenEvent",
    
    OpenButton = {
        Title = "Open ALS Hub",
        CornerRadius = UDim.new(0.5, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new(
            Color3.fromHex("#FF6B35"),
            Color3.fromHex("#F7931E")
        )
    }
})

-- Card Priority Tables
local CandyCards = {
    ["Weakened Resolve I"] = 13,
    ["Weakened Resolve II"] = 11,
    ["Weakened Resolve III"] = 4,
    ["Fog of War I"] = 12,
    ["Fog of War II"] = 10,
    ["Fog of War III"] = 5,
    ["Lingering Fear I"] = 6,
    ["Lingering Fear II"] = 2,
    ["Power Reversal I"] = 14,
    ["Power Reversal II"] = 9,
    ["Greedy Vampire's"] = 8,
    ["Hellish Gravity"] = 3,
    ["Deadly Striker"] = 7,
    ["Critical Denial"] = 1,
    ["Trick or Treat Coin Flip"] = 15
}

local DevilSacrifice = {
    ["Devil's Sacrifice"] = 999
}

local OtherCards = {
    ["Bullet Breaker I"] = 999,
    ["Bullet Breaker II"] = 999,
    ["Bullet Breaker III"] = 999,
    ["Hell Merchant I"] = 999,
    ["Hell Merchant II"] = 999,
    ["Hell Merchant III"] = 999,
    ["Hellish Warp I"] = 999,
    ["Hellish Warp II"] = 999,
    ["Fiery Surge I"] = 999,
    ["Fiery Surge II"] = 999,
    ["Grevious Wounds I"] = 999,
    ["Grevious Wounds II"] = 999,
    ["Scorching Hell I"] = 999,
    ["Scorching Hell II"] = 999,
    ["Fortune Flow"] = 999,
    ["Soul Link"] = 999
}

getgenv().CardPriority = {}
for name, priority in pairs(CandyCards) do getgenv().CardPriority[name] = priority end
for name, priority in pairs(DevilSacrifice) do getgenv().CardPriority[name] = priority end
for name, priority in pairs(OtherCards) do getgenv().CardPriority[name] = priority end

local BossRushGeneral = {
    ["Metal Skin"] = 0,
    ["Raging Power"] = 0,
    ["Demon Takeover"] = 0,
    ["Fortune"] = 0,
    ["Chaos Eater"] = 0,
    ["Godspeed"] = 0,
    ["Insanity"] = 0,
    ["Feeding Madness"] = 0,
    ["Emotional Damage"] = 0
}

getgenv().BossRushCardPriority = {}
for name, priority in pairs(BossRushGeneral) do getgenv().BossRushCardPriority[name] = priority end

-- Create Sections
local WelcomeSection = Window:Section({
    Title = "Update/Change",
    Icon = "home"
})

local MainSection = Window:Section({
    Title = "Main Features",
    Icon = "zap"
})

local AutomationSection = Window:Section({
    Title = "Automation",
    Icon = "bot"
})

local MiscSection = Window:Section({
    Title = "Miscellaneous",
    Icon = "sliders"
})

-- What's New Tab
local WhatsNewTab = WelcomeSection:Tab({
    Title = "What's New?",
    Icon = "sparkles"
})

WhatsNewTab:Section({
    Title = "What's New?",
    TextSize = 24,
})

WhatsNewTab:Section({
    Title = "Change Log",
    TextSize = 20,
})

WhatsNewTab:Section({
    Title = [[Test
- Added Sucking My Dick
]],
    TextSize = 14,
})

-- Auto Event Tab
local AutoEventTab = MainSection:Tab({
    Title = "Auto Event",
    Icon = "calendar"
})

AutoEventTab:Section({
    Title = "Halloween 2025 Event Auto Join",
    TextSize = 18,
})

AutoEventTab:Toggle({
    Flag = "AutoEventToggle",
    Title = "Enable Auto Event Join",
    Desc = "Automatically join and start the event",
    Default = false,
    Callback = function(state)
        getgenv().AutoEventEnabled = state
        WindUI:Notify({
            Title = "Auto Event",
            Content = state and "Auto event join enabled!" or "Auto event join disabled!",
            Icon = state and "check" or "x"
        })
    end
})

-- Auto Ability Tab
local AutoAbilityTab = MainSection:Tab({
    Title = "Auto Ability",
    Icon = "bot"
})

AutoAbilityTab:Section({
    Title = "Auto Ability System",
    TextSize = 18,
})

AutoAbilityTab:Toggle({
    Flag = "AutoAbilityToggle",
    Title = "Enable Auto Abilities",
    Desc = "Toggle automatic ability usage",
    Default = false,
    Callback = function(state)
        getgenv().AutoAbilitiesEnabled = state
        WindUI:Notify({
            Title = "Auto Ability",
            Content = state and "Auto abilities enabled!" or "Auto abilities disabled!",
            Icon = state and "check" or "x"
        })
    end
})

-- Helper Functions
local function getClientData()
    local success, clientData = pcall(function()
        local modulePath = RS:WaitForChild("Modules"):WaitForChild("ClientData")
        if modulePath and modulePath:IsA("ModuleScript") then
            return require(modulePath)
        end
        return nil
    end)
    return success and clientData or nil
end

local function getTowerInfo(unitName)
    local success, towerData = pcall(function()
        local towerInfoPath = RS:WaitForChild("Modules"):WaitForChild("TowerInfo")
        local towerModule = towerInfoPath:FindFirstChild(unitName)
        if towerModule and towerModule:IsA("ModuleScript") then
            return require(towerModule)
        end
        return nil
    end)
    return success and towerData or nil
end

local function getAllAbilities(unitName)
    local towerNameToCheck = unitName
    if unitName == "TuskSummon_Act4" then
        towerNameToCheck = "JohnnyGodly"
    end
    
    local towerInfo = getTowerInfo(towerNameToCheck)
    if not towerInfo then return {} end
    
    local abilities = {}
    
    for level = 0, 50 do
        if towerInfo[level] then
            if towerInfo[level].Ability then
                local abilityData = towerInfo[level].Ability
                local abilityName = abilityData.Name
                
                if not abilities[abilityName] then
                    abilities[abilityName] = {
                        name = abilityName,
                        cooldown = abilityData.Cd,
                        requiredLevel = level,
                        isGlobal = abilityData.IsCdGlobal or false,
                        isAttribute = abilityData.AttributeRequired or false
                    }
                end
            end
            
            if towerInfo[level].Abilities then
                for _, abilityData in pairs(towerInfo[level].Abilities) do
                    local abilityName = abilityData.Name
                    
                    if not abilities[abilityName] then
                        abilities[abilityName] = {
                            name = abilityName,
                            cooldown = abilityData.Cd,
                            requiredLevel = level,
                            isGlobal = abilityData.IsCdGlobal or false,
                            isAttribute = abilityData.AttributeRequired or false
                        }
                    end
                end
            end
        end
    end
    
    return abilities
end

local function buildAutoAbilityUI()
    local clientData = getClientData()
    if not clientData or not clientData.Slots then
        return
    end
    
    local sortedSlots = {"Slot1", "Slot2", "Slot3", "Slot4", "Slot5", "Slot6"}
    
    for _, slotName in ipairs(sortedSlots) do
        local slotData = clientData.Slots[slotName]
        if slotData then
            local unitName = slotData.Value
            if unitName then
                local abilities = getAllAbilities(unitName)
                
                if next(abilities) then
                    AutoAbilityTab:Section({
                        Title = unitName .. " - " .. slotName .. " (Level " .. (slotData.Level or 0) .. ")",
                        TextSize = 16,
                    })
                    
                    if not getgenv().UnitAbilities[unitName] then
                        getgenv().UnitAbilities[unitName] = {}
                    end
                    
                    local sortedAbilities = {}
                    for abilityName, abilityData in pairs(abilities) do
                        table.insert(sortedAbilities, {name = abilityName, data = abilityData})
                    end
                    table.sort(sortedAbilities, function(a, b)
                        return a.data.requiredLevel < b.data.requiredLevel
                    end)
                    
                    for _, abilityInfo in ipairs(sortedAbilities) do
                        local abilityName = abilityInfo.name
                        local abilityData = abilityInfo.data
                        
                        if not getgenv().UnitAbilities[unitName][abilityName] then
                            getgenv().UnitAbilities[unitName][abilityName] = {
                                enabled = false,
                                onlyOnBoss = false,
                                specificWave = nil,
                                requireBossInRange = false,
                                delayAfterBossSpawn = false,
                                useOnWave = false
                            }
                        end
                        
                        local abilityConfig = getgenv().UnitAbilities[unitName][abilityName]
                        
                        AutoAbilityTab:Toggle({
                            Flag = unitName .. "_" .. abilityName .. "_Toggle",
                            Title = abilityName,
                            Desc = "Lvl " .. abilityData.requiredLevel .. " | CD: " .. abilityData.cooldown .. "s" .. (abilityData.isAttribute and " | Requires Attribute" or ""),
                            Default = false,
                            Callback = function(state)
                                abilityConfig.enabled = state
                            end
                        })
                        
                        AutoAbilityTab:Input({
                            Flag = unitName .. "_" .. abilityName .. "_Wave",
                            Title = "    Wave Number",
                            Placeholder = "Enter wave (only used if 'On Wave' selected)",
                            Callback = function(value)
                                local num = tonumber(value)
                                abilityConfig.specificWave = num
                            end
                        })
                        
                        AutoAbilityTab:Dropdown({
                            Flag = unitName .. "_" .. abilityName .. "_Modifiers",
                            Title = "  Conditions",
                            Desc = "Optional modifiers",
                            Values = {"Only On Boss", "Boss In Range", "Delay After Boss Spawn", "On Wave"},
                            Multi = true,
                            Callback = function(values)
                                abilityConfig.onlyOnBoss = table.find(values, "Only On Boss") ~= nil
                                abilityConfig.requireBossInRange = table.find(values, "Boss In Range") ~= nil
                                abilityConfig.delayAfterBossSpawn = table.find(values, "Delay After Boss Spawn") ~= nil
                                abilityConfig.useOnWave = table.find(values, "On Wave") ~= nil
                            end
                        })
                        
                        AutoAbilityTab:Space()
                    end
                end
            end
        end
    end
end

task.spawn(function()
    task.wait(1)
    
    local maxRetries = 10
    local retryDelay = 3
    local success = false
    
    for attempt = 1, maxRetries do
        local clientData = getClientData()
        if clientData and clientData.Slots then
            buildAutoAbilityUI()
            success = true
            break
        else
            if attempt < maxRetries then
                WindUI:Notify({
                    Title = "Auto Ability",
                    Content = "ClientData loading failed, retrying... (" .. attempt .. "/" .. maxRetries .. ")",
                    Icon = "alert-circle"
                })
                task.wait(retryDelay)
            end
        end
    end
    
    if not success then
        AutoAbilityTab:Section({
            Title = "❌ Failed to Load Units",
            TextSize = 16,
        })
    end
end)

-- Card Selection Tab
local CardSelectionTab = AutomationSection:Tab({
    Title = "Card Selection",
    Icon = "layers"
})

CardSelectionTab:Section({
    Title = "Card Priority System",
    TextSize = 18,
})

CardSelectionTab:Toggle({
    Flag = "CardSelectionToggle",
    Title = "Enable Card Selection",
    Desc = "Automatically select cards based on priority",
    Default = false,
    Callback = function(state)
        getgenv().CardSelectionEnabled = state
        WindUI:Notify({
            Title = "Card Selection",
            Content = state and "Card selection enabled!" or "Card selection disabled!",
            Icon = state and "check" or "x"
        })
    end
})

CardSelectionTab:Section({
    Title = "━━━━━ Candy Cards ━━━━━",
    TextSize = 16,
})

local candyCardNames = {}
for cardName, _ in pairs(CandyCards) do
    table.insert(candyCardNames, cardName)
end
table.sort(candyCardNames, function(a, b)
    return CandyCards[a] < CandyCards[b]
end)

for _, cardName in ipairs(candyCardNames) do
    CardSelectionTab:Input({
        Flag = "Card_" .. cardName,
        Title = cardName,
        Value = tostring(CandyCards[cardName]),
        Placeholder = "Priority (1-999)",
        Callback = function(value)
            local num = tonumber(value)
            if num then
                getgenv().CardPriority[cardName] = num
            end
        end
    })
end

CardSelectionTab:Section({
    Title = "━━━━━ Devil's Sacrifice ━━━━━",
    TextSize = 16,
})

for cardName, priority in pairs(DevilSacrifice) do
    CardSelectionTab:Input({
        Flag = "Card_" .. cardName,
        Title = cardName,
        Value = tostring(priority),
        Placeholder = "Priority (1-999)",
        Callback = function(value)
            local num = tonumber(value)
            if num then
                getgenv().CardPriority[cardName] = num
            end
        end
    })
end

CardSelectionTab:Section({
    Title = "━━━━━ Other Cards ━━━━━",
    TextSize = 16,
})

local otherCardNames = {}
for cardName, _ in pairs(OtherCards) do
    table.insert(otherCardNames, cardName)
end
table.sort(otherCardNames)

for _, cardName in ipairs(otherCardNames) do
    CardSelectionTab:Input({
        Flag = "Card_" .. cardName,
        Title = cardName,
        Value = tostring(OtherCards[cardName]),
        Placeholder = "Priority (1-999)",
        Callback = function(value)
            local num = tonumber(value)
            if num then
                getgenv().CardPriority[cardName] = num
            end
        end
    })
end

-- Boss Rush Tab
local BossRushTab = AutomationSection:Tab({
    Title = "Boss Rush",
    Icon = "trophy"
})

BossRushTab:Section({
    Title = "Boss Rush Card System",
    TextSize = 18,
})

BossRushTab:Toggle({
    Flag = "BossRushToggle",
    Title = "Enable Boss Rush Cards",
    Desc = "Auto-select Boss Rush cards by priority",
    Default = false,
    Callback = function(state)
        getgenv().BossRushEnabled = state
        WindUI:Notify({
            Title = "Boss Rush",
            Content = state and "Boss Rush card selection enabled!" or "Boss Rush card selection disabled!",
            Icon = state and "check" or "x"
        })
    end
})

BossRushTab:Section({
    Title = "━━━━━ Boss Rush Cards ━━━━━",
    TextSize = 16,
})

local bossRushCardNames = {}
for cardName, _ in pairs(BossRushGeneral) do
    table.insert(bossRushCardNames, cardName)
end
table.sort(bossRushCardNames)

for _, cardName in ipairs(bossRushCardNames) do
    BossRushTab:Input({
        Flag = "BossRush_" .. cardName,
        Title = cardName,
        Value = tostring(BossRushGeneral[cardName]),
        Placeholder = "Priority (1-999)",
        Callback = function(value)
            local num = tonumber(value)
            if num then
                getgenv().BossRushCardPriority[cardName] = num
            end
        end
    })
end

-- Webhook Tab
local WebhookTab = AutomationSection:Tab({
    Title = "Webhook",
    Icon = "send"
})

WebhookTab:Section({
    Title = "Discord Webhook Integration",
    TextSize = 18,
})

WebhookTab:Input({
    Flag = "WebhookURL",
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(value)
        getgenv().WebhookURL = value
    end
})

WebhookTab:Toggle({
    Flag = "WebhookToggle",
    Title = "Enable Webhook",
    Desc = "Send match results to Discord",
    Default = false,
    Callback = function(state)
        getgenv().WebhookEnabled = state
        if state then
            if getgenv().WebhookURL == "" or not string.match(getgenv().WebhookURL, "^https://discord%.com/api/webhooks/") then
                WindUI:Notify({
                    Title = "Webhook Error",
                    Content = "Please enter a valid webhook URL first!",
                    Icon = "alert-triangle"
                })
                getgenv().WebhookEnabled = false
            else
                WindUI:Notify({
                    Title = "Webhook",
                    Content = "Webhook enabled!",
                    Icon = "check"
                })
            end
        else
            WindUI:Notify({
                Title = "Webhook",
                Content = "Webhook disabled!",
                Icon = "x"
            })
        end
    end
})

-- Seamless Fix Tab
local SeamlessTab = AutomationSection:Tab({
    Title = "Seamless Fix",
    Icon = "refresh-cw"
})

SeamlessTab:Section({
    Title = "Seamless Retry Bug Fix",
    TextSize = 18,
})

SeamlessTab:Input({
    Flag = "SeamlessRounds",
    Title = "Maximum Rounds",
    Value = "4",
    Placeholder = "Number of rounds (default: 4)",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            getgenv().MaxSeamlessRounds = num
        else
            getgenv().MaxSeamlessRounds = 4
        end
    end
})

SeamlessTab:Toggle({
    Flag = "SeamlessToggle",
    Title = "Enable Seamless Bug Fix",
    Desc = "Limit seamless retry to configured rounds",
    Default = false,
    Callback = function(state)
        getgenv().SeamlessLimiterEnabled = state
        WindUI:Notify({
            Title = "Seamless Fix",
            Content = state and "Seamless bug fix enabled!" or "Seamless bug fix disabled!",
            Icon = state and "check" or "x"
        })
    end
})

-- Event Tab (Only if not in lobby)
if not isInLobby then
    local EventTab = MainSection:Tab({
        Title = "Event",
        Icon = "grid"
    })
    
    EventTab:Section({
        Title = "Halloween 2025 Event Automation",
        TextSize = 18,
    })
    
    EventTab:Section({
        Title = "━━━━━ Auto Bingo ━━━━━",
        TextSize = 16,
    })
    
    EventTab:Toggle({
        Flag = "BingoToggle",
        Title = "Enable Auto Bingo",
        Desc = "Automatically manage bingo stamps and rewards",
        Default = false,
        Callback = function(state)
            getgenv().BingoEnabled = state
            WindUI:Notify({
                Title = "Auto Bingo",
                Content = state and "Auto bingo enabled!" or "Auto bingo disabled!",
                Icon = state and "check" or "x"
            })
        end
    })
    
    EventTab:Section({
        Title = "━━━━━ Auto Capsules ━━━━━",
        TextSize = 16,
    })
    
    EventTab:Toggle({
        Flag = "CapsuleToggle",
        Title = "Enable Auto Capsules",
        Desc = "Auto-buy and auto-open Halloween capsules",
        Default = false,
        Callback = function(state)
            getgenv().CapsuleEnabled = state
            WindUI:Notify({
                Title = "Auto Capsules",
                Content = state and "Auto capsules enabled!" or "Auto capsules disabled!",
                Icon = state and "check" or "x"
            })
        end
    })
end

-- Misc Tab
local MiscTab = MiscSection:Tab({
    Title = "Miscellaneous",
    Icon = "sliders"
})

MiscTab:Section({
    Title = "Miscellaneous Features",
    TextSize = 18,
})

MiscTab:Toggle({
    Flag = "RemoveEnemiesToggle",
    Title = "Remove Enemies/SpawnedUnits",
    Desc = "Deletes all non-boss enemies and spawned units",
    Default = false,
    Callback = function(state)
        getgenv().RemoveEnemiesEnabled = state
        WindUI:Notify({
            Title = "Remove Enemies",
            Content = state and "Remove enemies enabled!" or "Remove enemies disabled!",
            Icon = state and "check" or "x"
        })
    end
})

if not isInLobby then
    MiscTab:Toggle({
        Flag = "FPSBoostToggle",
        Title = "FPS Boost",
        Desc = "Removes lighting, textures, and non-model objects",
        Default = false,
        Callback = function(state)
            getgenv().FPSBoostEnabled = state
            WindUI:Notify({
                Title = "FPS Boost",
                Content = state and "Optimization enabled!" or "Optimization disabled!",
                Icon = state and "check" or "x"
            })
        end
    })
end

MiscTab:Toggle({
    Flag = "AntiAFKToggle",
    Title = "Anti-AFK",
    Desc = "Prevents being kicked for inactivity",
    Default = false,
    Callback = function(state)
        getgenv().AntiAFKEnabled = state
        WindUI:Notify({
            Title = "Anti-AFK",
            Content = state and "Anti-AFK enabled!" or "Anti-AFK disabled!",
            Icon = state and "check" or "x"
        })
    end
})

MiscTab:Toggle({
    Flag = "BlackScreenToggle",
    Title = "Black Screen",
    Desc = "Covers screen with black overlay and disables rendering",
    Default = false,
    Callback = function(state)
        getgenv().BlackScreenEnabled = state
        WindUI:Notify({
            Title = "Black Screen",
            Content = state and "Black screen enabled!" or "Black screen disabled!",
            Icon = state and "check" or "x"
        })
    end
})

-- Show success notification
WindUI:Notify({
    Title = "ALS Halloween Event",
    Content = "Script loaded successfully!",
    Icon = "check"
})

-- Auto Rejoin System
task.spawn(function()
    repeat task.wait() until game.CoreGui:FindFirstChild("RobloxPromptGui")
    
    local TeleportService = game:GetService("TeleportService")
    local promptOverlay = game.CoreGui.RobloxPromptGui.promptOverlay
    
    promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            print("[Auto Rejoin] Disconnect detected! Attempting to rejoin...")
            spawn(function()
                while true do
                    local success = pcall(function()
                        TeleportService:Teleport(12886143095, Players.LocalPlayer)
                    end)
                    if success then
                        print("[Auto Rejoin] Rejoining...")
                        break
                    else
                        print("[Auto Rejoin] Rejoin failed, retrying in 2 seconds...")
                        task.wait(2)
                    end
                end
            end)
        end
    end)
    
    print("[Auto Rejoin] Auto rejoin system loaded!")
end)

-- Anti-AFK System
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        if getgenv().AntiAFKEnabled then
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end
    end)
    
    print("[Anti-AFK] Anti-AFK system loaded!")
end)

-- Black Screen System
task.spawn(function()
    local blackScreenGui = nil
    local blackFrame = nil
    
    local function createBlackScreen()
        if blackScreenGui then return end
        
        blackScreenGui = Instance.new("ScreenGui")
        blackScreenGui.Name = "BlackScreenOverlay"
        blackScreenGui.DisplayOrder = -999999
        blackScreenGui.IgnoreGuiInset = true
        blackScreenGui.ResetOnSpawn = false
        
        blackFrame = Instance.new("Frame")
        blackFrame.Size = UDim2.new(1, 0, 1, 0)
        blackFrame.Position = UDim2.new(0, 0, 0, 0)
        blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
        blackFrame.BorderSizePixel = 0
        blackFrame.ZIndex = -999999
        blackFrame.Parent = blackScreenGui
        
        pcall(function()
            blackScreenGui.Parent = LocalPlayer.PlayerGui
        end)
        
        pcall(function()
            local workspace = game:GetService("Workspace")
            if workspace.CurrentCamera then
                workspace.CurrentCamera.MaxAxisFieldOfView = 0.001
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    end
    
    local function removeBlackScreen()
        if blackScreenGui then
            blackScreenGui:Destroy()
            blackScreenGui = nil
            blackFrame = nil
        end
        
        pcall(function()
            local workspace = game:GetService("Workspace")
            if workspace.CurrentCamera then
                workspace.CurrentCamera.MaxAxisFieldOfView = 70
            end
        end)
    end
    
    while true do
        task.wait(0.5)
        
        if getgenv().BlackScreenEnabled then
            if not blackScreenGui then
                createBlackScreen()
            end
        else
            if blackScreenGui then
                removeBlackScreen()
            end
        end
    end
end)

-- Remove Enemies System
task.spawn(function()
    while true do
        task.wait(0.1)
        
        if getgenv().RemoveEnemiesEnabled then
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    if enemy:IsA("Model") and enemy.Name ~= "Boss" then
                        pcall(function()
                            enemy:Destroy()
                        end)
                    end
                end
            end
            local spawnedunits = workspace:FindFirstChild("SpawnedUnits")
            if spawnedunits then
                for _, spawnedunit in pairs(spawnedunits:GetChildren()) do
                    if spawnedunit:IsA("Model") then
                        pcall(function()
                            spawnedunit:Destroy()
                        end)
                    end
                end
            end
        end
    end
end)

-- FPS Boost System
task.spawn(function()
    while true do
        task.wait(10)

        if not isInLobby and getgenv().FPSBoostEnabled then
            pcall(function()
                local lighting = game:GetService("Lighting")
                for _, child in ipairs(lighting:GetChildren()) do
                    child:Destroy()
                end
                lighting.Ambient = Color3.new(1, 1, 1)
                lighting.Brightness = 1
                lighting.GlobalShadows = false
                lighting.FogEnd = 100000
                lighting.FogStart = 100000
                lighting.ClockTime = 12
                lighting.GeographicLatitude = 0

                for _, obj in ipairs(game.Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("WedgePart") or obj:IsA("CornerWedgePart") then
                            obj.Material = Enum.Material.SmoothPlastic
                            if obj:FindFirstChildOfClass("Texture") then
                                for _, texture in ipairs(obj:GetChildren()) do
                                    if texture:IsA("Texture") then
                                        texture:Destroy()
                                    end
                                end
                            end
                            if obj:IsA("MeshPart") then
                                obj.TextureID = ""
                            end
                        end
                        if obj:IsA("Decal") then
                            obj:Destroy()
                        end
                    end
                    if obj:IsA("SurfaceAppearance") then
                        obj:Destroy()
                    end
                end

                local mapPath = game.Workspace:FindFirstChild("Map") and game.Workspace.Map:FindFirstChild("Map")
                if mapPath then
                    for _, child in ipairs(mapPath:GetChildren()) do
                        if not child:IsA("Model") then
                            child:Destroy()
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Event System
task.spawn(function()
    while true do
        task.wait(1)
        
        if getgenv().AutoEventEnabled then
            local eventsFolder = RS:FindFirstChild("Events")
            if eventsFolder then
                local halloweenFolder = eventsFolder:FindFirstChild("Hallowen2025")
                if halloweenFolder then
                    local enterEvent = halloweenFolder:FindFirstChild("Enter")
                    local startEvent = halloweenFolder:FindFirstChild("Start")
                    
                    if enterEvent and startEvent then
                        pcall(function()
                            enterEvent:FireServer()
                            task.wait(0.2)
                            startEvent:FireServer()
                        end)
                        print("[Auto Event] Joined and started Halloween event")
                    end
                end
            end
        end
    end
end)

-- Auto Ability System (Full implementation from original script)
task.spawn(function()
    local GAME_SPEED = 3
    local Towers = workspace.Towers
    local bossSpawnTime = nil
    local bossInRangeTracker = {}
    local abilityCooldowns = {}
    local towerInfoCache = {}
    local generalBossSpawnTime = nil
    local lastWave = 0
    
    local function resetRoundTrackers()
        bossSpawnTime = nil
        bossInRangeTracker = {}
        generalBossSpawnTime = nil
        abilityCooldowns = {}
    end
    
    local function getTowerInfoCached(towerName)
        if towerInfoCache[towerName] then return towerInfoCache[towerName] end
        local towerData = getTowerInfo(towerName)
        if towerData then
            towerInfoCache[towerName] = towerData
        end
        return towerData
    end
    
    local function getAbilityData(towerName, abilityName)
        local towerInfo = getTowerInfoCached(towerName)
        if not towerInfo then return nil end
        for level = 0, 50 do
            if towerInfo[level] then
                if towerInfo[level].Ability then
                    local abilityData = towerInfo[level].Ability
                    if abilityData.Name == abilityName then
                        return {
                            cooldown = abilityData.Cd,
                            requiredLevel = level,
                            isGlobal = abilityData.IsCdGlobal
                        }
                    end
                end
                if towerInfo[level].Abilities then
                    for _, abilityData in pairs(towerInfo[level].Abilities) do
                        if abilityData.Name == abilityName then
                            return {
                                cooldown = abilityData.Cd,
                                requiredLevel = level,
                                isGlobal = abilityData.IsCdGlobal
                            }
                        end
                    end
                end
            end
        end
        return nil
    end
    
    local function getCurrentWave()
        local ok, result = pcall(function()
            local gui = LocalPlayer.PlayerGui:FindFirstChild("Top")
            if not gui then return 0 end
            local frame = gui:FindFirstChild("Frame")
            if not frame then return 0 end
            frame = frame:FindFirstChild("Frame")
            if not frame then return 0 end
            frame = frame:FindFirstChild("Frame")
            if not frame then return 0 end
            frame = frame:FindFirstChild("Frame")
            if not frame then return 0 end
            local button = frame:FindFirstChild("TextButton")
            if not button then return 0 end
            local children = button:GetChildren()
            if #children < 3 then return 0 end
            local text = children[3].Text
            return tonumber(text) or 0
        end)
        return ok and result or 0
    end
    
    local function getTowerInfoName(tower)
        if not tower then return nil end
        local candidates = {
            tower:GetAttribute("TowerType"),
            tower:GetAttribute("Type"),
            tower:GetAttribute("TowerName"),
            tower:GetAttribute("BaseTower"),
            tower:FindFirstChild("TowerType") and tower.TowerType:IsA("ValueBase") and tower.TowerType.Value,
            tower:FindFirstChild("Type") and tower.Type:IsA("ValueBase") and tower.Type.Value,
            tower:FindFirstChild("TowerName") and tower.TowerName:IsA("ValueBase") and tower.TowerName.Value,
            tower.Name
        }
        for _, candidate in ipairs(candidates) do
            if candidate and type(candidate) == "string" and candidate ~= "" then
                return candidate
            end
        end
        return tower.Name
    end
    
    local function getTower(name)
        return Towers:FindFirstChild(name)
    end
    
    local function getUpgradeLevel(tower)
        if not tower then return 0 end
        local upgradeVal = tower:FindFirstChild("Upgrade")
        if upgradeVal and upgradeVal:IsA("ValueBase") then
            return upgradeVal.Value or 0
        end
        return 0
    end
    
    local function useAbility(tower, abilityName)
        if tower then
            pcall(function()
                local Event = RS.Remotes.Ability
                Event:InvokeServer(tower, abilityName)
            end)
        end
    end
    
    local function isOnCooldown(towerName, abilityName)
        local abilityData = getAbilityData(towerName, abilityName)
        if not abilityData or not abilityData.cooldown then return false end
        local key = towerName .. "_" .. abilityName
        local lastUsed = abilityCooldowns[key]
        if not lastUsed then return false end
        local adjustedCooldown = abilityData.cooldown / GAME_SPEED
        local elapsed = tick() - lastUsed
        return elapsed < adjustedCooldown
    end
    
    local function setAbilityUsed(towerName, abilityName)
        local key = towerName .. "_" .. abilityName
        abilityCooldowns[key] = tick()
    end
    
    local function hasAbilityBeenUnlocked(towerName, abilityName, towerLevel)
        local abilityData = getAbilityData(towerName, abilityName)
        if not abilityData then return false end
        return towerLevel >= abilityData.requiredLevel
    end
    
    local function bossExists()
        local ok, result = pcall(function()
            local enemies = workspace:FindFirstChild("Enemies")
            if not enemies then return false end
            return enemies:FindFirstChild("Boss") ~= nil
        end)
        return ok and result
    end
    
    local function bossReadyForAbilities()
        if bossExists() then
            if not generalBossSpawnTime then
                generalBossSpawnTime = tick()
            end
            local elapsed = tick() - generalBossSpawnTime
            return elapsed >= 1
        else
            generalBossSpawnTime = nil
            return false
        end
    end
    
    local function checkBossSpawnTime()
        if bossExists() then
            if not bossSpawnTime then
                bossSpawnTime = tick()
            end
            local elapsed = tick() - bossSpawnTime
            return elapsed >= 16
        else
            bossSpawnTime = nil
            return false
        end
    end
    
    local function getBossPosition()
        local ok, result = pcall(function()
            local enemies = workspace:FindFirstChild("Enemies")
            if not enemies then return nil end
            local boss = enemies:FindFirstChild("Boss")
            if not boss then return nil end
            local hrp = boss:FindFirstChild("HumanoidRootPart")
            if hrp then return hrp.Position end
            return nil
        end)
        return ok and result or nil
    end
    
    local function getTowerPosition(tower)
        if not tower then return nil end
        local ok, result = pcall(function()
            local hrp = tower:FindFirstChild("HumanoidRootPart")
            if hrp then return hrp.Position end
            return nil
        end)
        return ok and result or nil
    end
    
    local function getTowerRange(tower)
        if not tower then return 0 end
        local ok, result = pcall(function()
            local stats = tower:FindFirstChild("Stats")
            if not stats then return 0 end
            local range = stats:FindFirstChild("Range")
            if not range then return 0 end
            return range.Value or 0
        end)
        return ok and result or 0
    end
    
    local function isBossInRange(tower)
        local bossPos = getBossPosition()
        local towerPos = getTowerPosition(tower)
        if not bossPos or not towerPos then return false end
        local range = getTowerRange(tower)
        if range <= 0 then return false end
        local distance = (bossPos - towerPos).Magnitude
        return distance <= range
    end
    
    local function checkBossInRangeForDuration(tower, requiredDuration)
        if not tower then return false end
        local towerName = tower.Name
        local currentTime = tick()
        if isBossInRange(tower) then
            if requiredDuration == 0 then return true end
            if not bossInRangeTracker[towerName] then
                bossInRangeTracker[towerName] = currentTime
                return false
            else
                local timeInRange = currentTime - bossInRangeTracker[towerName]
                if timeInRange >= requiredDuration then return true end
            end
        else
            bossInRangeTracker[towerName] = nil
        end
        return false
    end
    
    while true do
        wait(0.5)
        
        if getgenv().AutoAbilitiesEnabled then
            local currentWave = getCurrentWave()
            local hasBoss = bossExists()
            
            if currentWave < lastWave then
                resetRoundTrackers()
                print("[Auto Ability] Round reset detected")
            end
            
            if getgenv().SeamlessLimiterEnabled and lastWave >= 50 and currentWave < 50 then
                resetRoundTrackers()
                print("[Auto Ability] Seamless mode new round detected")
            end
            
            lastWave = currentWave
            
            for unitName, abilitiesConfig in pairs(getgenv().UnitAbilities) do
                local tower = getTower(unitName)
                
                if tower then
                    local towerInfoName = getTowerInfoName(tower)
                    local towerLevel = getUpgradeLevel(tower)
                    
                    for abilityName, abilityConfig in pairs(abilitiesConfig) do
                        if abilityConfig.enabled then
                            local shouldUse = true
                            
                            if not hasAbilityBeenUnlocked(towerInfoName, abilityName, towerLevel) then
                                shouldUse = false
                            end
                            
                            if shouldUse and isOnCooldown(towerInfoName, abilityName) then
                                shouldUse = false
                            end
                            
                            if shouldUse then
                                if abilityConfig.onlyOnBoss then
                                    if not hasBoss then
                                        shouldUse = false
                                    elseif not bossReadyForAbilities() then
                                        shouldUse = false
                                    end
                                end
                                
                                if shouldUse and abilityConfig.useOnWave and abilityConfig.specificWave then
                                    if currentWave ~= abilityConfig.specificWave then
                                        shouldUse = false
                                    end
                                end
                                
                                if shouldUse and abilityConfig.requireBossInRange then
                                    if not hasBoss then
                                        shouldUse = false
                                    elseif not checkBossInRangeForDuration(tower, 0) then
                                        shouldUse = false
                                    end
                                end
                                
                                if shouldUse and abilityConfig.delayAfterBossSpawn then
                                    if not hasBoss then
                                        shouldUse = false
                                    elseif not checkBossSpawnTime() then
                                        shouldUse = false
                                    end
                                end
                            end
                            
                            if shouldUse then
                                useAbility(tower, abilityName)
                                setAbilityUsed(towerInfoName, abilityName)
                                print("[Auto Ability] ✓ Used " .. abilityName .. " on " .. unitName)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Card Selection System
task.spawn(function()
    local function getAvailableCards()
        local playerGui = LocalPlayer.PlayerGui
        local prompt = playerGui:FindFirstChild("Prompt")
        if not prompt then return nil end
        local frame = prompt:FindFirstChild("Frame")
        if not frame or not frame:FindFirstChild("Frame") then return nil end
        local cards = {}
        local cardButtons = {}
        for _, descendant in pairs(frame:GetDescendants()) do
            if descendant:IsA("TextLabel") and descendant.Parent and descendant.Parent:IsA("Frame") then
                local text = descendant.Text
                if getgenv().CardPriority[text] then
                    local button = descendant.Parent.Parent
                    if button:IsA("GuiButton") or button:IsA("TextButton") or button:IsA("ImageButton") then
                        table.insert(cardButtons, {text = text, button = button})
                    end
                end
            end
        end
        table.sort(cardButtons, function(a, b)
            return a.button.AbsolutePosition.X < b.button.AbsolutePosition.X
        end)
        for i, cardData in ipairs(cardButtons) do
            cards[i] = {name = cardData.text, button = cardData.button}
        end
        return #cards > 0 and cards or nil
    end
    
    local function findBestCard(availableCards)
        local bestIndex = 1
        local bestPriority = math.huge
        for cardIndex = 1, #availableCards do
            local cardData = availableCards[cardIndex]
            local cardName = cardData.name
            local priority = getgenv().CardPriority[cardName] or 999
            if priority < bestPriority then
                bestPriority = priority
                bestIndex = cardIndex
            end
        end
        return bestIndex, availableCards[bestIndex], bestPriority
    end
    
    local function pressConfirmButton()
        local ok, confirmButton = pcall(function()
            local prompt = LocalPlayer.PlayerGui:FindFirstChild("Prompt")
            if not prompt then return nil end
            local frame = prompt:FindFirstChild("Frame")
            if not frame then return nil end
            local innerFrame = frame:FindFirstChild("Frame")
            if not innerFrame then return nil end
            local children = innerFrame:GetChildren()
            if #children < 5 then return nil end
            local button = children[5]:FindFirstChild("TextButton")
            if not button then return nil end
            local label = button:FindFirstChild("TextLabel")
            if label and label.Text == "Confirm" then
                return button
            end
            return nil
        end)
        if ok and confirmButton then
            local events = {"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}
            for _, eventName in ipairs(events) do
                pcall(function()
                    for _, conn in ipairs(getconnections(confirmButton[eventName])) do
                        conn:Fire()
                    end
                end)
            end
            return true
        end
        return false
    end
    
    local function selectCard()
        if not getgenv().CardSelectionEnabled then return false end
        local availableCards = getAvailableCards()
        if not availableCards then return false end
        local bestCardIndex, bestCardData, bestPriority = findBestCard(availableCards)
        local buttonToClick = bestCardData.button
        local events = {"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}
        for _, eventName in ipairs(events) do
            pcall(function()
                for _, conn in ipairs(getconnections(buttonToClick[eventName])) do
                    conn:Fire()
                end
            end)
        end
        wait(0.2)
        pressConfirmButton()
        return true
    end
    
    while true do
        wait(1)
        if getgenv().CardSelectionEnabled then
            selectCard()
        end
    end
end)

-- Boss Rush Card Selection
task.spawn(function()
    local function getBossRushCards()
        local playerGui = LocalPlayer.PlayerGui
        local prompt = playerGui:FindFirstChild("Prompt")
        if not prompt then return nil end
        local frame = prompt:FindFirstChild("Frame")
        if not frame or not frame:FindFirstChild("Frame") then return nil end
        
        local cards = {}
        local cardButtons = {}
        
        for _, descendant in pairs(frame:GetDescendants()) do
            if descendant:IsA("TextLabel") and descendant.Parent and descendant.Parent:IsA("Frame") then
                local text = descendant.Text
                if getgenv().BossRushCardPriority[text] then
                    local button = descendant.Parent.Parent
                    if button:IsA("GuiButton") or button:IsA("TextButton") or button:IsA("ImageButton") then
                        table.insert(cardButtons, {text = text, button = button})
                    end
                end
            end
        end
        
        table.sort(cardButtons, function(a, b)
            return a.button.AbsolutePosition.X < b.button.AbsolutePosition.X
        end)
        
        for i, cardData in ipairs(cardButtons) do
            cards[i] = {name = cardData.text, button = cardData.button}
        end
        
        return #cards > 0 and cards or nil
    end
    
    local function findBestBossRushCard(availableCards)
        local bestIndex = 1
        local bestPriority = math.huge
        
        for cardIndex = 1, #availableCards do
            local cardData = availableCards[cardIndex]
            local cardName = cardData.name
            local priority = getgenv().BossRushCardPriority[cardName] or 999
            
            if priority < bestPriority then
                bestPriority = priority
                bestIndex = cardIndex
            end
        end
        
        return bestIndex, availableCards[bestIndex], bestPriority
    end
    
    local function pressBossRushConfirm()
        local ok, confirmButton = pcall(function()
            local prompt = LocalPlayer.PlayerGui:FindFirstChild("Prompt")
            if not prompt then return nil end
            local frame = prompt:FindFirstChild("Frame")
            if not frame then return nil end
            local innerFrame = frame:FindFirstChild("Frame")
            if not innerFrame then return nil end
            
            local children = innerFrame:GetChildren()
            if #children < 5 then return nil end
            
            local button = children[5]:FindFirstChild("TextButton")
            if not button then return nil end
            
            local label = button:FindFirstChild("TextLabel")
            if label and label.Text == "Confirm" then
                return button
            end
            
            return nil
        end)
        
        if ok and confirmButton then
            local events = {"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}
            for _, eventName in ipairs(events) do
                pcall(function()
                    for _, conn in ipairs(getconnections(confirmButton[eventName])) do
                        conn:Fire()
                    end
                end)
            end
            return true
        end
        return false
    end
    
    local function selectBossRushCard()
        if not getgenv().BossRushEnabled then return false end
        
        local availableCards = getBossRushCards()
        if not availableCards then return false end
        
        local bestCardIndex, bestCardData, bestPriority = findBestBossRushCard(availableCards)
        
        if bestPriority >= 999 then
            return false
        end
        
        local buttonToClick = bestCardData.button
        local events = {"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}
        
        for _, eventName in ipairs(events) do
            pcall(function()
                for _, conn in ipairs(getconnections(buttonToClick[eventName])) do
                    conn:Fire()
                end
            end)
        end
        
        wait(0.2)
        pressBossRushConfirm()
        
        return true
    end
    
    while true do
        wait(1)
        if getgenv().BossRushEnabled then
            selectBossRushCard()
        end
    end
end)

-- Seamless Fix System
task.spawn(function()
    local endgameCount = 0
    local hasRun = false
    
    repeat task.wait(0.5) until not LocalPlayer.PlayerGui:FindFirstChild("TeleportUI")
    
    print("[Seamless Fix] Waiting for Settings GUI...")
    repeat task.wait(0.5) until LocalPlayer.PlayerGui:FindFirstChild("Settings")
    print("[Seamless Fix] Settings GUI found!")
    
    local function getSeamlessValue()
        local settings = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Settings")
        if settings then
            local seamless = settings:FindFirstChild("SeamlessRetry")
            if seamless then
                return seamless.Value
            end
        end
        return false
    end
    
    local function setSeamlessRetry()
        pcall(function()
            RS.Remotes.SetSettings:InvokeServer("SeamlessRetry")
        end)
    end
    
    local function restartMatch()
        pcall(function()
            RS.Remotes.RestartMatch:FireServer()
        end)
    end
    
    task.spawn(function()
        if getgenv().SeamlessLimiterEnabled then
            print("[Seamless Fix] Checking initial seamless state...")
            local currentSeamless = getSeamlessValue()
            if endgameCount < (getgenv().MaxSeamlessRounds or 4) then
                if not currentSeamless then
                    setSeamlessRetry()
                    task.wait(0.5)
                    print("[Seamless Fix] Enabled Seamless Retry")
                end
            end
        end
    end)
    
    LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
        if not getgenv().SeamlessLimiterEnabled then return end
        
        if child.Name == "EndGameUI" and not hasRun then
            hasRun = true
            endgameCount = endgameCount + 1
            local maxRounds = getgenv().MaxSeamlessRounds or 4
            print("[Seamless Fix] Endgame detected. Current seamless rounds: " .. endgameCount .. "/" .. maxRounds)
            
            if endgameCount >= maxRounds and getSeamlessValue() then
                task.wait(0.5)
                setSeamlessRetry()
                print("[Seamless Fix] Disabled Seamless Retry")
                task.wait(0.5)
                if not getSeamlessValue() then
                    restartMatch()
                    print("[Seamless Fix] Restarted match")
                end
            end
        end
    end)
    
    LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
        if child.Name == "EndGameUI" then
            hasRun = false
            print("[Seamless Fix] EndgameUI removed, ready for next round")
        end
    end)
end)

-- Bingo Automation
task.spawn(function()
    if isInLobby then return end
    
    task.wait(2)
    
    local BingoEvents = RS:WaitForChild("Events"):WaitForChild("Bingo")
    local UseStampEvent = BingoEvents:FindFirstChild("UseStamp")
    local ClaimRewardEvent = BingoEvents:FindFirstChild("ClaimReward")
    local CompleteBoardEvent = BingoEvents:FindFirstChild("CompleteBoard")
    
    print("[Auto Bingo] Bingo automation loaded!")
    
    while true do
        task.wait(1)
        
        if getgenv().BingoEnabled then
            if UseStampEvent then
                for i = 1, 25 do
                    pcall(function()
                        UseStampEvent:FireServer()
                    end)
                    task.wait(0.1)
                end
                task.wait(0.2)
            end
            
            if ClaimRewardEvent then
                for i = 1, 25 do
                    pcall(function()
                        ClaimRewardEvent:InvokeServer(i)
                    end)
                    task.wait(0.1)
                end
                task.wait(0.2)
            end
            
            if CompleteBoardEvent then
                pcall(function()
                    CompleteBoardEvent:InvokeServer()
                end)
                task.wait(0.1)
            end
            
            task.wait(0)
        end
    end
end)

-- Capsule Automation
task.spawn(function()
    if isInLobby then return end
    
    task.wait(0)
    
    local PurchaseEvent = RS:WaitForChild("Events"):WaitForChild("Hallowen2025"):WaitForChild("Purchase")
    local OpenCapsuleEvent = RS:WaitForChild("Remotes"):WaitForChild("OpenCapsule")
    
    print("[Auto Capsules] Capsule automation loaded!")
    
    while true do
        task.wait(0)
        
        if getgenv().CapsuleEnabled then
            local clientData = getClientData()
            if clientData then
                local candyBasket = clientData.CandyBasket or 0
                local capsuleAmount = 0
                
                if clientData.ItemData and clientData.ItemData.HalloweenCapsule2025 then
                    capsuleAmount = clientData.ItemData.HalloweenCapsule2025.Amount or 0
                end
                
                if candyBasket >= 100000 then
                    pcall(function()
                        PurchaseEvent:InvokeServer(1, 100)
                    end)
                    task.wait(0)
                elseif candyBasket >= 10000 then
                    pcall(function()
                        PurchaseEvent:InvokeServer(1, 10)
                    end)
                    task.wait(0)
                elseif candyBasket >= 1000 then
                    pcall(function()
                        PurchaseEvent:InvokeServer(1, 1)
                    end)
                    task.wait(0)
                end
                
                task.wait(0)
                clientData = getClientData()
                if clientData and clientData.ItemData and clientData.ItemData.HalloweenCapsule2025 then
                    capsuleAmount = clientData.ItemData.HalloweenCapsule2025.Amount or 0
                end
                
                if capsuleAmount > 0 then
                    pcall(function()
                        OpenCapsuleEvent:FireServer("HalloweenCapsule2025", capsuleAmount)
                    end)
                    task.wait(0)
                end
            end
        end
    end
end)
