script_name('GameText Replacer')
script_author('Chapo (vk.com/amid24)')

--==[REQUIREMENTS]==--
require 'lib.moonloader'
local vk = require 'vkeys'
local imgui = require('imgui')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'

--==[INICFG]==--
local directIni = 'GameTextReplacer.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        skip = true,
        usecolors = true,
        enabled = true,
    },
    color_back = {
        r = 0.13,
        g = 0.14,
        b = 0.17,
        a = 1.00,
    },
    color_main = {
        r = 1,
        g = 0,
        b = 0.3,
        a = 1.00,
    },
    color_text = {
        r = 1,
        g = 1,
        b = 1,
        a = 1.00,
    },
}, directIni))
inicfg.save(ini, directIni)

--==[IMGUI]==--
local window = imgui.ImBool(false)
local settings = imgui.ImBool(false)
local enabled = imgui.ImBool(ini.main.enabled)
local use_colors = imgui.ImBool(true) 
local show_skip = imgui.ImBool(ini.main.skip)
local color_back = imgui.ImFloat4(ini.color_back.r, ini.color_back.g, ini.color_back.b, ini.color_back.a)
local color_timer = imgui.ImFloat4(ini.color_main.r, ini.color_main.g, ini.color_main.b, ini.color_main.a)
local color_text = imgui.ImFloat4(ini.color_text.r, ini.color_text.g, ini.color_text.b, ini.color_text.a)

--==[NOTIFICATION]==--
local notf_time = 0
local notf_text = 'text example'
local sizeX, sizeY = 100, 50
local size_multiplier = 1

function main()
    while not isSampAvailable() do wait(200) end
    imgui.Process = false
    window.v = false
    settings.v = false
    sampAddChatMessage('{ff004d}[GameText Replacer]:{ffffff} Загружен! Автор: {ff004f}Chapo', -1)
    sampRegisterChatCommand('gametext', function() settings.v = not settings.v end)
    while true do
        wait(0)
        if settings.v or window.v then imgui.Process = true else imgui.Process = false end
        if show_skip.v and window.v and wasKeyPressed(vk.VK_BACK) then window.v = false; notf_time = -1; print('Уведомление "{ff004d}'..notf_text..'{ffffff}" было закрыто.') end
    end
end

local fontsize = nil
function imgui.BeforeDrawFrame()
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end

function imgui.OnDrawFrame()
    resX, resY = getScreenResolution()
    if settings.v then
        sSizeX, sSizeY = 250, 165
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sSizeX / 2, resY / 2 - sSizeY / 2), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(sSizeX, sSizeY), imgui.Cond.Always)
        imgui.Begin('GameText Replacer by chapo', settings, imgui.WindowFlags.NoResize)
        
        imgui.ShowCursor = true
        imgui.Checkbox(u8'Заменять', enabled)
        imgui.Checkbox(u8'Разрешить пропуск (BACKSPACE)', show_skip)
        --imgui.Checkbox(u8'Использовать цвета геймтекста', use_colors)
        imgui.Separator()
        imgui.CenterTextColoredRGB('Настройка цветов:')

        if imgui.ColorEdit4(u8'Цвет заднего фона', color_back, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then save() end
        if imgui.ColorEdit4(u8'Цвет полоски (таймера)', color_timer, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then save() end
        --if imgui.ColorEdit4(u8'Цвет текста', color_text, imgui.ColorEditFlags.AlphaBar + imgui.ColorEditFlags.NoInputs) then save() end

        imgui.SetCursorPosX(5)
        if imgui.Button(u8'Показать тестовый GameText', imgui.ImVec2(sSizeX - 10, 20)) then
            showNotf(2000, '~r~Red ~g~Green ~b~Blue ~p~Purple ~y~Yellow')
        end

        imgui.End()
    end
    if window.v then
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX * size_multiplier / 2, resY / 2 - sizeY / 2 + 300), imgui.Cond.Always)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX * size_multiplier, sizeY), imgui.Cond.Always)
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(color_back.v[1], color_back.v[2], color_back.v[3], color_back.v[4]))
        imgui.Begin('ebat ti loh, skachal ratnik!', window, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)

        if not settings.v then imgui.ShowCursor = false end

        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))

        imgui.SetCursorPosY(7)
        imgui.PushFont(fontsize)
        imgui.CenterTextColoredRGB(notf_text)
        imgui.PopFont()

        imgui.PopStyleColor()

        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 0))
        imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 1))
        imgui.PushStyleColor(imgui.Col.PlotHistogram, imgui.ImVec4(color_timer.v[1], color_timer.v[2], color_timer.v[3], color_timer.v[4]))
        imgui.SetCursorPos(imgui.ImVec2(5, sizeY - 20))
        imgui.ProgressBar(notf_time, imgui.ImVec2(sizeX * size_multiplier - 10, 15))
        imgui.PopStyleColor(3)

        if show_skip.v then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
            imgui.SetCursorPosY(sizeY - 20)
            imgui.CenterTextColoredRGB('Backspace - закрыть')
            imgui.PopStyleColor()
        end
        
        imgui.End()
        imgui.PopStyleColor()
    end
end

function save()
    ini.main.enabled = enabled.v
    ini.main.usecolors = use_colors.v
    ini.main.skip = show_skip.v
    ini.color_back.r, ini.color_back.g, ini.color_back.b, ini.color_back.a = color_back.v[1], color_back.v[2], color_back.v[3], color_back.v[4]
    ini.color_main.r, ini.color_main.g, ini.color_main.b, ini.color_main.a = color_timer.v[1], color_timer.v[2], color_timer.v[3], color_timer.v[4]
    ini.color_text.r, ini.color_text.g, ini.color_text.b, ini.color_text.a = color_text.v[1], color_text.v[2], color_text.v[3], color_text.v[4]

    inicfg.save(ini, directIni)
end

function sampev.onDisplayGameText(style, time, text)
    if enabled.v then
        print()
        showNotf(time, text)
        showCursor(false)
        return false
    end
end

function showNotf(time, text)
    lua_thread.create(function()
        if use_colors.v then
            result = text:gsub('~r~', '{ff0000}')
            result = result:gsub('~g~', '{00a61c}')
            result = result:gsub('~b~', '{3b4eff}')
            result = result:gsub('~w~', '{ffffff}')
            result = result:gsub('~s~', '{ffffff}')
            result = result:gsub('~y~', '{ffe500}')
            result = result:gsub('~p~', '{d900b5}')
            result = result:gsub('~l~', '{000000}')
            result = result:gsub('~n~', ' ')
            
            notf_text = result
        else
            result = text:gsub('~n~', ' ')
            result = result:gsub('~%a~', '')
        end
        sizeX = imgui.CalcTextSize(notf_text).x
        print('Новый GameText ({ff004d}"'..text..'{ffffff}"), заменяю его на уведомление: "{ff004d}'..notf_text..'{ffffff}"!')
        window.v = true
        
        for i = 0, 1, 0.01 do
            if notf_time ~= -1 then
                notf_time = i
                wait(time / 100)
            else
                notf_time = 0
                showCursor(false)
                break
            end
        end
        window.v = false
        showCursor(false)
        
    end)
end

function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end

function applyTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
  
  
    style.WindowPadding = ImVec2(6, 4)
    style.WindowRounding = 15.0
    style.FramePadding = ImVec2(5, 2)
    style.FrameRounding = 15.0
    style.ItemSpacing = ImVec2(7, 5)
    style.ItemInnerSpacing = ImVec2(1, 1)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing = 6.0
    style.ScrollbarSize = 12.0
    style.ScrollbarRounding = 16.0
    style.GrabMinSize = 20.0
    style.GrabRounding = 2.0
  
    style.WindowTitleAlign = ImVec2(0.5, 0.5)

    colors[clr.Border] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.WindowBg] = ImVec4(0.13, 0.14, 0.17, 1.00)
    colors[clr.FrameBg] = ImVec4(0.200, 0.220, 0.270, 0.85)
    colors[clr.TitleBg] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.TitleBgActive] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.Button] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.Separator] = ImVec4(1, 0, 0.3, 1.00)
    --CollapsingHeader
    colors[clr.Header] = ImVec4(1, 0, 0.3, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.68, 0, 0.2, 0.86)
    colors[clr.HeaderActive] = ImVec4(1, 0.24, 0.47, 1.00)
    colors[clr.CheckMark] = ImVec4(1, 0, 0.3, 1.00)
end
applyTheme()



