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
    timer.Simple(20, function()
        if IsValid(frame) then
            frame:Close()
        end
    end)

    local currentValue = ply:GetVoiceVolumeScale()
    currentValue = currentValue != nil and currentValue or 1



    local text = vgui.Create("DLabel", frame)
    text:SetPos(padding, padding)
    text:SetSize(width - padding * 2, 20)
	text:SetColor(Color(255, 255, 255, 255))
    text.UpdateValue = function(self, newValue)
        self:SetText(math.Round(newValue * 100) .. "%")
    end
    text:UpdateValue(currentValue)
    text:SetContentAlignment(5)



    local slider = vgui.Create( "DSlider", frame)
	slider:SetHeight(16)
    slider:Dock(TOP)
    slider:SetSlideX(currentValue)
	slider:SetLockY(0.5)
	slider.TranslateValues = function(slider, x, y)
        ply:SetVoiceVolumeScale(x)
        text:UpdateValue(x)
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

    Derma_Hook(slider, "Paint", "Paint", "NumSlider")


    -- local DermaNumSlider = vgui.Create( "DNumSlider", DermaPanel )
    -- DermaNumSlider:SetPos( 0, 0 )				-- Set the position
    -- DermaNumSlider:SetSize( 300, 100 )			-- Set the size
    -- DermaNumSlider:SetMin( 0 )				 	-- Set the minimum number you can slide to
    -- DermaNumSlider:SetMax( 100 )				-- Set the maximum number you can slide to
    -- DermaNumSlider:SetDecimals( 0 )				-- Decimal places - zero for whole number
    -- DermaNumSlider:SetValue(ply:GetVoiceVolumeScale() * 100)

    -- -- If not using convars, you can use this hook + Panel.SetValue()
    -- DermaNumSlider.OnValueChanged = function( self, value )
    --     local newVolumeScale = math.Round(value / 100, 3)
    --     print("Value changed to " .. newVolumeScale .. " for " .. ply:Nick())
    --     ply:SetVoiceVolumeScale(newVolumeScale)
    -- end
end

-- TODO: remove, or turn into a proper command with a player target
concommand.Remove("test_volume_slider")
concommand.Add("test_volume_slider", function( ply, cmd, args )
    print("Rendering volume slider")

    RenderVoiceSlider(ply)
end)



print("Reloading volume slider")

hook.Remove("TTTScoreboardColumns", "TTTScoreboardMenuVoiceSliders")
hook.Add("TTTScoreboardColumns","TTTScoreboardMenuVoiceSliders", function(pnl)
    print("Scoreboard initialised") -- TODO: Remove

    -- TODO: Remove
    /*
    self.voice = vgui.Create("DImageButton", self)
    self.voice:SetSize(16,16)

    if self.Player != LocalPlayer() then
        local muted = self.Player:IsMuted()
        self.voice:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
    else
        self.voice:Hide()
    end

    self.voice:SetVisible(not self.open)
    self.voice:SetSize(16, 16)
    self.voice:DockMargin(4, 4, 4, 4)
    self.voice:Dock(RIGHT)

    self.voice.DoClick = function()
        if IsValid(ply) and ply != LocalPlayer() then
            ply:SetMuted(not ply:IsMuted())
        end
    end

    https://wiki.facepunch.com/gmod/DNumSlider



    pnl:AddColumn("ID", function(ply) return ply:UserID() end)
    pnl:GetPlayer()

    1. Wait 1 tick and add a volume slider column
    2. Override paint
    3. Override DoClick/RightClick
    4. Remove other volumne icon?

    */

    
    -- Skip the header row
    if pnl.GetPlayer == nil then return end

    -- This timer allows the scoreboard to add the mute button, which happens after this function runs
    timer.Simple(1, function()
        local rowPlayer = pnl:GetPlayer()

        if (rowPlayer == LocalPlayer()) then return end
        print("Adding custom voice button for " .. rowPlayer:Nick()) -- TODO: Remove

        pnl.voice.DoRightClick = function()
            print("Right clicked on custom voice for " .. rowPlayer:Nick()) -- TODO: Remove

            RenderVoiceSlider(rowPlayer)
        end

        -- TODO: Remove
        -- for _, v in ipairs( pnl:GetChildren() ) do
        --     print( v:GetClassName() )
        -- end

        -- local voiceSlider = vgui.Create("DImageButton", pnl)
        -- voiceSlider:SetSize(16,16)
        -- voiceSlider.Think = function(self)
        --     local muted = rowPlayer:IsMuted()
        --     voiceSlider:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
        -- end
        -- voiceSlider.DoClick = function()
        --     print("Clicked on custom voice")
        --     if IsValid(rowPlayer) then
        --         rowPlayer:SetMuted(not rowPlayer:IsMuted())
        --     end
        -- end

        -- voiceSlider.DoRightClick = function()
        --     print("Right clicked on custom voice")
        --     if not IsValid(rowPlayer) then return end

        --     -- TODO: 
        -- end

        -- voiceSlider:SetVisible(true)
        -- voiceSlider:SetSize(16, 16)
        -- voiceSlider:DockMargin(4, 4, 4, 4)
        -- voiceSlider:Dock(RIGHT)
    end)
end)
