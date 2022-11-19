AddCSLuaFile()

local SpelList = {
    ["Blink"] = { delay = 5,
    cooldown = 0,
    timestart = 0,
    prefunction = function( ply )

    end,
    postfunction = function( ply )

    end,
},

}

hook.Add( "InitPostEntity", "Ready", function()
	ply.TablePhaseSpels = ply.TablePhaseSpels or {}
end )

net.Receive("UpdatePlayerSpel", function()
    local nettable = net.ReadTable()

    local ply = LocalPlayer()

    local owner = nettable.owner
    local spel = nettable.spel
    local type = nettable.type

    hook.Call("UpdatePlayerSpel", nil, ply, owner, type, spel)
end)

hook.Add( "UpdatePlayerSpel", "UpdatePlayerSpel", function( ply, owner, type, spel )
	if IsValid( ply ) then

    end
end )