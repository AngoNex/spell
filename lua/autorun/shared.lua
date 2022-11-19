AddCSLuaFile()

local Spell = {}
Spell.__index = Spell

function AddSpell( name )
    return setmetatable( { name = name }, Spell)
end

function isspell( var )
    return getmetatable( var ) = Spell
end

function Spell:Set( key, var )
    self[key] = var
end

function Spell:Get( key )
    return self[key]
end

if SERVER then
    function GiveSpell( ply, spell )
        if istable( ply.TableSpells ) and isspell( spell ) then
            ply.TableSpells[spell.name] = spell
        end
    end

    function RemoveSpell( ply, spell )
        if istable( ply.TableSpells ) and isspell( spell ) then
            table.remove( ply.TableSpells, spell.name)
        end
    end
end