local arc9_lean_direction = nil

hook.Add("CreateMove", "ARC9_CreateMove", function(cmd)
    local wpn = LocalPlayer():GetActiveWeapon()
    local ply = LocalPlayer()

    if !IsValid(wpn) then return end
    if !wpn.ARC9 then return end

    if wpn:GetRequestReload() and !wpn:GetCustomize() and wpn:CanReload() then
        if cmd:TickCount() % 2 == 0 then
            local buttons = cmd:GetButtons()

            buttons = buttons + IN_RELOAD

            cmd:SetButtons(buttons)
        end
    end

    if GetConVar("arc9_autoreload"):GetBool() then
        if wpn:GetUBGL() then
            if !LocalPlayer():KeyDown(IN_USE) and wpn:Clip2() == 0 and wpn:Ammo2() > 0 and wpn:GetNextPrimaryFire() + 0.5 < CurTime() then
                local buttons = cmd:GetButtons()

                buttons = buttons + IN_RELOAD

                cmd:SetButtons(buttons)
            end
        else
            if !LocalPlayer():KeyDown(IN_USE) and wpn:Clip1() == 0 and wpn:Ammo1() > 0 and wpn:GetNextPrimaryFire() + 0.5 < CurTime() then
                local buttons = cmd:GetButtons()

                buttons = buttons + IN_RELOAD

                cmd:SetButtons(buttons)
            end
        end
    end

    if ARC9.KeyPressed_Menu then
        local buttons = cmd:GetButtons()

        buttons = buttons + IN_BULLRUSH

        cmd:SetButtons(buttons)
    end

    if GetConVar("arc9_autolean") then
        if cmd:KeyDown(IN_ATTACK2) then
            if arc9_lean_direction != nil and arc9_lean_direction != 0 then
                local eyepos = ply:EyePos()
                local forward = ply:EyeAngles():Forward()

                local covertrace = util.TraceLine({
                    start = eyepos,
                    endpos = eyepos + forward * 32,
                    filter = ply,
                })

                if !covertrace.Hit then
                    arc9_lean_direction = 0
                    return
                end

                local buttons = cmd:GetButtons()
                if arc9_lean_direction > 0 then
                    buttons = buttons + IN_ALT2
                elseif arc9_lean_direction < 0 then
                    buttons = buttons + IN_ALT1
                end
                cmd:SetButtons(buttons)
            elseif arc9_lean_direction == nil then
                local eyepos = ply:EyePos()
                local right = ply:EyeAngles():Right()
                local forward = ply:EyeAngles():Forward()

                local covertrace = util.TraceLine({
                    start = eyepos,
                    endpos = eyepos + forward * 32,
                    filter = ply,
                })

                if covertrace.Hit then
                    // See if it's valid to lean left

                    arc9_lean_direction = 0

                    local leftleantrace = util.TraceLine({
                        start = eyepos,
                        endpos = eyepos + right * -16,
                        filter = ply,
                    })

                    if !leftleantrace.Hit then
                        // see if it's possible to lean in this direction

                        local leftleantrace2 = util.TraceLine({
                            start = leftleantrace.HitPos,
                            endpos = leftleantrace.HitPos + (forward * 32),
                            filter = ply,
                        })

                        if !leftleantrace2.Hit then
                            arc9_lean_direction = -1
                        end
                    end

                    if arc9_lean_direction == 0 then

                        // See if it's valid to lean right

                        local rightleantrace = util.TraceLine({
                            start = eyepos,
                            endpos = eyepos + right * 16,
                            filter = ply,
                        })

                        if !rightleantrace.Hit then
                            // see if it's possible to lean in this direction

                            local rightleantrace2 = util.TraceLine({
                                start = rightleantrace.HitPos,
                                endpos = rightleantrace.HitPos + (forward * 32),
                                filter = ply,
                            })

                            if !rightleantrace2.Hit then
                                arc9_lean_direction = 1
                            end
                        end

                    end
                end
            end
        else
            arc9_lean_direction = nil
        end
    end
end)