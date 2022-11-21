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
    SPELL_blink:Set( "prefunction", function(ply, spell)
        spell.act = false
        timer.Simple(19,function()
            if spell.act then
                
            else
                SpellCancel( ply, spell )
            end
        end)
    end)
    SPELL_blink:Set( "postfunction", function( ply, spell  )
        if IsValid( ply ) then
            spell.act = true
            local uptrace = util.TraceLine({start = ply:EyePos(),
            endpos = ply:EyePos()+Vector(0,0,500000),
            filter = self,
            collisiongroup = COLLISION_GROUP_DEBRIS})

            local UpPos = uptrace.HitPos

            local trace = util.TraceHull( {
                start = UpPos - Vector(0,0,ply:OBBMaxs()[3]),
                endpos = UpPos + ply:EyeAngles():Forward() * 1000000,
                filter = ply,
                mins = ply:OBBMins(),
                maxs = ply:OBBMaxs(),
            } )
            PointPos = trace.HitPos
            timer.Simple(1.5,function()
                ply:SetPos(PointPos)
                ply:ViewPunch( Angle(10,0,0) )
            end)
        end
    end)
end

if CLIENT then

    -- pretype = render, camera, gybrid

    SPELL_blink:Set( "icon", Material( "https://i.imgur.com/CNndJXr.png", "smooth") )
    SPELL_blink:Set( "iconSize", 1 )
    SPELL_blink:Set( "iconAnim", function( spell )  DefaultAnim( spell ) end)
    SPELL_blink:Set( "pretype", "render" )
    SPELL_blink:Set( "prefunction", function( ply, spell )
        timer.Create("spelliconeblink",0.01,0,function()
            spell.iconSize = 0.8 + math.sin(CurTime()*5)*0.1
        end)

        hook.Add( "PrePlayerDraw", "spellblink", function(pl)
            if pl == ply then
                render.SetBlend( 0 )
            end
        end)

        hook.Add( "PostPlayerDraw", "spellblink", function()
            render.SetBlend( 1 )
        end)

        spell.viewpos = ply:EyePos()
        local uptrace = util.TraceLine({start = ply:EyePos(),
        endpos = ply:EyePos()+Vector(0,0,500000),
        filter = self,
        collisiongroup = COLLISION_GROUP_DEBRIS})
        local LerpPos = 0
        local UpPos = uptrace.HitPos - Vector(0,0,ply:OBBMaxs()[3])

        local Effect = EffectData()
        Effect:SetStart( ply:GetPos() )
        Effect:SetOrigin( UpPos )
        util.Effect("in_phase", Effect)
        if ply ~= LocalPlayer() then return end

        timer.Simple(1.5,function()
            timer.Create("LerpPos",0.01,0,function()
                LerpPos = LerpPos + 0.08
                if LerpPos>= 1 then
                    timer.Remove("LerpPos")
                    LerpPos = 1
                end
            end)
            sound.Play( "player/footsteps/wade6.wav", spell.viewpos, 90, 200 )
        end)
        hook.Add("CalcView","blinkvieweffect",function(ply,origin,angles,fov,znear,zfar)

            local playerview = LerpVector( LerpPos, origin, UpPos )
            spell.viewpos = playerview
            local view = {
                origin = playerview,
                angles = angles,
                fov = fov ,
                znear = znear,
                zfar = zfar,
                drawviewer = true

            }
            return view
        end)


        hook.Add("HUDPaint", "BlinkSpell", function()
            local trace = util.TraceHull( {
                start = UpPos,
                endpos = UpPos + ply:EyeAngles():Forward() * 1000000,
                filter = ply,
                mins = ply:OBBMins(),
                maxs = ply:OBBMaxs(),
            } )
            local PointPos = trace.HitPos
            spell.pos = PointPos
            cam.Start3D()
                render.DrawWireframeBox( PointPos, Angle(0,ply:EyeAngles()[2],0), ply:OBBMins(), ply:OBBMaxs(), color_white )
            cam.End3D()
        end)
    end)

    SPELL_blink:Set( "cancelfunction", function( ply, spell )
        timer.Remove("spelliconeblink")
        local LerpPos = 0
        local Effect = EffectData()
        Effect:SetStart( spell.viewpos )
        Effect:SetOrigin( ply:GetPos() )
        util.Effect("in_phase", Effect)
        timer.Simple(1.55,function()
            timer.Create("LerpPos",0.01,0,function()
                LerpPos = LerpPos + 0.04
                if LerpPos>= 1 then
                    hook.Remove("CalcView","blinkvieweffect")
                    hook.Remove("PrePlayerDraw","spellblink")
                    hook.Remove("PostPlayerDraw","spellblink")
                    hook.Remove("HUDPaint", "BlinkSpell")
                    timer.Remove("LerpPos")

                    LerpPos = 1
                end
            end)
            sound.Play( "player/footsteps/wade6.wav", spell.viewpos, 90, 200 )
            hook.Add("CalcView","blinkvieweffect",function(ply,origin,angles,fov,znear,zfar)

                local playerview = LerpVector( LerpPos, spell.viewpos, ply:GetPos() )

                local view = {
                    origin = playerview,
                    angles = angles,
                    fov = fov1 ,
                    znear = znear,
                    zfar = zfar,
                    drawviewer = true

                }
                return view
            end)
        end)

    end)

    SPELL_blink:Set( "postfunction", function( ply, spell )
        timer.Remove("spelliconeblink")
        local LerpPos = 0
        sound.Play( "common/bass.wav", spell.viewpos, 90, 200 )

        hook.Remove("HUDPaint","BlinkSpell")
        local Effect = EffectData()
        Effect:SetStart( spell.viewpos )
        Effect:SetOrigin( spell.pos + Vector(0,0,40) )
        if ply ~= LocalPlayer() then return end
        util.Effect("in_phase", Effect)
        local fov1 = 20
        timer.Simple(1.55,function()
            timer.Create("LerpPos",0.01,0,function()
                LerpPos = LerpPos + 0.04
                if LerpPos>= 1 then
                    hook.Remove("CalcView","blinkvieweffect")
                    hook.Remove("PrePlayerDraw","spellblink")
                    hook.Remove("PostPlayerDraw","spellblink")
                    timer.Remove("LerpPos")

                    LerpPos = 1
                end
            end)
            sound.Play( "player/footsteps/wade6.wav", spell.viewpos, 90, 200 )
        end)

        hook.Add("CalcView","blinkvieweffect",function(ply,origin,angles,fov,znear,zfar)

            local playerview = LerpVector( LerpPos, spell.viewpos, spell.pos + Vector(0,0,70) )
            fov1 = fov1 + 1

            local view = {
                origin = playerview,
                angles = angles,
                fov = fov1 ,
                znear = znear,
                zfar = zfar,
                drawviewer = true

            }
            return view
        end)

    end)
end

SPELL_reverse = AddSpell( "Reverse" )

SPELL_reverse:Set( "delay", 15 )
SPELL_reverse:Set( "cooldown", 0 )
SPELL_reverse:Set( "timestart", 0 )
SPELL_reverse:Set( "charges", 1 )
--SPELL_reverse:Set( "key", KEY_T )
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
    end)
end


SPELL_wall = AddSpell( "Wall" )

SPELL_wall:Set( "delay", 1 )
SPELL_wall:Set( "cooldown", 0 )
SPELL_wall:Set( "timestart", 0 )
SPELL_wall:Set( "charges", 1 )
SPELL_wall:Set( "key", KEY_T )
SPELL_wall:Set( "sendtoclientpost", true )

if SERVER then
    SPELL_wall:Set( "prefunction", function( ply, spell )
    end)

    SPELL_wall:Set( "postfunction", function( ply, spell  )
    end)
end

if CLIENT then
    SPELL_wall:Set( "icon", Material( "https://i.imgur.com/MTcuCIh.png", "smooth") )
    SPELL_wall:Set( "iconSize", 1 )
    SPELL_wall:Set( "iconAnim", function( spell )  DefaultAnim( spell ) end)

    SPELL_wall:Set( "prefunction", function( ply, spell )
        timer.Create("SPELL_wall_icon",0.01,0,function()
            spell.iconSize = 0.8 + math.sin(CurTime()*5)*0.1
        end)

        hook.Add("HUDPaint", "WallSpell", function()
            local trace = util.TraceHull( {
                start = ply:EyePos(),
                endpos = ply:EyePos() + ply:EyeAngles():Forward() * 2000,
                filter = ply,
                mins = ply:OBBMins(),
                maxs = ply:OBBMaxs(),
            } )
            local PointPos = trace.HitPos
            spell.PointPos = PointPos
            cam.Start3D()
                render.DrawWireframeBox( PointPos, Angle(0,ply:EyeAngles()[2],0), ply:OBBMins(), ply:OBBMaxs(), color_white )
            cam.End3D()
        end)

    end)

    SPELL_wall:Set( "postfunction", function( ply, spell )
        hook.Remove("HUDPaint","WallSpell")
        timer.Remove("SPELL_wall_icon")
        local Effect = EffectData()
        Effect:SetStart( spell.PointPos )
        Effect:SetOrigin( ply:GetPos() )
        util.Effect("wall_effect", Effect)
    end)
end

