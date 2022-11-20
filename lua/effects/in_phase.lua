local emitter = nil
local ply = nil
function EFFECT:Init( data )

	local vOffset = data:GetEntity():EyePos()
	ply = data:GetEntity()

	sound.Play( "garrysmod/balloon_pop_cute.wav", vOffset, 90, math.random( 90, 120 ) )

	local NumParticles = 120

	emitter = ParticleEmitter( vOffset, true )

	for i = 0, NumParticles do
		local rand = math.random(0,360)
		local Pos = Vector( math.sin(rand)*math.Rand( -1, 1 ), math.cos(rand)*math.Rand( -1, 1 ), math.Rand( -1, 1 ) )

		local particle = emitter:Add( "particles/balloon_bit", vOffset + Pos * 8 )
		if ( particle ) then

			particle:SetVelocity( Pos * 500 )

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 10 )

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )

			local Size = math.Rand( 1, 3 )
			particle:SetStartSize( Size )
			particle:SetEndSize( 0 )

			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -2, 2 ) )

			particle:SetAirResistance( 100 )
			particle:SetGravity( Vector( 0, 0, math.random(-50,50) ) )

			particle:SetColor( 255, 255, 255 )

			particle:SetCollide( true )

			particle:SetAngleVelocity( Angle( math.Rand( -160, 160 ), math.Rand( -160, 160 ), math.Rand( -160, 160 ) ) )

			particle:SetBounce( 1 )
			particle:SetLighting( false )

		end

	end


	local vOffset = data:GetEntity():GetPos()
	local ent = data:GetEntity()

	local dlight = DynamicLight( ent:EntIndex() )

	if ( dlight ) then

		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 10
		dlight.Size = 512
		dlight.DieTime = CurTime() + 0.02
		dlight.Decay = 512

	end



end

function EFFECT:Think()

end

function EFFECT:Render()

end