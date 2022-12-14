AddCSLuaFile()

local DrawTable = {}

hook.Add( "InitPostEntity", "Ready", function()
    local ply = LocalPlayer()
	ply.TableSpells = ply.TablePhaseSpeTableSpells or {}
    PlayerSpellHudToggle( true )
end )

net.Receive("UpdatePlayerSpell", function()
    local nettable = net.ReadTable()

    local ply = LocalPlayer()

    local owner = nettable.owner
    local name = nettable.name
    local type = nettable.type

    hook.Call("UpdatePlayerSpell", nil, ply, owner, type, name)
end)

hook.Add( "UpdatePlayerSpell", "UpdatePlayerSpell", function( ply, owner, type, spellkey, event )
	if IsValid( ply ) and IsValid( owner ) then
        owner.TableSpells = (type == "refresh" and {} ) or owner.TableSpells or {}
        local spell = owner.TableSpells[spellkey]
        if type == "init" then
            -- добавить обилку в массив игрока
            -- в том числе и создать объект spell на стороне клиента
            owner.TableSpells[spellkey] = owner.TableSpells[spellkey] or {}
            table.CopyFromTo( SPELL_LIST[spellkey], owner.TableSpells[spellkey])
        end


        if istable( spell ) then
            if owner == ply then
                if type == "init" then
                    -- обновить текущее значение
                end

                if type == "cooldown" then
                    -- включить отсчёт кд ( ну и худ соответственно тоже )
                    spell.cooldown = CurTime() + spell.delay
                    spell.startime = CurTime()
                    if spell.iconAnim ~= nil then
                        isfunction( spell.iconAnim( spell ) )
                    end
                end

                if type == "remove" then
                    -- удаляет обилку из массива игрока
                    owner.TableSpells[spellkey] = nil
                end

                if type == "event" then
                    -- вызов при ивенте
                end
            end

            if type == "pre" then
                -- включить пре функцию ( например отрисовка траектории )
                -- выключение пре функции должно быть либо при начале пост функции либо при отмене
                spell.prefunction( owner, spell )
            end

            if type == "cancel" then
                -- отмена пре функции если она была активирована
                spell.cancelfunction( owner, spell )
                spell.cooldown = CurTime() + 2
                spell.startime = CurTime()
                if spell.iconAnim ~= nil then
                    isfunction( spell.iconAnim( spell ) )
                end
            end

            if type == "post" then
                -- включить отсчёт кд ( ну и худ соответственно тоже )
                -- включить пост функцию ( само действие )
                -- if spell.postfunction != false then
                --     table.insert( DrawTable, spell.postfunction )
                -- end
                print(" а вот и спел прилетел")
                if spell.postfunction ~= false then
                    spell.postfunction( owner, spell )
                end
            end
        end

    end
end )

function PlayerSpellHudToggle( bool )
    if bool then
        local w, h = ScrW(), ScrH()
        local sw, sh = ScrH()*0.1, ScrH()*0.1
        local ply = LocalPlayer()
        hook.Add("HUDPaint", "PlayerSpell", function()

            for num, func in ipairs( DrawTable ) do
                if isfunction( func ) then
                    func( ply )
                end
            end

            if IsValid(ply) then
                local count = table.Count(ply.TableSpells)
                local size = sw * count
                local x = ( w - (size + 2))/2
                local i = 0

                for name, spell in pairs( ply.TableSpells ) do
                    local y = h

                    surface.SetDrawColor( 0,0,0)
                    surface.DrawRect( x + i * (sw + 2), y - sh, sw, sh )

                    surface.SetDrawColor( 55,55,55)
                    if spell.icon ~= nil then
                        surface.SetMaterial( spell.icon )
                    else
                        draw.NoTexture()
                    end
                    local mult = ( spell.iconSize or 1 )
                    surface.DrawTexturedRectRotated( x + i * (sw + 2) + sw/2, y - sh + sh/2, sw * mult , sh * mult, 0 )

                    if spell.cooldown ~= nil and !SpellIsReady( ply, spell ) then
                        local cd =  ( spell.cooldown - CurTime() ) / spell.delay
                        surface.SetDrawColor( 255,255,255,55)
                        surface.DrawRect( x + i * (sw + 2), y - sh, sw, sh * cd )
                        draw.SimpleText( math.Round( spell.cooldown - CurTime(), 1), "DermaLarge", x + i * (sw + 2) + sw/2, y - sh + sh/2, color_White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                    i = i + 1
                end

            end
        end)
    else
        hook.Remove( "HUDPaint", "PlayerSpell" )
    end
end

PlayerSpellHudToggle( true )
