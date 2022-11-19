
util.AddNetworkString("UpdatePlayerSpell")

hook.Add( "PlayerInitialSpawn", "Spells_Base_FullLoadSetup", function( ply )
    ply.TableSpells = ply.TableSpells or {}
end )

hook.Add( "PlayerButtonDown", "Spells_Base", function( ply, key )
    if IsFirstTimePredicted() and istable( ply.TableSpells ) then
        local spells = ply.TableSpells

        for name, spell in pairs( spells ) do
            if key == spell.key and (spell.prefunction != false or spell.postfunction != false) then

                local nettable = {}
                nettable.owner = ply
                nettable.spell = name

                if spell.prefunction != false then
                    nettable.type = "pre"
                    spell.prefunction( ply )
                elseif spell.postfunction != false then
                    nettable.type = "post"
                    spell.postfunction( ply )
                else
                    return
                end

                if spell.sendtoclient then
                    nettable.sendtoclient = spel.sendtoclient
                end

                if istable( nettable ) then
                    net.Start("UpdatePlayerSpell")
                        net.WriteTable( nettable )
                    if nettable.sendtoclient then
                        net.Send( nettable.owner )
                    else
                        net.Broadcast()
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
                if key == spell.key and spel.postfunction != false and spell.prefunction != false then
                    isfunction( spell.postfunction( ply ) )

                    local nettable = {}
                    nettable.owner = ply
                    nettable.spell = name
                    nettable.type = "post"

                    if spell.sendtoclient then
                        nettable.sendtoclient = spell.sendtoclient
                    end

                    if istable( nettable ) then
                        net.Start("UpdatePlayerSpell")
                            net.WriteTable( nettable )
                        if nettable.sendtoclient then
                            net.Send( nettable.owner )
                        else
                            net.Broadcast()
                        end
                    end

                    return
                end
            end
            return "not key"
        end
	end
end)