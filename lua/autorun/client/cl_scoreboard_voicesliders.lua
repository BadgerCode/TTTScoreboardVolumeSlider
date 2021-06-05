local function RenderVoiceSlider(ply)
    local width = 300
    local height = 50
    local padding = 10

    local x = math.max(gui.MouseX() - width, 0)
    local y = math.min(gui.MouseY(), ScrH() - height)

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

    -- TODO: Keep this timer?
    timer.Simple(10, function()
        if IsValid(frame) then
            frame:Close()
        end
    end)

    local currentValue = ply:GetVoiceVolumeScale()
    currentValue = currentValue != nil and currentValue or 1


    local label = vgui.Create("DLabel", frame)
    label:SetPos(padding, padding)
    label:SetFont("cool_small")
    label:SetSize(width - padding * 2, 20)
	label:SetColor(Color(255, 255, 255, 255))
    label:SetText("Player Volume")


    local sliderHeight = 16
    local sliderDisplayHeight = 8

    local slider = vgui.Create( "DSlider", frame)
	slider:SetHeight(sliderHeight)
    slider:Dock(TOP)
    slider:DockMargin(padding, 0, padding, 0)
    slider:SetSlideX(currentValue)
	slider:SetLockY(0.5)
	slider.TranslateValues = function(slider, x, y)
        ply:SetVoiceVolumeScale(x)
        return x, y
    end

    local oldOnMouseReleased = slider.OnMouseReleased
    slider.OnMouseReleased = function(panel, mcode)
		frame:Close()
	end

    local oldKnobOnMouseReleased = slider.Knob.OnMouseReleased
	slider.Knob.OnMouseReleased = function(panel, mcode)
		frame:Close()
	end

    slider.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, sliderDisplayHeight / 2, w, sliderDisplayHeight, Color(200, 46, 46, 255))
    end

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

-- TODO: remove, or turn into a proper command with a player target
concommand.Remove("test_volume_slider")
concommand.Add("test_volume_slider", function( ply, cmd, args )
    print("Rendering volume slider")

    RenderVoiceSlider(ply)
end)



print("Reloading volume slider") -- TODO: Delete

hook.Remove("TTTScoreboardColumns", "TTTScoreboardMenuVoiceSliders")
hook.Add("TTTScoreboardColumns","TTTScoreboardMenuVoiceSliders", function(pnl)
    
    -- Skip the header row
    if pnl.GetPlayer == nil then return end

    -- Wait for the scoreboard to finish adding the mute (voice) button, before trying to modify it
    -- We have to wait for the panel's player to be set too
    timer.Simple(1, function()
        pnl.voice.DoRightClick = function()
            local rowPlayer = pnl:GetPlayer()
            if (rowPlayer == LocalPlayer() or not IsValid(rowPlayer)) then return end

            RenderVoiceSlider(rowPlayer)
        end
    end)
end)
