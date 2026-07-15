





if not CLIENT then return end

DarkThemeEngine = DarkThemeEngine or {}
DarkThemeEngine.VguiTheme = DarkThemeEngine.VguiTheme or {}

local TAG = "[ThemeEngine VGUI] "
local _active = false
local _originalPaints = {}
local _hookedPanels  = {}





local COL = {
    bg          = Color(26,  26,  26,  255),
    bg2         = Color(34,  34,  34,  255),
    bg3         = Color(42,  42,  42,  255),
    border      = Color(68,  68,  68,  255),
    border2     = Color(85,  85,  85,  255),
    text        = Color(224, 224, 224, 255),
    textDim     = Color(170, 170, 170, 255),
    textDim2    = Color(153, 153, 153, 255),
    accent      = Color(17,  92,  158, 255),
    accentHover = Color(35,  135, 237, 255),
    good        = Color(141, 174, 79,  255),
    warn        = Color(204, 170, 0,   255),
    bad         = Color(204, 51,  0,   255),
    badLight    = Color(213, 85,  85,  255),
    header      = Color(17,  92,  158, 240),
}

local BASE_COL = {}
for k, c in pairs(COL) do
    BASE_COL[k] = Color(c.r, c.g, c.b, c.a)
end

local function ResetPalette()
    for k, c in pairs(BASE_COL) do
        COL[k] = Color(c.r, c.g, c.b, c.a)
    end
end





local function SetColors(pnl)
    if not IsValid(pnl) then return end
    pnl:SetBGColor(COL.bg)
    pnl:SetFGColor(COL.text)
end

local function PaintRoundedBox(pnl, w, h, col, radius)
    radius = radius or 4
    draw.RoundedBox(radius, 0, 0, w, h, col or COL.bg)
end





local SKIP_CLASS = {
    ["DScrollBar"]  = true, ["DScrollBarGrip"] = true,
    ["DListView_Column"] = true, ["DListView_ColumnHeader"] = true,
}

local function ApplyToChildren(pnl, depth)
    depth = depth or 0
    if depth > 8 then return end
    for _, child in ipairs(pnl:GetChildren()) do
        if not IsValid(child) then continue end
        local cls = child:GetClassName()
        if SKIP_CLASS[cls] then continue end

        if cls == "DLabel" or cls == "Label" then
            child:SetTextColor(COL.text)
            child:SetDark(false)
        elseif cls == "DButton" then
            child:SetTextColor(COL.text)
        elseif cls == "DTextEntry" then
            child:SetTextColor(COL.text)
            child:SetCursorColor(COL.text)
            child:SetHighlightColor(COL.accent)
            child:SetPaintBackground(true)
        end

        ApplyToChildren(child, depth + 1)
    end
end

local function RefreshOpenVguiPanels()
    local popups = vgui.GetPopups and vgui.GetPopups() or {}
    for _, pnl in ipairs(popups) do
        if not IsValid(pnl) then continue end
        ApplyToChildren(pnl, 0)
        if pnl.InvalidateLayout then pnl:InvalidateLayout(true) end
    end
end









local function PatchProblemsPanel(pnl)
    if not IsValid(pnl) or _hookedPanels[pnl] then return end
    _hookedPanels[pnl] = true

    local origPaint = pnl.Paint
    pnl.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, COL.bg)
        if origPaint then origPaint(self, w, h) end
    end


    timer.Simple(0.05, function()
        if not IsValid(pnl) then return end
        ApplyToChildren(pnl, 0)


        for _, child in ipairs(pnl:GetChildren()) do
            if not IsValid(child) then continue end
            if child:GetClassName() == "DListView" then
                child:SetLineHeight(22)

                for _, hdr in ipairs(child:GetColumns()) do
                    if IsValid(hdr) then
                        hdr:SetTextColor(COL.text)
                    end
                end
            end
        end
    end)
end





local function PatchWorkshopDownloadPanel(pnl)
    if not IsValid(pnl) or _hookedPanels[pnl] then return end
    _hookedPanels[pnl] = true

    local origPaint = pnl.Paint
    pnl.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        surface.SetDrawColor(COL.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        if origPaint then origPaint(self, w, h) end
    end

    timer.Simple(0.05, function()
        if not IsValid(pnl) then return end
        ApplyToChildren(pnl, 0)

        for _, child in ipairs(pnl:GetChildren()) do
            if not IsValid(child) then continue end
            local cls = child:GetClassName()

            if cls == "DProgress" then

                child.Paint = function(self, w, h)
                    draw.RoundedBox(3, 0, 0, w, h, COL.bg3)
                    surface.SetDrawColor(COL.border)
                    surface.DrawOutlinedRect(0, 0, w, h, 1)
                    local frac = math.Clamp(self:GetFraction(), 0, 1)
                    if frac > 0 then
                        draw.RoundedBox(3, 1, 1, math.floor((w - 2) * frac), h - 2, COL.accent)
                    end
                end
            end
        end
    end)
end



local function PatchDFrame(pnl)
    if not IsValid(pnl) or _hookedPanels[pnl] then return end
    _hookedPanels[pnl] = true

    local origPaint = pnl.Paint
    pnl.Paint = function(self, w, h)

        draw.RoundedBoxEx(6, 0, 0, w, 24, COL.header, true, true, false, false)

        draw.RoundedBoxEx(6, 0, 24, w, h - 24, COL.bg, false, false, true, true)
        surface.SetDrawColor(COL.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    timer.Simple(0.05, function()
        if not IsValid(pnl) then return end
        ApplyToChildren(pnl, 0)
    end)
end







local _origVguiRegister = vgui.Register


local INTERCEPT_CLASSES = {
    ["problems_pnl"]      = PatchProblemsPanel,
    ["WorkshopDownload"]  = PatchWorkshopDownloadPanel,
}

local function SafeWrapRegister()
    if not _origVguiRegister then return end
    vgui.Register = function(name, tab, base)
        local result = _origVguiRegister(name, tab, base)

        local patcher = INTERCEPT_CLASSES[name]
        if patcher and tab then
            local origInit = tab.Init
            tab.Init = function(self, ...)
                if origInit then origInit(self, ...) end
                if _active then
                    timer.Simple(0, function()
                        if IsValid(self) then patcher(self) end
                    end)
                end
            end
        end

        return result
    end
end





local function HookVguiCreate()




    hook.Add("Think", "DTE_VguiTheme_ScanPopups", function()
        if not _active then return end
        for _, pnl in ipairs(vgui.GetWorldPanel and { vgui.GetWorldPanel() } or {}) do

        end

        local popups = vgui.GetPopups and vgui.GetPopups() or {}
        for _, pnl in ipairs(popups) do
            if not IsValid(pnl) or _hookedPanels[pnl] then continue end
            local cls = pnl:GetClassName()
            local patcher = INTERCEPT_CLASSES[cls]
            if patcher then
                patcher(pnl)
            elseif cls == "DFrame" and pnl:GetTitle() ~= "" then

                local title = string.lower(pnl:GetTitle() or "")
                if string.find(title, "problem") or string.find(title, "error")
                or string.find(title, "download") or string.find(title, "workshop") then
                    PatchDFrame(pnl)
                end
            end
        end
    end)
end








local function PatchLoadingPanel(pnl)
    if not IsValid(pnl) or _hookedPanels[pnl] then return end
    _hookedPanels[pnl] = true

    local origPaint = pnl.Paint
    pnl.Paint = function(self, w, h)

        surface.SetDrawColor(COL.bg)
        surface.DrawRect(0, 0, w, h)


        surface.SetDrawColor(COL.accent)
        surface.DrawRect(0, 0, w, 2)

        if origPaint then origPaint(self, w, h) end
    end

    timer.Simple(0.05, function()
        if not IsValid(pnl) then return end
        ApplyToChildren(pnl, 0)
    end)
end

hook.Add("LoadingScreenPanelCreated", "DTE_VguiTheme_LoadingPanel", function(pnl)
    if not _active then return end
    PatchLoadingPanel(pnl)
end)







local _origDermaMsg = Derma_Message
local function WrapDermaMessage()
    if not _origDermaMsg then return end
    Derma_Message = function(text, title, btn, ...)
        local result = _origDermaMsg(text, title, btn, ...)
        if _active and IsValid(result) then
            timer.Simple(0, function()
                if IsValid(result) then PatchDFrame(result) end
            end)
        end
        return result
    end
end

local _origDermaQuery = Derma_Query
local function WrapDermaQuery()
    if not _origDermaQuery then return end
    Derma_Query = function(text, title, ...)
        local result = _origDermaQuery(text, title, ...)
        if _active and IsValid(result) then
            timer.Simple(0, function()
                if IsValid(result) then PatchDFrame(result) end
            end)
        end
        return result
    end
end





local function PatchNotification(pnl)
    if not IsValid(pnl) or _hookedPanels[pnl] then return end
    _hookedPanels[pnl] = true

    local origPaint = pnl.Paint
    pnl.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COL.bg2)
        surface.SetDrawColor(COL.border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        if origPaint then origPaint(self, w, h) end
    end
end

hook.Add("Think", "DTE_VguiTheme_Notifications", function()
    if not _active then return end


end)














local function ApplyVguiThemeJSON(folder)
    if not folder or folder == "" then return end


    local paths = {
        "theme_engine_created_addons/" .. folder .. "/vgui_theme.json",
        "theme_engine_full_themes/"    .. folder .. "/vgui_theme.json",
    }
    local raw
    for _, p in ipairs(paths) do
        raw = file.Read(p, "DATA")
        if raw and raw ~= "" then break end
        raw = file.Read("data_static/" .. p, "GAME")
        if raw and raw ~= "" then break end
    end

    if not raw or raw == "" then
        if DarkThemeEngine_Log then DarkThemeEngine_Log("debug", "VGUI", "No vgui_theme.json for " .. tostring(folder)) end
        return
    end

    local ok, parsed = pcall(util.JSONToTable, raw)
    if not ok or type(parsed) ~= "table" then
        if DarkThemeEngine_Log then DarkThemeEngine_Log("warn", "VGUI", "Invalid vgui_theme.json for " .. tostring(folder)) end
        return
    end

    local function parseColor(key)
        local v = parsed[key]
        if type(v) == "table" and v[1] and v[2] and v[3] then
            return Color(
                math.Clamp(tonumber(v[1]) or 0, 0, 255),
                math.Clamp(tonumber(v[2]) or 0, 0, 255),
                math.Clamp(tonumber(v[3]) or 0, 0, 255),
                math.Clamp(tonumber(v[4]) or 255, 0, 255)
            )
        end
        return nil
    end

    local keys = { "bg", "bg2", "bg3", "border", "border2", "text", "textDim",
                   "textDim2", "accent", "accentHover", "good", "warn", "bad",
                   "badLight", "header" }
    for _, k in ipairs(keys) do
        local c = parseColor(k)
        if c then
            COL[k] = c
        end
    end
end





function DarkThemeEngine.VguiTheme.Activate(folder)
    if _active then return end
    _active = true

    if folder and folder ~= "" then
        ApplyVguiThemeJSON(folder)
    end

    SafeWrapRegister()
    HookVguiCreate()
    WrapDermaMessage()
    WrapDermaQuery()


    local popups = vgui.GetPopups and vgui.GetPopups() or {}
    for _, pnl in ipairs(popups) do
        if not IsValid(pnl) then continue end
        local cls = pnl:GetClassName()
        local patcher = INTERCEPT_CLASSES[cls]
        if patcher then
            patcher(pnl)
        end
    end
end

function DarkThemeEngine.VguiTheme.Deactivate()
    if not _active then return end
    _active = false

    hook.Remove("Think", "DTE_VguiTheme_ScanPopups")
    hook.Remove("Think", "DTE_VguiTheme_Notifications")
    hook.Remove("LoadingScreenPanelCreated", "DTE_VguiTheme_LoadingPanel")


    if _origVguiRegister then
        vgui.Register = _origVguiRegister
    end


    if _origDermaMsg   then Derma_Message = _origDermaMsg   end
    if _origDermaQuery then Derma_Query   = _origDermaQuery end


    _hookedPanels = {}

end






function DarkThemeEngine.VguiTheme.OnThemeChanged(mode)
    if not mode then return end

    if mode == "dark" or mode:sub(1, 7) == "custom:" then
        local folder = mode:sub(1, 7) == "custom:" and mode:sub(8) or nil
        DarkThemeEngine.VguiTheme.Activate(folder)
    elseif mode == "light" then

        DarkThemeEngine.VguiTheme.Deactivate()
    end
end





timer.Simple(0, function()
    local ok, raw = pcall(file.Read, "theme_engine_data/settings.json", "DATA")
    if not ok or not raw or raw == "" then

        DarkThemeEngine.VguiTheme.Activate(nil)
        return
    end

    local s = util.JSONToTable(raw) or {}
    local mode = (s.ThemeOptions and s.ThemeOptions.Mode) or "dark"
    local folder = (s.ThemeOptions and s.ThemeOptions.CustomThemeFolder) or nil

    if mode == "dark" or mode:sub(1, 7) == "custom:" then
        DarkThemeEngine.VguiTheme.Activate(folder)
    end
end)
