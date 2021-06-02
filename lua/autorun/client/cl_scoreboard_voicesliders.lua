hook.Remove("TTTScoreboardMenu", "TTTScoreboardMenuVoiceSliders")
hook.Add("TTTScoreboardMenu","TTTScoreboardMenuVoiceSliders", function(menu)
    print("Right click TTT row")
end)


local function RenderVoiceSlider(ply, x, y)
    local frame = vgui.Create( "DFrame" )
    frame:SetPos(x, y)
    frame:SetSize( 300, 200 )
    frame:MakePopup()
    frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:SetDraggable(false)
	frame:SetSizable(false)

    local text = vgui.Create("DLabel", frame)
    text:Dock( TOP )
	text:DockMargin( 4, 0, 0, 0 ) -- shift to the right
	text:SetColor( color_black )
    text.UpdateValue = function(self, newValue)
        self:SetText(math.Round(newValue * 100) .. "%")
    end
    text:UpdateValue(ply:GetVoiceVolumeScale())


    local slider = vgui.Create( "DSlider", frame)
    slider:Dock(TOP)
	slider:SetLockY(0.5)
    slider:SetSlideX(ply:GetVoiceVolumeScale())
	slider.TranslateValues = function(slider, x, y)
        ply:SetVoiceVolumeScale(x)
        text:UpdateValue(x)
        return x, y
    end
	slider:SetTrapInside( true )
	slider:Dock( FILL )
	slider:SetHeight( 16 )

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

concommand.Remove("test_volume_slider")
concommand.Add("test_volume_slider", function( ply, cmd, args )
    print("Rendering volume slider")

    RenderVoiceSlider(ply, 500, 500)
end)



print("Reloading volume slider")

hook.Remove("TTTScoreboardColumns", "TTTScoreboardMenuVoiceSliders")
hook.Add("TTTScoreboardColumns","TTTScoreboardMenuVoiceSliders", function(pnl)
    print("Scoreboard initialised")

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

    timer.Simple(1, function()
        local rowPlayer = pnl:GetPlayer()

        if (rowPlayer == LocalPlayer()) then return end
        print("Adding custom voice button for " .. rowPlayer:Nick())


        pnl.voice.DoRightClick = function()
            print("Right clicked on custom voice for " .. rowPlayer:Nick())

            local posX, posY = pnl.voice:GetPos()
            RenderVoiceSlider(rowPlayer, posX, posY)
        end

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
