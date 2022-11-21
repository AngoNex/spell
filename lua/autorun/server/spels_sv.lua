
util.AddNetworkString("UpdatePlayerSpell")

function GiveSpell( ply, spell )
    if istable( ply.TableSpells ) and isspell( spell ) then
        ply.TableSpells[spell.name] =  table.Copy( spell )

        local nettable = {}
        nettable.owner = ply
        nettable.name = spell.name
        nettable.type = "init"

        if istable( nettable ) then
            net.Start("UpdatePlayerSpell")
                net.WriteTable( nettable )
            net.Send( nettable.owner )
        end
    end
end

function SpellRefresh( ply )
    ply.TableSpells = {}
    local nettable = {}
    nettable.owner = ply
    nettable.type = "refresh"

    if istable( nettable ) then
        net.Start("UpdatePlayerSpell")
            net.WriteTable( nettable )
        net.Send( nettable.owner )
    end
    
end

function RemoveSpell( ply, spell )
    if istable( ply.TableSpells ) and isspell( spell ) then
        ply.TableSpells[spell.name] = nil

        local nettable = {}
        nettable.owner = ply
        nettable.name = spell.name
        nettable.type = "remove"

        if istable( nettable ) then
            net.Start("UpdatePlayerSpell")
                net.WriteTable( nettable )
            net.Send( nettable.owner )
        end
    end
end

function SpellCooldown( ply, spell )
    if spell.delay ~= 0 or spell.delay ~= nil then
        spell.cooldown = CurTime() + spell.delay
        spell.startime = CurTime()

        local nettable = {}
        nettable.owner = ply
        nettable.name = spell.name
        nettable.type = "cooldown"

        if istable( nettable ) then
            net.Start("UpdatePlayerSpell")
                net.WriteTable( nettable )
            net.Send( nettable.owner )
        end
    end
end

hook.Add( "PlayerInitialized", "Spells_Base_FullLoadSetup", function( ply )
    ply.TableSpells = ply.TableSpells or {}
    GiveSpell( ply, SPELL_blink)
    GiveSpell( ply, SPELL_reverse)
    GiveSpell( ply, SPELL_wall)
end )

hook.Add( "PlayerLoadout", "Spells_Base_FullLoadSetup", function( ply )
    GiveSpell( ply, SPELL_blink)
    GiveSpell( ply, SPELL_reverse)
    GiveSpell( ply, SPELL_wall)
end )

hook.Add( "PlayerButtonDown", "Spells_Base", function( ply, key )
    if IsFirstTimePredicted() and istable( ply.TableSpells ) then
        local spells = ply.TableSpells

        for name, spell in pairs( spells ) do
            if key == spell.key and (spell.prefunction != false or spell.postfunction != false) then
                if SpellIsReady( ply, spell ) then
                    local nettable = {}
                    nettable.owner = ply
                    nettable.name = spell.name

                    if spell.prefunction != false and spell.prefunction != true then
                        nettable.type = "pre"
                        isfunction( spell.prefunction( ply, spell ) )
                    elseif spell.prefunction == true then
                        nettable.type = "pre"
                    elseif spell.postfunction != false then
                        nettable.type = "post"
                        isfunction( spell.postfunction( ply, spell ) )
                        SpellCooldown( ply, spell )
                    else
                        return
                    end

                    if spell.sendtoclient then
                        nettable.sendtoclient = spel.sendtoclientpre
                    end

                    if istable( nettable ) then
                        net.Start("UpdatePlayerSpell")
                        net.WriteTable( nettable )
                        if nettable.sendtoclient then
                            net.Broadcast()
                        else
                            net.Send( nettable.owner )
                        end
                    end
                end
                return
            end
        end
        return "not key"
    end
end)

hook.Add( "PlayerButtonUp", "Spells_Base", function( ply, key )
	if IsValid( ply ) then
        if IsFirstTimePredicted() and istable( ply.TableSpells ) then
            local spells = ply.TableSpells

            for name, spell in pairs( spells ) do
                if key == spell.key and spell.postfunction != false and spell.prefunction != false then
                    if SpellIsReady( ply, spell ) then
                        isfunction( spell.postfunction( ply, spell ) )
                        SpellCooldown( ply, spell )

                        local nettable = {}
                        nettable.owner = ply
                        nettable.name = spell.name
                        nettable.type = "post"

                        if spell.sendtoclient then
                            nettable.sendtoclient = spell.sendtoclientpost
                        end

                        if istable( nettable ) then
                            net.Start("UpdatePlayerSpell")
                                net.WriteTable( nettable )
                            if nettable.sendtoclient then
                                net.Broadcast()
                            else
                                net.Send( nettable.owner )
                            end
                        end
                    end
                    return
                end
            end
            return "not key"
        end
	end
end)