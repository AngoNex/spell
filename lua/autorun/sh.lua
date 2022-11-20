AddCSLuaFile()

SPELL_LIST = {}

do
    local Spell = {}
    Spell.__index = Spell

    function AddSpell( name )
        local meta = setmetatable( { name = name, prefunction = false, postfunction = false }, Spell)
        SPELL_LIST[name] = meta
        return meta
    end

    function isspell( var )
        return getmetatable( var ) == Spell
    end

    function Spell:Set( key, var )
        self[key] = var
    end

    function Spell:Get( key )
        return self[key]
    end
end

function SpellIsReady( ply, spell )
    return (( (spell.delay == 0 or spell.delay == nil) or ( ( spell.delay ~= 0 or spell.delay ~= nil) and spell.cooldown <= CurTime() ) ) and spell.charge == nil) or spell.charge == 100
end

SPELL_bl = AddSpell( "Bl" )
SPELL_b = AddSpell( "B" )

SPELL_blink = AddSpell( "Blink" )

SPELL_blink:Set( "delay", 5 )
SPELL_blink:Set( "cooldown", 0 )
SPELL_blink:Set( "timestart", 0 )
SPELL_blink:Set( "charges", 1 )
SPELL_blink:Set( "key", KEY_G )

if SERVER then
    SPELL_blink:Set( "prefunction", true)
    SPELL_blink:Set( "postfunction", function( ply )
        if IsValid( ply ) then
            local trace = util.TraceHull( {
                start = ply:EyePos(),
                endpos = ply:EyePos() + ply:EyeAngles():Forward() * 1000,
                filter = ply,
                mins = ply:OBBMins(),
                maxs = ply:OBBMaxs(),
            } )
            PointPos = trace.HitPos
            ply:SetPos(PointPos)
        end
    end)
end

if CLIENT then

    -- pretype = render, camera, gybrid
    local function DefaultAnim( spell )
        if istable( spell ) then
            spell.iconSize = 0.8
            timer.Simple( spell.delay, function()
                if istable( spell ) and spell.cooldown <= CurTime() then
                    local frac = 0
                    timer.Create( "anim"..spell.name, 0.01, 0, function()
                        if istable( spell ) then
                            frac = frac + FrameTime()
                            if frac >= 1 then
                                timer.Remove( "anim"..spell.name )
                            end
                            spell.iconSize = 0.8 + math.ease.InOutElastic(frac) * 0.2
                        else
                            timer.Remove( "anim"..spell.name )
                        end
                    end)
                end
            end)
        end
    end

    SPELL_blink:Set( "icon", Material( "https://i.imgur.com/CNndJXr.png", "smooth") )
    SPELL_blink:Set( "iconSize", 1 )
    SPELL_blink:Set( "iconAnim", function( spell )  DefaultAnim( spell ) end)
    SPELL_blink:Set( "pretype", "render" )
    SPELL_blink:Set( "prefunction", function( ply )

        local trace = util.TraceHull( {
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * 1000,
			filter = ply,
			mins = ply:OBBMins(),
			maxs = ply:OBBMaxs(),
		} )
		PointPos = trace.HitPos

		cam.Start3D()
			render.DrawWireframeBox( PointPos, Angle(0,ply:EyeAngles()[2],0), ply:OBBMins(), ply:OBBMaxs(), color_white )
		cam.End3D()

    end)

    SPELL_blink:Set( "postfunction", function( ply )
        local Effect = EffectData()
        Effect:SetEntity( ply )
        util.Effect("in_phase", Effect)
    end)
end
