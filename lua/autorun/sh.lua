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

SPELL_blink = AddSpell( "Blink" )

SPELL_blink:Set( "delay", 5 )
SPELL_blink:Set( "cooldown", 0 )
SPELL_blink:Set( "timestart", 0 )
SPELL_blink:Set( "charges", 1 )
SPELL_blink:Set( "key", KEY_G )
SPELL_blink:Set( "sendtoclientpost", true )

if SERVER then
    SPELL_blink:Set( "prefunction", true)
    SPELL_blink:Set( "postfunction", function( ply, spell  )
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

SPELL_reverse = AddSpell( "Reverse" )

SPELL_reverse:Set( "delay", 15 )
SPELL_reverse:Set( "cooldown", 0 )
SPELL_reverse:Set( "timestart", 0 )
SPELL_reverse:Set( "charges", 1 )
SPELL_reverse:Set( "key", KEY_T )
SPELL_reverse:Set( "sendtoclientpost", true )

if SERVER then
    SPELL_reverse:Set( "prefunction", function( ply, spell )
        spell.Reverse = {}
        local attach_id = ply:LookupAttachment("chest")
        if (attach_id == nil) or (attach_id == -1) then
            attach_id = 0
        end
        SafeRemoveEntity(spell.trail)
        spell.trail = util.SpriteTrail(ply, attach_id, ply:GetPlayerColor(), true, 17, 60, 20, 1 / ( 17 + 80 ) * 0.5, "sprites/tp_beam001")

        spell.Health = ply:Health()
        timer.Create("spellReverse",0.05,0,function()
            table.insert( spell.Reverse, {ply:GetPos(), ply:EyeAngles()} )
        end)
    end)

    SPELL_reverse:Set( "postfunction", function( ply, spell  )
        timer.Remove("spellReverse")
        local iteration = #spell.Reverse
        if iteration > 1 then
            timer.Create("spellReverse",0.01,0,function()
                ply:SetPos( spell.Reverse[ iteration ][1])
                ply:SetEyeAngles( spell.Reverse[ iteration ][2] )
                iteration = math.max( 1,iteration - 1 )
                if iteration <= 1 then
                    timer.Remove("spellReverse")
                    SafeRemoveEntity(spell.trail)
                    spell.Reverse = {}
                    ply:SetHealth(spell.Health)
                end
            end)
        else
            SafeRemoveEntity(spell.trail)
        end
    end)
end

if CLIENT then
    SPELL_reverse:Set( "icon", Material( "https://i.imgur.com/RTGMJos.png", "smooth") )
    SPELL_reverse:Set( "iconSize", 1 )
    SPELL_reverse:Set( "iconAnim", function( spell )  DefaultAnim( spell ) end)

    SPELL_reverse:Set( "prefunction", function( ply, spell )
        timer.Create("spellReverse",0.01,0,function()
            spell.iconSize = 0.8 + math.sin(CurTime()*5)*0.1
        end)
    end)

    SPELL_reverse:Set( "postfunction", function( ply )
        timer.Remove("spellReverse")
        local Effect = EffectData()
        Effect:SetEntity( ply )
        util.Effect("in_phase", Effect)
    end)
end