
util.AddNetworkString("UpdatePlayerSpel")

hook.Add( "PlayerInitialSpawn", "Spels_Base_FullLoadSetup", function( ply )
    ply.TableSpels = ply.TableSpels or {}
end )

hook.Add( "PlayerButtonDown", "Spels_Base", function( ply, key )
	if IsValid( ply ) then
        if IsFirstTimePredicted() and istable( ply.TableSpels ) then
            local spels = ply.TableSpels

            for name, spel in pairs( spels ) do
                if key == spel.key and (spel.prefunction != false or spel.postfunction != false) then

                    local nettable = {}
                    nettable.owner = ply
                    nettable.spel = name

                    if spel.prefunction != false then
                        nettable.type = "pre"
                        spel.prefunction( ply )
                    elseif spel.postfunction != false then
                        nettable.type = "post"
                        spel.postfunction( ply )
                    else
                        return
                    end

                    if spel.sendtoclient then
                        nettable.sendtoclient = spel.sendtoclient
                    end

                    if istable( nettable ) then
                        net.Start("UpdatePlayerSpel")
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

hook.Add( "PlayerButtonUp", "Spels_Base", function( ply, key )
	if IsValid( ply ) then
        if IsFirstTimePredicted() and istable( ply.TableSpels ) then
            local spels = ply.TableSpels

            for name, spel in pairs( spels ) do
                if key == spel.key and spel.postfunction != false and spel.prefunction != false then
                    isfunction( spel.postfunction( ply ) )

                    local nettable = {}
                    nettable.owner = ply
                    nettable.spel = name
                    nettable.type = "post"

                    if spel.sendtoclient then
                        nettable.sendtoclient = spel.sendtoclient
                    end

                    if istable( nettable ) then
                        net.Start("UpdatePlayerSpel")
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