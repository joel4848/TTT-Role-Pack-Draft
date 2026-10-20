local maxStreamLength = 65528

local draft_innocent_picks = GetConVar("ttt_draft_innocent_picks")
local draft_innocent_bans = GetConVar("ttt_draft_innocent_bans")
local draft_traitor_picks = GetConVar("ttt_draft_traitor_picks")
local draft_traitor_bans = GetConVar("ttt_draft_traitor_bans")
local draft_jester_picks = GetConVar("ttt_draft_jester_picks")
local draft_jester_bans = GetConVar("ttt_draft_jester_bans")
local draft_independent_picks = GetConVar("ttt_draft_independent_picks")
local draft_independent_bans = GetConVar("ttt_draft_independent_bans")
local draft_monster_picks = GetConVar("ttt_draft_monster_picks")
local draft_monster_bans = GetConVar("ttt_draft_monster_bans")
local draft_detective_picks = GetConVar("ttt_draft_detective_picks")
local draft_detective_bans = GetConVar("ttt_draft_detective_bans")

local draft_prep_time = GetConVar("ttt_draft_prep_time")
local draft_turn_time = GetConVar("ttt_draft_turn_time")
local draft_end_time = GetConVar("ttt_draft_end_time")

local smallIconSize = 32
local smallIconMargin = 10
local smallIconOutline = 2
local smallIconGlow = 16
local largeIconSize = 64
local largeIconMargin = 40
local largeIconOutline = 4
local largeIconGlow = 32
local groupDividerWidth = 4
local groupMargin = 10
local timerWidth = 256

surface.CreateFont("DraftName", {
    font = "Tahoma",
    size = 16,
    weight = 1000
})

surface.CreateFont("DraftDescription", {
    font = "Tahoma",
    size = 24,
    weight = 400,
    italic = true
})

surface.CreateFont("DraftTimer", {
    font = "Tahoma",
    size = 32,
    weight = 1000
})

surface.CreateFont("DraftSmall", {
    font = "Tahoma",
    size = 38,
    weight = 1000
})

surface.CreateFont("DraftRegular", {
    font = "Tahoma",
    size = 48,
    weight = 1000
})

surface.CreateFont("DraftLarge", {
    font = "Tahoma",
    size = 64,
    weight = 1000
})

local function CalculateTopIconPositions()
    local innocentPicks = draft_innocent_picks:GetInt()
    local innocentBans = draft_innocent_bans:GetInt()
    local traitorPicks = draft_traitor_picks:GetInt()
    local traitorBans = draft_traitor_bans:GetInt()
    local jesterPicks = draft_jester_picks:GetInt()
    local jesterBans = draft_jester_bans:GetInt()
    local independentPicks = draft_independent_picks:GetInt()
    local independentBans = draft_independent_bans:GetInt()
    local monsterPicks = draft_monster_picks:GetInt()
    local monsterBans = draft_monster_bans:GetInt()
    local detectivePicks = draft_detective_picks:GetInt()
    local detectiveBans = draft_detective_bans:GetInt()

    local groups = 0
    local innocentGroupSize = 0
    if innocentPicks > 0 or innocentBans > 0 then
        groups = groups + 1
        innocentGroupSize = math.max(innocentPicks, innocentBans)
    end
    local traitorGroupSize = 0
    if traitorPicks > 0 or traitorBans > 0 then
        groups = groups + 1
        traitorGroupSize = math.max(traitorPicks, traitorBans)
    end
    local jesterGroupSize = 0
    if jesterPicks > 0 or jesterBans > 0 then
        groups = groups + 1
        jesterGroupSize = math.max(jesterPicks, jesterBans)
    end
    local independentGroupSize = 0
    if independentPicks > 0 or independentBans > 0 then
        groups = groups + 1
        independentGroupSize = math.max(independentPicks, independentBans)
    end
    local monsterGroupSize = 0
    if monsterPicks > 0 or monsterBans > 0 then
        groups = groups + 1
        monsterGroupSize = math.max(monsterPicks, monsterBans)
    end
    local detectiveGroupSize = 0
    if detectivePicks > 0 or detectiveBans > 0 then
        groups = groups + 1
        detectiveGroupSize = math.max(detectivePicks, detectiveBans)
    end

    local totalSize = innocentGroupSize + traitorGroupSize + jesterGroupSize + independentGroupSize + monsterGroupSize + detectiveGroupSize
    local width = ((groups - 1) * (groupDividerWidth + (2 * groupMargin))) + (totalSize * smallIconSize) + ((totalSize + groups - 2) * smallIconMargin)
    local x = (ScrW() - width) / 2

    local groupPositions = {
        [ROLE_TEAM_INNOCENT] = {["picks"] = {["count"] = innocentPicks, ["x"] = 0}, ["bans"] = {["count"] = innocentBans, ["x"] = 0}},
        [ROLE_TEAM_TRAITOR] = {["picks"] = {["count"] = traitorPicks, ["x"] = 0}, ["bans"] = {["count"] = traitorBans, ["x"] = 0}},
        [ROLE_TEAM_JESTER] = {["picks"] = {["count"] = jesterPicks, ["x"] = 0}, ["bans"] = {["count"] = jesterBans, ["x"] = 0}},
        [ROLE_TEAM_INDEPENDENT] = {["picks"] = {["count"] = independentPicks, ["x"] = 0}, ["bans"] = {["count"] = independentBans, ["x"] = 0}},
        [ROLE_TEAM_MONSTER] = {["picks"] = {["count"] = monsterPicks, ["x"] = 0}, ["bans"] = {["count"] = monsterBans, ["x"] = 0}},
        [ROLE_TEAM_DETECTIVE] = {["picks"] = {["count"] = detectivePicks, ["x"] = 0}, ["bans"] = {["count"] = detectiveBans, ["x"] = 0}}
    }

    local dividerPositions = {}

    -- Follow the same order as role packs (Det > Inn > Tra > Jes > Ind > Mon)
    if detectiveGroupSize > 0 then
        table.insert(dividerPositions, x + ((smallIconSize + smallIconMargin) * detectiveGroupSize) + groupMargin)
        if detectivePicks >= detectiveBans then
            groupPositions[ROLE_TEAM_DETECTIVE]["picks"]["x"] = x
            groupPositions[ROLE_TEAM_DETECTIVE]["bans"]["x"] = x + ((detectivePicks - detectiveBans) / 2) * (smallIconSize + smallIconMargin)
        else
            groupPositions[ROLE_TEAM_DETECTIVE]["bans"]["x"] = x
            groupPositions[ROLE_TEAM_DETECTIVE]["picks"]["x"] = x + ((detectiveBans - detectivePicks) / 2) * (smallIconSize + smallIconMargin)
        end
        x = x + (detectiveGroupSize * (smallIconSize + smallIconMargin)) + groupDividerWidth + (2 * groupMargin) + smallIconMargin
    end
    if innocentGroupSize > 0 then
        table.insert(dividerPositions, x + ((smallIconSize + smallIconMargin) * innocentGroupSize) + groupMargin)
        if innocentPicks >= innocentBans then
            groupPositions[ROLE_TEAM_INNOCENT]["picks"]["x"] = x
            groupPositions[ROLE_TEAM_INNOCENT]["bans"]["x"] = x + ((innocentPicks - innocentBans) / 2) * (smallIconSize + smallIconMargin)
        else
            groupPositions[ROLE_TEAM_INNOCENT]["bans"]["x"] = x
            groupPositions[ROLE_TEAM_INNOCENT]["picks"]["x"] = x + ((innocentBans - innocentPicks) / 2) * (smallIconSize + smallIconMargin)
        end
        x = x + (innocentGroupSize * (smallIconSize + smallIconMargin)) + groupDividerWidth + (2 * groupMargin) + smallIconMargin
    end
    if traitorGroupSize > 0 then
        table.insert(dividerPositions, x + ((smallIconSize + smallIconMargin) * traitorGroupSize) + groupMargin)
        if traitorPicks >= traitorBans then
            groupPositions[ROLE_TEAM_TRAITOR]["picks"]["x"] = x
            groupPositions[ROLE_TEAM_TRAITOR]["bans"]["x"] = x + ((traitorPicks - traitorBans) / 2) * (smallIconSize + smallIconMargin)
        else
            groupPositions[ROLE_TEAM_TRAITOR]["bans"]["x"] = x
            groupPositions[ROLE_TEAM_TRAITOR]["picks"]["x"] = x + ((traitorBans - traitorPicks) / 2) * (smallIconSize + smallIconMargin)
        end
        x = x + (traitorGroupSize * (smallIconSize + smallIconMargin)) + groupDividerWidth + (2 * groupMargin) + smallIconMargin
    end
    if jesterGroupSize > 0 then
        table.insert(dividerPositions, x + ((smallIconSize + smallIconMargin) * jesterGroupSize) + groupMargin)
        if jesterPicks >= jesterBans then
            groupPositions[ROLE_TEAM_JESTER]["picks"]["x"] = x
            groupPositions[ROLE_TEAM_JESTER]["bans"]["x"] = x + ((jesterPicks - jesterBans) / 2) * (smallIconSize + smallIconMargin)
        else
            groupPositions[ROLE_TEAM_JESTER]["bans"]["x"] = x
            groupPositions[ROLE_TEAM_JESTER]["picks"]["x"] = x + ((jesterBans - jesterPicks) / 2) * (smallIconSize + smallIconMargin)
        end
        x = x + (jesterGroupSize * (smallIconSize + smallIconMargin)) + groupDividerWidth + (2 * groupMargin) + smallIconMargin
    end
    if independentGroupSize > 0 then
        table.insert(dividerPositions, x + ((smallIconSize + smallIconMargin) * independentGroupSize) + groupMargin)
        if independentPicks >= independentBans then
            groupPositions[ROLE_TEAM_INDEPENDENT]["picks"]["x"] = x
            groupPositions[ROLE_TEAM_INDEPENDENT]["bans"]["x"] = x + ((independentPicks - independentBans) / 2) * (smallIconSize + smallIconMargin)
        else
            groupPositions[ROLE_TEAM_INDEPENDENT]["bans"]["x"] = x
            groupPositions[ROLE_TEAM_INDEPENDENT]["picks"]["x"] = x + ((independentBans - independentPicks) / 2) * (smallIconSize + smallIconMargin)
        end
        x = x + (independentGroupSize * (smallIconSize + smallIconMargin)) + groupDividerWidth + (2 * groupMargin) + smallIconMargin
    end
    if monsterGroupSize > 0 then
        table.insert(dividerPositions, x + ((smallIconSize + smallIconMargin) * monsterGroupSize) + groupMargin)
        if monsterPicks >= monsterBans then
            groupPositions[ROLE_TEAM_MONSTER]["picks"]["x"] = x
            groupPositions[ROLE_TEAM_MONSTER]["bans"]["x"] = x + ((monsterPicks - monsterBans) / 2) * (smallIconSize + smallIconMargin)
        else
            groupPositions[ROLE_TEAM_MONSTER]["bans"]["x"] = x
            groupPositions[ROLE_TEAM_MONSTER]["picks"]["x"] = x + ((monsterBans - monsterPicks) / 2) * (smallIconSize + smallIconMargin)
        end
    end

    table.remove(dividerPositions)

    return {["groups"] = groupPositions, ["dividers"] = dividerPositions}
end

local function CalculateBottomIconPositions(draftOrder)
    local width = (#draftOrder * (smallIconSize + (2 * smallIconMargin))) - (2 * smallIconMargin)
    local x = (ScrW() - width) / 2
    return {["x"] = x, ["width"] = width, ["order"] = draftOrder}
end

local function CalculateCentreIconPositions(roles)
    local positions = {}
    for team = ROLE_TEAM_INNOCENT, ROLE_TEAM_DETECTIVE do
        local width = #roles[team] * (largeIconSize + largeIconMargin) - largeIconMargin
        local x = (ScrW() - width) / 2
        positions[team] = {["x"] = x}
    end
    return positions
end

local topPositions = {}
local bottomPositions = {}
local centrePositions = {
    [ROLE_TEAM_INNOCENT] = {},
    [ROLE_TEAM_TRAITOR] = {},
    [ROLE_TEAM_JESTER] = {},
    [ROLE_TEAM_INDEPENDENT] = {},
    [ROLE_TEAM_MONSTER] = {},
    [ROLE_TEAM_DETECTIVE] = {}
}
local availableRoles = {
    [ROLE_TEAM_INNOCENT] = {},
    [ROLE_TEAM_TRAITOR] = {},
    [ROLE_TEAM_JESTER] = {},
    [ROLE_TEAM_INDEPENDENT] = {},
    [ROLE_TEAM_MONSTER] = {},
    [ROLE_TEAM_DETECTIVE] = {}
}
local pickedRoles = {
    [ROLE_TEAM_INNOCENT] = {},
    [ROLE_TEAM_TRAITOR] = {},
    [ROLE_TEAM_JESTER] = {},
    [ROLE_TEAM_INDEPENDENT] = {},
    [ROLE_TEAM_MONSTER] = {},
    [ROLE_TEAM_DETECTIVE] = {}
}
local bannedRoles = {
    [ROLE_TEAM_INNOCENT] = {},
    [ROLE_TEAM_TRAITOR] = {},
    [ROLE_TEAM_JESTER] = {},
    [ROLE_TEAM_INDEPENDENT] = {},
    [ROLE_TEAM_MONSTER] = {},
    [ROLE_TEAM_DETECTIVE] = {}
}
local draftPhase = -1
local nextPhaseTime = -1
local randomSelection = false
local previousSelection
local selectedRole
local frames = {}
local mouseAutoEnabled = false

local function BeginRolePackDraft(draftData)
    topPositions = CalculateTopIconPositions()
    bottomPositions = CalculateBottomIconPositions(draftData.order)
    centrePositions = CalculateCentreIconPositions(draftData.roles)
    availableRoles = draftData.roles
    draftPhase = 0
    nextPhaseTime = CurTime() + draft_prep_time:GetInt()
end

local buff = ""
net.Receive("TTT_BeginRolePackDraft_Part", function()
    buff = buff .. net.ReadData(maxStreamLength)
end)

net.Receive("TTT_BeginRolePackDraft", function()
    local dataJson = util.Decompress(buff .. net.ReadData(net.ReadUInt(16)))
    buff = ""

    if #dataJson == 0 then
        ErrorNoHalt("Role pack draft table decompression failed!\n")
        return
    end

    local dataTable = util.JSONToTable(dataJson)
    if dataTable == nil then
        ErrorNoHalt("Role pack draft table conversion failed!\n")
        return
    end

    BeginRolePackDraft(dataTable)
end)

net.Receive("TTT_EndRolePackDraft", function()
    topPositions = {}
    bottomPositions = {}
    centrePositions = {
        [ROLE_TEAM_INNOCENT] = {},
        [ROLE_TEAM_TRAITOR] = {},
        [ROLE_TEAM_JESTER] = {},
        [ROLE_TEAM_INDEPENDENT] = {},
        [ROLE_TEAM_MONSTER] = {},
        [ROLE_TEAM_DETECTIVE] = {}
    }
    availableRoles = {
        [ROLE_TEAM_INNOCENT] = {},
        [ROLE_TEAM_TRAITOR] = {},
        [ROLE_TEAM_JESTER] = {},
        [ROLE_TEAM_INDEPENDENT] = {},
        [ROLE_TEAM_MONSTER] = {},
        [ROLE_TEAM_DETECTIVE] = {}
    }
    pickedRoles = {
        [ROLE_TEAM_INNOCENT] = {},
        [ROLE_TEAM_TRAITOR] = {},
        [ROLE_TEAM_JESTER] = {},
        [ROLE_TEAM_INDEPENDENT] = {},
        [ROLE_TEAM_MONSTER] = {},
        [ROLE_TEAM_DETECTIVE] = {}
    }
    bannedRoles = {
        [ROLE_TEAM_INNOCENT] = {},
        [ROLE_TEAM_TRAITOR] = {},
        [ROLE_TEAM_JESTER] = {},
        [ROLE_TEAM_INDEPENDENT] = {},
        [ROLE_TEAM_MONSTER] = {},
        [ROLE_TEAM_DETECTIVE] = {}
    }
    draftPhase = -1
    nextPhaseTime = -1
    randomSelection = false
    previousSelection = nil
    selectedRole = nil

    if vgui.CursorVisible() then
        gui.EnableScreenClicker(false)
        mouseAutoEnabled = false
    end

    for _, frame in pairs(frames) do
        frame:Close()
    end
    frames = {}
end)

net.Receive("TTT_NextRolePackDraft", function()
    if draftPhase == -1 then return end

    randomSelection = net.ReadBool()
    previousSelection = net.ReadInt(util.RoleBits())
    if draftPhase > 0 then
        if bottomPositions.order[draftPhase].action == "pick" then
            table.insert(pickedRoles[bottomPositions.order[draftPhase].team], previousSelection)
        else
            table.insert(bannedRoles[bottomPositions.order[draftPhase].team], previousSelection)
        end
    end
    draftPhase = draftPhase + 1
    if draftPhase > #bottomPositions.order then
        nextPhaseTime = CurTime() + draft_end_time:GetInt()
    else
        nextPhaseTime = CurTime() + draft_turn_time:GetInt()
    end
    selectedRole = nil

    local currentPlayer
    if draftPhase > 0 and draftPhase <= #bottomPositions.order then
        currentPlayer = player.GetBySteamID64(bottomPositions.order[draftPhase].player)
    end
    if currentPlayer == LocalPlayer() then
        surface.PlaySound("rolepackdraft/alert.wav")
    end

    if draftPhase > #bottomPositions.order or currentPlayer ~= LocalPlayer() then
        if vgui.CursorVisible() then
            gui.EnableScreenClicker(false)
            mouseAutoEnabled = false
        end
    end
end)

net.Receive("TTT_UpdateRolePackDraft", function()
    selectedRole = net.ReadInt(util.RoleBits())
end)

local smallOutline = Material("rolepackdraft/outline_small.png")
local smallGlow = Material("rolepackdraft/glow_small.png")
local largeOutline = Material("rolepackdraft/outline_large.png")
local largeGlow = Material("rolepackdraft/glow_large.png")
local pickIcon = Material("rolepackdraft/pick.png")
local banIcon = Material("rolepackdraft/ban.png")
local largeBan = Material("rolepackdraft/ban_large.png")
local randomIcon = Material("rolepackdraft/random.png")

hook.Add("HUDShouldDraw", "TTTDraft_HUDShouldDraw", function(name)
    if draftPhase >= 0 and name ~= "CHudGMod" then return false end
end)

local function DrawColoredText(textTable, font, x, y, xalign, yalign)
    surface.SetFont(font)

    local width = 0
    local height
    local widths = {}
    for _, text in ipairs(textTable) do
        local w, h = surface.GetTextSize(text.text)
        if not height then height = h end
        table.insert(widths, w)
        width = width + w
    end

    if (xalign == TEXT_ALIGN_CENTER) then
        x = x - width / 2
    elseif (xalign == TEXT_ALIGN_RIGHT) then
        x = x - width
    end

    if (yalign == TEXT_ALIGN_CENTER) then
        y = y - height / 2
    elseif (yalign == TEXT_ALIGN_BOTTOM) then
        y = y - height
    end

    for i, text in ipairs(textTable) do
        surface.SetTextPos(math.ceil(x), math.ceil(y))

        if (text.color ~= nil) then
            surface.SetTextColor(text.color.r, text.color.g, text.color.b, text.color.a)
        else
            surface.SetTextColor(255, 255, 255, 255)
        end

        surface.DrawText(text.text)
        x = x + widths[i]
    end

    return width, height
end

local teamArticle = {
    [ROLE_TEAM_INNOCENT] = "AN",
    [ROLE_TEAM_TRAITOR] = "A",
    [ROLE_TEAM_JESTER] = "A",
    [ROLE_TEAM_INDEPENDENT] = "AN",
    [ROLE_TEAM_MONSTER] = "A",
    [ROLE_TEAM_DETECTIVE] = "A"
}
local teamNames = {
    [ROLE_TEAM_INNOCENT] = "INNOCENT",
    [ROLE_TEAM_TRAITOR] = "TRAITOR",
    [ROLE_TEAM_JESTER] = "JESTER",
    [ROLE_TEAM_INDEPENDENT] = "INDEPENDENT",
    [ROLE_TEAM_MONSTER] = "MONSTER",
    [ROLE_TEAM_DETECTIVE] = "DETECTIVE"
}
local mouseDown = false
local lastRandomSelect = 0
local lastRandomIndex = 0

local pickedY     = smallIconMargin
local bannedY     = smallIconSize + (2 * smallIconMargin)
local topDivY     = (1.5 * smallIconMargin) + (0.5 * smallIconSize)
local timerY      = (2 * smallIconSize) + (3 * smallIconMargin)
local bottomPosY  = ScrH() - smallIconSize - smallIconMargin
local centrePosY  = (ScrH() - largeIconSize) / 2
local centreDivY  = (ScrH() + largeIconSize) / 2 + largeIconMargin + smallIconMargin
local upNextY     = (3 * smallIconSize) + (4 * smallIconMargin)
local messageY    = centreDivY + (2 * smallIconMargin)
local previewY    = ScrH() * 4 / 5

hook.Add("HUDDrawScoreBoard", "TTTDraft_HUDDrawScoreBoard", function()
    if draftPhase >= 0 then
        draw.NoTexture()
        surface.SetDrawColor(0, 0, 0, 220)
        surface.DrawRect(0, 0, ScrW(), ScrH())

        -------------------------------------------------------------------------------------------------------
        -- Top row icons (picks/bans)
        -------------------------------------------------------------------------------------------------------

        for team, group in pairs(topPositions.groups) do
            local x = group.picks.x
            -- local y = smallIconMargin
            for slot = 1, group.picks.count do
                local bright = false
                if draftPhase >= 1 and draftPhase <= #bottomPositions.order then
                    if bottomPositions.order[draftPhase].action == "pick" and bottomPositions.order[draftPhase].team == team then
                        if slot == #pickedRoles[team] + 1 then
                            bright = true
                            surface.SetDrawColor(GetRoleTeamColor(team, "highlight"))
                            surface.SetMaterial(smallGlow)
                            surface.DrawTexturedRect(x - smallIconGlow, pickedY - smallIconGlow, smallIconSize + (2 * smallIconGlow), smallIconSize + (2 * smallIconGlow))
                        end
                    end
                end
                draw.NoTexture()
                surface.SetDrawColor(COLOR_BLACK)
                surface.DrawRect(x, pickedY, smallIconSize, smallIconSize)
                surface.SetDrawColor(GetRoleTeamColor(team, "highlight"))
                surface.SetMaterial(smallOutline)
                surface.DrawTexturedRect(x - smallIconOutline, pickedY - smallIconOutline, smallIconSize + (2 * smallIconOutline), smallIconSize + (2 * smallIconOutline))
                if slot > #pickedRoles[team] then
                    if bright then
                        surface.SetDrawColor(COLOR_WHITE)
                    else
                        surface.SetDrawColor(255, 255, 255, 127)
                    end
                    surface.SetMaterial(pickIcon)
                else
                    surface.SetDrawColor(COLOR_WHITE)
                    surface.SetMaterial(Material(util.GetRoleIconPath(ROLE_STRINGS_SHORT[pickedRoles[team][slot]], "score", "png")))
                end
                surface.DrawTexturedRect(x, pickedY, smallIconSize, smallIconSize)
                x = x + smallIconSize + smallIconMargin
            end
            x = group.bans.x
            -- y = smallIconSize + (2 * smallIconMargin)
            for slot = 1, group.bans.count do
                local bright = false
                if draftPhase >= 1 and draftPhase <= #bottomPositions.order then
                    if bottomPositions.order[draftPhase].action == "ban" and bottomPositions.order[draftPhase].team == team then
                        if slot == #bannedRoles[team] + 1 then
                            bright = true
                            surface.SetDrawColor(GetRoleTeamColor(team, "highlight"))
                            surface.SetMaterial(smallGlow)
                            surface.DrawTexturedRect(x - smallIconGlow, bannedY - smallIconGlow, smallIconSize + (2 * smallIconGlow), smallIconSize + (2 * smallIconGlow))
                        end
                    end
                end
                draw.NoTexture()
                surface.SetDrawColor(COLOR_BLACK)
                surface.DrawRect(x, bannedY, smallIconSize, smallIconSize)
                surface.SetDrawColor(GetRoleTeamColor(team, "highlight"))
                surface.SetMaterial(smallOutline)
                surface.DrawTexturedRect(x - smallIconOutline, bannedY - smallIconOutline, smallIconSize + (2 * smallIconOutline), smallIconSize + (2 * smallIconOutline))
                if slot > #bannedRoles[team] then
                    if bright then
                        surface.SetDrawColor(COLOR_WHITE)
                    else
                        surface.SetDrawColor(255, 255, 255, 127)
                    end
                    surface.SetMaterial(banIcon)
                else
                    surface.SetDrawColor(255, 255, 255, 32)
                    surface.SetMaterial(Material(util.GetRoleIconPath(ROLE_STRINGS_SHORT[bannedRoles[team][slot]], "score", "png")))
                end
                surface.DrawTexturedRect(x, bannedY, smallIconSize, smallIconSize)
                x = x + smallIconSize + smallIconMargin
            end
        end

        draw.NoTexture()
        -- local y = (1.5 * smallIconMargin) + (0.5 * smallIconSize)
        for _, divider in pairs(topPositions.dividers) do
            surface.SetDrawColor(COLOR_WHITE)
            surface.DrawRect(divider, topDivY, groupDividerWidth, smallIconSize)
        end

        -------------------------------------------------------------------------------------------------------
        -- Timer
        -------------------------------------------------------------------------------------------------------

        -- y = (2 * smallIconSize) + (3 * smallIconMargin)
        local time = math.max(0, nextPhaseTime - CurTime())
        local progress
        if draftPhase == 0 then
            progress = time / draft_prep_time:GetInt()
        elseif draftPhase > #bottomPositions.order then
            progress = time / draft_end_time:GetInt()
        else
            progress = time / draft_turn_time:GetInt()
        end
        draw.SimpleText(string.format("%05.2f", time), "DraftTimer", ScrW() / 2, timerY, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        surface.DrawRect((ScrW() - (timerWidth * progress)) / 2, timerY + smallIconSize + (0.5 * smallIconMargin), timerWidth * progress, groupDividerWidth)

        -------------------------------------------------------------------------------------------------------
        -- Bottom row icons (players/actions)
        -------------------------------------------------------------------------------------------------------

        local x = bottomPositions.x
        -- y = ScrH() - smallIconSize - smallIconMargin
        draw.NoTexture()
        surface.SetDrawColor(COLOR_WHITE)
        surface.DrawRect(x + (0.5 * smallIconSize), bottomPosY + (0.5 * (smallIconSize - groupDividerWidth)), bottomPositions.width - smallIconSize, groupDividerWidth)

        if draftPhase >= 1 and draftPhase <= #bottomPositions.order then
            surface.SetDrawColor(GetRoleTeamColor(bottomPositions.order[draftPhase].team, "highlight"))
            surface.SetMaterial(smallGlow)
            surface.DrawTexturedRect(x - smallIconGlow + ((draftPhase - 1) * (smallIconSize + (2 * smallIconMargin))), bottomPosY - smallIconGlow, smallIconSize + (2 * smallIconGlow), smallIconSize + (2 * smallIconGlow))
        end

        local createFrames = #frames == 0

        for order, turn in ipairs(bottomPositions.order) do
            if turn.player then
                if createFrames then
                    local frame = vgui.Create("DFrame")
                    frame:SetPos(x, bottomPosY)
                    frame:SetSize(smallIconSize, smallIconSize)
                    frame:ShowCloseButton(false)
                    frame.Paint = function() end
                    frames[order] = frame
                    local avatar = vgui.Create("AvatarImage", frame)
                    avatar:SetPlayer(player.GetBySteamID64(turn.player))
                    avatar:SetSize(smallIconSize, smallIconSize)
                    frame.avatar = avatar
                    local panel = vgui.Create("DPanel", frame)
                    panel:SetSize(smallIconSize, smallIconSize)
                    frame.panel = panel
                end
            else
                draw.NoTexture()
                surface.SetDrawColor(COLOR_BLACK)
                surface.DrawRect(x, bottomPosY, smallIconSize, smallIconSize)
                if order < draftPhase then
                    surface.SetDrawColor(255, 255, 255, 32)
                elseif order > draftPhase then
                    surface.SetDrawColor(255, 255, 255, 127)
                else
                    surface.SetDrawColor(COLOR_WHITE)
                end
                surface.SetMaterial(randomIcon)
                surface.DrawTexturedRect(x, bottomPosY, smallIconSize, smallIconSize)
            end

            surface.SetDrawColor(GetRoleTeamColor(turn.team, "highlight"))
            surface.SetMaterial(smallOutline)
            surface.DrawTexturedRect(x - smallIconOutline, bottomPosY - smallIconOutline, smallIconSize + (2 * smallIconOutline), smallIconSize + (2 * smallIconOutline))
            if order < draftPhase then
                surface.SetDrawColor(255, 255, 255, 32)
                if turn.player then
                    frames[order].panel:SetBackgroundColor(Color(0, 0, 0, 223))
                    frames[order].panel:SetPaintBackground(true)
                end
            elseif order > draftPhase then
                surface.SetDrawColor(255, 255, 255, 127)
                if turn.player then
                    frames[order].panel:SetBackgroundColor(Color(0, 0, 0, 127))
                    frames[order].panel:SetPaintBackground(true)
                end
            else
                surface.SetDrawColor(COLOR_WHITE)
                if turn.player then
                    frames[order].panel:SetPaintBackground(false)
                end
            end
            if turn.action == "pick" then
                surface.SetMaterial(pickIcon)
            else
                surface.SetMaterial(banIcon)
            end
            surface.DrawTexturedRect(x, bottomPosY - smallIconSize, smallIconSize, smallIconSize)
            x = x + smallIconSize + (2 * smallIconMargin)
        end

        -------------------------------------------------------------------------------------------------------
        -- Middle row (choices)
        -------------------------------------------------------------------------------------------------------

        if draftPhase >= 1 and draftPhase <= #bottomPositions.order then
            local turn = bottomPositions.order[draftPhase]
            x = centrePositions[turn.team].x
            -- y = (ScrH() - largeIconSize) / 2

            local cursorX, cursorY = -1, -1
            if player.GetBySteamID64(turn.player) == LocalPlayer() then
                if not vgui.CursorVisible() then
                    gui.EnableScreenClicker(true)
                    mouseAutoEnabled = true
                end

                cursorX, cursorY = input.GetCursorPos()
            elseif turn.player == nil then
                if CurTime() - lastRandomSelect > 0.5 then
                    lastRandomSelect = CurTime()
                    lastRandomIndex = math.random(1, #availableRoles[turn.team])
                    while table.HasValue(pickedRoles[turn.team], availableRoles[turn.team][lastRandomIndex]) or table.HasValue(bannedRoles[turn.team], availableRoles[turn.team][lastRandomIndex]) do
                        lastRandomIndex = lastRandomIndex + 1
                        if lastRandomIndex > #availableRoles[turn.team] then
                            lastRandomIndex = 1
                        end
                    end
                    selectedRole = availableRoles[turn.team][lastRandomIndex]
                end
            end

            for _, role in ipairs(availableRoles[turn.team]) do
                local hover = false
                local selected = selectedRole == role
                if cursorX >= x and cursorX <= x + largeIconSize and cursorY >= centrePosY and cursorY <= centrePosY + largeIconSize then
                    if not table.HasValue(pickedRoles[turn.team], role) and not table.HasValue(bannedRoles[turn.team], role) then
                        hover = true
                        if input.IsMouseDown(MOUSE_LEFT) then
                            if not mouseDown then
                                net.Start("TTT_SelectRolePackDraft")
                                net.WriteInt(role, util.RoleBits())
                                net.WriteUInt(draftPhase, 8)
                                net.SendToServer()
                            end
                            mouseDown = true
                        else
                            mouseDown = false
                        end
                    end
                end

                if selected then
                    surface.SetDrawColor(GetRoleTeamColor(turn.team, "highlight"))
                    surface.SetMaterial(largeGlow)
                    surface.DrawTexturedRect(x - largeIconGlow, centrePosY - largeIconGlow, largeIconSize + (2 * largeIconGlow), largeIconSize + (2 * largeIconGlow))
                elseif hover then
                    surface.SetDrawColor(ColorAlpha(GetRoleTeamColor(turn.team, "highlight"), 128))
                    surface.SetMaterial(largeGlow)
                    surface.DrawTexturedRect(x - largeIconGlow, centrePosY - largeIconGlow, largeIconSize + (2 * largeIconGlow), largeIconSize + (2 * largeIconGlow))
                end

                draw.NoTexture()
                surface.SetDrawColor(COLOR_BLACK)
                surface.DrawRect(x, centrePosY, largeIconSize, largeIconSize)
                if table.HasValue(pickedRoles[turn.team], role) or table.HasValue(bannedRoles[turn.team], role) then
                    surface.SetDrawColor(255, 255, 255, 32)
                    draw.SimpleText(ROLE_STRINGS[role], "DraftName", x + (0.5 * largeIconSize), centrePosY + largeIconSize + (0.25 * largeIconMargin), Color(255, 255, 255, 32), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                elseif selected or hover then
                    if turn.action == "ban" then
                        surface.SetDrawColor(255, 255, 255, 32)
                    else
                        surface.SetDrawColor(COLOR_WHITE)
                    end
                    draw.SimpleText(ROLE_STRINGS[role], "DraftName", x + (0.5 * largeIconSize), centrePosY + largeIconSize + (0.25 * largeIconMargin), COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                else
                    surface.SetDrawColor(255, 255, 255, 191)
                    draw.SimpleText(ROLE_STRINGS[role], "DraftName", x + (0.5 * largeIconSize), centrePosY + largeIconSize + (0.25 * largeIconMargin), Color(255, 255, 255, 191), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end
                surface.SetMaterial(ROLE_SPRITE_ICON_MATERIALS[ROLE_STRINGS_SHORT[role]])
                surface.DrawTexturedRect(x, centrePosY, largeIconSize, largeIconSize)

                if turn.action == "ban" then
                    if selected then
                        surface.SetDrawColor(COLOR_WHITE)
                        surface.SetMaterial(largeBan)
                        surface.DrawTexturedRect(x, centrePosY, largeIconSize, largeIconSize)
                    elseif hover then
                        surface.SetDrawColor(255, 255, 255, 191)
                        surface.SetMaterial(largeBan)
                        surface.DrawTexturedRect(x, centrePosY, largeIconSize, largeIconSize)
                    end
                end

                surface.SetDrawColor(GetRoleTeamColor(turn.team, "highlight"))
                surface.SetMaterial(largeOutline)
                surface.DrawTexturedRect(x - largeIconOutline, centrePosY - largeIconOutline, largeIconSize + (2 * largeIconOutline), largeIconSize + (2 * largeIconOutline))
                x = x + largeIconSize + largeIconMargin
            end
        end

        -------------------------------------------------------------------------------------------------------
        -- Next turn choice previews
        -------------------------------------------------------------------------------------------------------

        local showNext = GetConVar("ttt_draft_show_next"):GetInt()
        if showNext > 0 and draftPhase < #bottomPositions.order then
            local targetTurn     = nil
            local turnsUntilPick = 0

            if showNext == 1 then
                -- Show previews if player is up next
                local nextTurn = bottomPositions.order[draftPhase + 1]
                local nextPly = player.GetBySteamID64(nextTurn.player)
                if nextPly == LocalPlayer() then
                    targetTurn = nextTurn
                    turnsUntilPick = 1
                end
            elseif showNext == 2 then
                -- Find player's next choice
                for i = draftPhase + 1, #bottomPositions.order do
                    local turn = bottomPositions.order[i]
                    if turn.player and player.GetBySteamID64(turn.player) == LocalPlayer() then
                        targetTurn = turn
                        turnsUntilPick = i - draftPhase
                        break
                    end
                end
            end

            if targetTurn then
                local nextX = centrePositions[targetTurn.team].x

                local previewSize   = 48
                local previewMargin = 40

                local previewWidth = #availableRoles[targetTurn.team] * (previewSize + previewMargin) - previewMargin
                nextX = (ScrW() - previewWidth) / 2

                -- Get cursor location for hover detection
                local cursorX, cursorY = input.GetCursorPos()

                local iconOffsetY = turnsUntilPick <= 1 and 70 or 0

                -- Draw "IN x TURNS" text
                if showNext == 2 and turnsUntilPick > 1 then
                    local actionText  = targetTurn.action == "pick" and "PICKING" or "BANNING"
                    local actionColor = targetTurn.action == "pick" and GetRoleTeamColor(ROLE_TEAM_DETECTIVE, "highlight") or GetRoleTeamColor(ROLE_TEAM_TRAITOR, "highlight")
                    local teamColour  = GetRoleTeamColor(targetTurn.team, "highlight")

                    local message = {}
                    table.insert(message, {["text"] = string.format("IN %d TURNS: ", turnsUntilPick), ["color"] = COLOR_WHITE})
                    table.insert(message, {["text"] = "YOU ARE ", ["color"] = COLOR_WHITE})
                    table.insert(message, {["text"] = actionText, ["color"] = actionColor})
                    table.insert(message, {["text"] = " " .. teamArticle[targetTurn.team], ["color"] = COLOR_WHITE})
                    table.insert(message, {["text"] = " " .. teamNames[targetTurn.team], ["color"] = teamColour})
                    for _, text in ipairs(message) do
                        text.color = ColorAlpha(text.color, 220)
                    end
                    DrawColoredText(message, "DraftSmall", ScrW() / 2, previewY - previewSize / 2 - 35 - iconOffsetY, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

                    nextOffsetY = 35
                end

                local hoveredRole = nil

                -- Draw preview icons
                for _, role in ipairs(availableRoles[targetTurn.team]) do
                    local iconY = previewY - previewSize / 2 - iconOffsetY
                    local isHovered = (cursorX >= nextX and cursorX <= nextX + previewSize and cursorY >= iconY and cursorY <= iconY + previewSize)

                    if isHovered then
                        hoveredRole = role
                    end

                    -- Draw glow if hovered
                    if isHovered then
                        surface.SetDrawColor(ColorAlpha(GetRoleTeamColor(targetTurn.team, "highlight"), 180))
                        surface.SetMaterial(smallGlow)
                        surface.DrawTexturedRect(nextX - smallIconGlow, iconY - smallIconGlow, previewSize + (2 * smallIconGlow), previewSize + (2 * smallIconGlow))
                    end

                    draw.NoTexture()
                    surface.SetDrawColor(0, 0, 0, 150)
                    surface.DrawRect(nextX, iconY, previewSize, previewSize)

                    local isPickedOrBanned = table.HasValue(pickedRoles[targetTurn.team], role) or table.HasValue(bannedRoles[targetTurn.team], role)

                    if isPickedOrBanned then
                        surface.SetDrawColor(255, 255, 255, 30)
                    elseif isHovered then
                        surface.SetDrawColor(255, 255, 255, 255)
                    else
                        surface.SetDrawColor(255, 255, 255, 160)
                    end

                    -- Role icon
                    local iconMat = ROLE_SPRITE_ICON_MATERIALS[ROLE_STRINGS_SHORT[role]]
                    if iconMat then
                        surface.SetMaterial(iconMat)
                        surface.DrawTexturedRect(nextX, iconY, previewSize, previewSize)
                    end

                    -- Role name
                    local nameColor = isPickedOrBanned and Color(255, 255, 255, 30) or (isHovered and COLOR_WHITE or Color(255, 255, 255, 180))
                    draw.SimpleText(
                        ROLE_STRINGS[role],
                        "DraftName",
                        nextX + (0.5 * previewSize),
                        previewY + previewSize / 2 + 4 - iconOffsetY,
                        nameColor,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_TOP
                    )

                    -- Outline
                    surface.SetDrawColor(ColorAlpha(GetRoleTeamColor(targetTurn.team, "highlight"), isHovered and 255 or 150))
                    surface.SetMaterial(smallOutline)
                    surface.DrawTexturedRect(nextX - smallIconOutline, iconY - smallIconOutline, previewSize + (2 * smallIconOutline), previewSize + (2 * smallIconOutline))

                    nextX = nextX + previewSize + previewMargin
                end

                -- Draw role description underneath preview names if hovered
                if hoveredRole then
                    local descText = "This role doesn't have a description :("
                    if LANG and LANG.GetRawTranslation then
                        descText = LANG.GetRawTranslation("cheatsheet_desc_" .. ROLE_STRINGS_RAW[hoveredRole]) or descText
                    end

                    draw.SimpleText(
                        descText,
                        "DraftDescription",
                        ScrW() / 2,
                        previewY + previewSize + smallIconMargin - iconOffsetY,
                        Color(220, 220, 220, 230),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_TOP
                    )
                end
            end
        end

        x = ScrW() / 2
        if draftPhase == 0 then
            draw.SimpleText("ROLE PACK DRAFT STARTING SOON", "DraftLarge", x, ScrH() / 2, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local nextTurn = bottomPositions.order[1]
            local nextPly = player.GetBySteamID64(nextTurn.player)

            local action = {}
            if nextTurn.action == "pick" then
                action.text = "PICKING"
                action.color = GetRoleTeamColor(ROLE_TEAM_DETECTIVE, "highlight")
            else
                action.text = "BANNING"
                action.color = GetRoleTeamColor(ROLE_TEAM_TRAITOR, "highlight")
            end

            local message = {}
            table.insert(message, {["text"] = "UP FIRST: ", ["color"] = COLOR_WHITE})
            if nextPly == LocalPlayer() then
                table.insert(message, {["text"] = "YOU ARE ", ["color"] = COLOR_WHITE})
            elseif nextTurn.player == nil then
                table.insert(message, {["text"] = "RANDOMLY ", ["color"] = COLOR_WHITE})
            else
                table.insert(message, {["text"] = string.upper(nextPly:Nick()) .. " IS ", ["color"] = COLOR_WHITE})
            end
            table.insert(message, action)
            table.insert(message, {["text"] = " " .. teamArticle[nextTurn.team], ["color"] = COLOR_WHITE})
            table.insert(message, {["text"] = " " .. teamNames[nextTurn.team], ["color"] = GetRoleTeamColor(nextTurn.team, "highlight")})
            for _, text in ipairs(message) do
                text.color = ColorAlpha(text.color, 220)
            end
            DrawColoredText(message, "DraftRegular", x, (ScrH() / 2) + largeIconSize, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        elseif draftPhase > #bottomPositions.order then
            draw.SimpleText("ROLE PACK DRAFT FINISHED", "DraftLarge", x, ScrH() / 2, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("A NEW ROUND WILL BEGIN SOON", "DraftRegular", x, (ScrH() / 2) + largeIconSize, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local turn = bottomPositions.order[draftPhase]
            local ply = player.GetBySteamID64(turn.player)

            local action = {}
            if turn.action == "pick" then
                action.text = "PICKING"
                action.color = GetRoleTeamColor(ROLE_TEAM_DETECTIVE, "highlight")
            else
                action.text = "BANNING"
                action.color = GetRoleTeamColor(ROLE_TEAM_TRAITOR, "highlight")
            end

            local actionShort = {}
            if turn.action == "pick" then
                actionShort.text = "PICK"
                actionShort.color = GetRoleTeamColor(ROLE_TEAM_DETECTIVE, "highlight")
            else
                actionShort.text = "BAN"
                actionShort.color = GetRoleTeamColor(ROLE_TEAM_TRAITOR, "highlight")
            end

            local message = {}
            if ply == LocalPlayer() then
                table.insert(message, {["text"] = "YOUR TURN TO ", ["color"] = COLOR_WHITE})
                table.insert(message, actionShort)
            elseif turn.player == nil then
                table.insert(message, {["text"] = "RANDOMLY ", ["color"] = COLOR_WHITE})
                table.insert(message, action)
            else
                table.insert(message, {["text"] = string.upper(ply:Nick()) .. " IS ", ["color"] = COLOR_WHITE})
                table.insert(message, action)
            end
            table.insert(message, {["text"] = " " .. teamArticle[turn.team], ["color"] = COLOR_WHITE})
            table.insert(message, {["text"] = " " .. teamNames[turn.team], ["color"] = GetRoleTeamColor(turn.team, "highlight")})
            DrawColoredText(message, "DraftLarge", x, (ScrH() - largeIconSize) / 2 - (0.5 * largeIconMargin), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

            -- y = (ScrH() + largeIconSize) / 2 + largeIconMargin + smallIconMargin
            draw.NoTexture()
            surface.SetDrawColor(COLOR_WHITE)
            surface.DrawRect(centrePositions[turn.team].x - smallIconSize, centreDivY, ScrW() + (2 * smallIconSize) - (2 * centrePositions[turn.team].x), groupDividerWidth / 2)
            messageY = centreDivY + (2 * smallIconMargin)

            if draftPhase > 1 then
                local lastTurn = bottomPositions.order[draftPhase - 1]
                local lastPly = player.GetBySteamID64(lastTurn.player)

                action = {}
                if lastTurn.action == "pick" then
                    action.text = "PICKED"
                    action.color = GetRoleTeamColor(ROLE_TEAM_DETECTIVE, "highlight")
                else
                    action.text = "BANNED"
                    action.color = GetRoleTeamColor(ROLE_TEAM_TRAITOR, "highlight")
                end

                message = {}
                if lastPly == LocalPlayer() then
                    table.insert(message, {["text"] = "YOU ", ["color"] = COLOR_WHITE})
                    if randomSelection then
                        table.insert(message, {["text"] = "RAN OUT OF TIME AND RANDOMLY ", ["color"] = COLOR_WHITE})
                    end
                elseif lastTurn.player == nil then
                    table.insert(message, {["text"] = "RANDOMLY ", ["color"] = COLOR_WHITE})
                else
                    if randomSelection then
                        table.insert(message, {["text"] = string.upper(lastPly:Nick()) .. " RAN OUT OF TIME AND RANDOMLY ", ["color"] = COLOR_WHITE})
                    else
                        table.insert(message, {["text"] = string.upper(lastPly:Nick()) .. " ", ["color"] = COLOR_WHITE})
                    end
                end
                table.insert(message, action)
                table.insert(message, {["text"] = " " .. string.upper(ROLE_STRINGS[previousSelection]), ["color"] = GetRoleTeamColor(lastTurn.team, "highlight")})
                for _, text in ipairs(message) do
                    text.color = ColorAlpha(text.color, 220)
                end
                DrawColoredText(message, "DraftSmall", x, messageY, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

                messageY = messageY + (0.65 * largeIconSize)
            end

            if draftPhase < #bottomPositions.order then
                local nextTurn = bottomPositions.order[draftPhase + 1]
                local nextPly = player.GetBySteamID64(nextTurn.player)

                action = {}
                if nextTurn.action == "pick" then
                    action.text = "PICKING"
                    action.color = GetRoleTeamColor(ROLE_TEAM_DETECTIVE, "highlight")
                else
                    action.text = "BANNING"
                    action.color = GetRoleTeamColor(ROLE_TEAM_TRAITOR, "highlight")
                end

                message = {}
                table.insert(message, {["text"] = "UP NEXT: ", ["color"] = COLOR_WHITE})
                if nextPly == LocalPlayer() then
                    table.insert(message, {["text"] = "YOU ARE ", ["color"] = COLOR_WHITE})
                elseif nextTurn.player == nil then
                    table.insert(message, {["text"] = "RANDOMLY ", ["color"] = COLOR_WHITE})
                else
                    table.insert(message, {["text"] = string.upper(nextPly:Nick()) .. " IS ", ["color"] = COLOR_WHITE})
                end
                table.insert(message, action)
                table.insert(message, {["text"] = " " .. teamArticle[nextTurn.team], ["color"] = COLOR_WHITE})
                table.insert(message, {["text"] = " " .. teamNames[nextTurn.team], ["color"] = GetRoleTeamColor(nextTurn.team, "highlight")})
                for _, text in ipairs(message) do
                    text.color = ColorAlpha(text.color, 220)
                end
                DrawColoredText(message, "DraftSmall", x, messageY, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            -- Draw dividing line above preview row
            surface.DrawRect(centrePositions[turn.team].x, messageY + 38 + (2 * smallIconMargin), ScrW() - (2 * centrePositions[turn.team].x), groupDividerWidth / 2)
        end

        if draftPhase < #bottomPositions.order then
            local nextTurn = bottomPositions.order[draftPhase + 1]
            local nextPly = player.GetBySteamID64(nextTurn.player)
            if nextPly == LocalPlayer() then
                x = ScrW() / 2
                -- y = (3 * smallIconSize) + (4 * smallIconMargin)
                draw.SimpleText("YOU ARE UP NEXT", "DraftSmall", x, upNextY, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        end
    end
end)

-- Block scoreboard if player holds tab to hover preview icons and see role descriptions
hook.Add("ScoreboardShow", "RoleDraft_BlockScoreboardShow", function()
    if draftPhase >= 0 then
        return true
    end
end)

-- Enable cursor if player holds tab (need to do this manually as we're blocking the scoreboard)
hook.Add("PlayerButtonDown", "RoleDraft_EnableMouseClicker", function(_, button)
    if button ~= KEY_TAB then return end
    if draftPhase < 0 then return end

    if not gui.EnableScreenClicker() then
        gui.EnableScreenClicker(true)
    end
end)

-- Disable the cursor on tab release UNLESS it was auto-enabled because it's their turn to pick (i.e. don't mess with current functionality)
hook.Add("PlayerButtonUp", "RoleDraft_DisableMouseClicker", function(_, button)
    if button ~= KEY_TAB then return end
    if draftPhase < 0 or mouseAutoEnabled then return end

    if gui.EnableScreenClicker() then
        gui.EnableScreenClicker(false)
    end
end)