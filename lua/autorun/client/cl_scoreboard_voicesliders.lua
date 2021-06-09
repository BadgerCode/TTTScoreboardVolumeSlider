hook.Remove("Initialize", "TTTScoreboardMenuVoiceSliders")
hook.Add("Initialize", "TTTScoreboardMenuVoiceSliders", function()
    LANG.AddToLanguage("english", "sb_playervolume", "Player Volume")
end)

local function RenderVoiceSlider(targetPlayer)
    local width = 300
    local height = 50
    local padding = 10

    local sliderHeight = 16
    local sliderDisplayHeight = 8

    local x = math.max(gui.MouseX() - width, 0)
    local y = math.min(gui.MouseY(), ScrH() - height)

    local currentPlayerVolume = targetPlayer:GetVoiceVolumeScale()
    currentPlayerVolume = currentPlayerVolume != nil and currentPlayerVolume or 1


    -- Frame for the slider
    local frame = vgui.Create( "DFrame" )
    frame:SetPos(x, y)
    frame:SetSize(width, height)
    frame:MakePopup()
    frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:SetDraggable(false)
	frame:SetSizable(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(24, 25, 28, 255))
    end

    -- Automatically close after 10 seconds (something may have gone wrong)
    timer.Simple(10, function() if IsValid(frame) then frame:Close() end end)


    -- "Player volume"
    local label = vgui.Create("DLabel", frame)
    label:SetPos(padding, padding)
    label:SetFont("cool_small")
    label:SetSize(width - padding * 2, 20)
	label:SetColor(Color(255, 255, 255, 255))
    label:SetText(LANG.GetTranslation("sb_playervolume"))


    -- Slider
    local slider = vgui.Create("DSlider", frame)
	slider:SetHeight(sliderHeight)
    slider:Dock(TOP)
    slider:DockMargin(padding, 0, padding, 0)
    slider:SetSlideX(currentPlayerVolume)
	slider:SetLockY(0.5)
	slider.TranslateValues = function(slider, x, y)
        targetPlayer:SetVoiceVolumeScale(x)
        return x, y
    end

    -- Close the slider panel once the player has selected a volume
    slider.OnMouseReleased = function(panel, mcode) frame:Close() end
	slider.Knob.OnMouseReleased = function(panel, mcode) frame:Close() end


    -- Slider rendering
    -- Render slider bar
    slider.Paint = function(self, w, h)
        local volumePercent = slider:GetSlideX()

        -- Filled in box
        draw.RoundedBox(5, 0, sliderDisplayHeight / 2, w * volumePercent, sliderDisplayHeight, Color(200, 46, 46, 255))

        -- Grey box
        draw.RoundedBox(5, w * volumePercent, sliderDisplayHeight / 2, w * (1 - volumePercent), sliderDisplayHeight, Color(79, 84, 92, 255))
    end

    -- Render slider "knob" & text
    slider.Knob.Paint = function(self, w, h)
        if(slider:IsEditing()) then
            local textValue = math.Round(slider:GetSlideX() * 100) .. "%"
            local textPadding = 5

            -- The position of the text and size of rounded box are not relative to the text size. May cause problems if font size changes
            draw.RoundedBox(
                5, -- Radius
                -sliderHeight * 0.5 - textPadding, -- X
                -25, -- Y
                sliderHeight * 2 + textPadding * 2, -- Width
                sliderHeight + textPadding * 2, -- Height
                Color(52, 54, 57, 255)
            )
            draw.DrawText(textValue, "cool_small", sliderHeight / 2, -20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        end
        
        draw.RoundedBox(100, 0, 0, sliderHeight, sliderHeight, Color(255, 255, 255, 255))
    end
end


hook.Remove("TTTScoreboardColumns", "TTTScoreboardMenuVoiceSliders")
hook.Add("TTTScoreboardColumns","TTTScoreboardMenuVoiceSliders", function(pnl)
    -- Skip the header row
    if pnl.GetPlayer == nil then return end

    -- Wait for the scoreboard to finish adding the mute (voice) button, before trying to modify it
    -- We have to wait for the panel's player to be set too
    timer.Simple(2, function()
        if pnl.voice == nil then return end

        pnl.voice.DoRightClick = function()
            local rowPlayer = pnl:GetPlayer()
            if (rowPlayer == LocalPlayer() or not IsValid(rowPlayer)) then return end

            -- This addon may be used before the update which adds GetVoiceVolumeScale/SetVoiceVolumeScale
            if rowPlayer.GetVoiceVolumeScale == nil or rowPlayer.SetVoiceVolumeScale == nil then return end

            RenderVoiceSlider(rowPlayer)
        end
    end)
end)

