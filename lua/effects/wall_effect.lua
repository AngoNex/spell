local emitter = nil
local ply = nil
function EFFECT:Init( data )

	local vOffset = data:GetStart()
	self.pos = data:GetOrigin()
	self.npos = vOffset

	self.NumParticles = 2000

	self.emitter = ParticleEmitter( vOffset, true )

	local part = {}
	self.part = {}
	local emitter = self.emitter

	for i = 0, 100 do
		local Pos = LerpVector( i / 100, self.pos, self.npos)
		timer.Simple(i/100,function()
			local particle = emitter:Add( "particles/balloon_bit", Pos)
			if ( particle ) then

				particle:SetVelocity( Vector(0,0,0) )

				particle:SetLifeTime( 0 )
				particle:SetDieTime( 20 )

				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 555 )

				local Size = math.Rand( 1, 3 )
				particle:SetStartSize( Size )
				particle:SetEndSize( 0 )

				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -2, 2 ) )

				particle:SetAirResistance( 100 )
				particle:SetGravity( Vector( 0, 0, -1550 ) )

				particle:SetColor( 255, 255, 255 )

				particle:SetCollide( true )
				particle:SetCollide( true )
				particle:SetCollideCallback( function( part, hitpos, hitnormal ) 
					sound.Play( "garrysmod/ui_hover.wav", hitpos, 90, math.random( 90, 120 ) )
				end )
				particle:SetAngleVelocity( Angle( math.Rand( -160, 160 ), math.Rand( -160, 160 ), math.Rand( -160, 160 ) ) )

				particle:SetBounce( 0 )
				particle:SetLighting( false )

				table.insert(part,particle)
			end
		end)
	end

	local NumParticles = self.NumParticles
	local pos = self.pos
	local npos = self.npos
	local part2 = self.part
	timer.Simple(1.6 ,function()
		sound.Play( "garrysmod/save_load1.wav",  part[1]:GetPos(), 90, math.random( 90, 120 ) )
		
		for i = 0, NumParticles - 100 do
			timer.Simple( math.floor(i/9)/120,function()
			local Pos = part[math.min(1 + math.floor(i/18.5),100)]:GetPos()

			local particle = emitter:Add( "particles/balloon_bit", Pos)
			if ( particle ) then
				
					particle:SetVelocity( Vector(0,0,i%10 *60) )
					particle:SetGravity( Vector( math.random(-2,2), math.random(-2,2), math.random(-5,5) ) )
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 20 )

				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 555 )

				local Size = math.Rand( 1, 3 )
				particle:SetStartSize( Size )
				particle:SetEndSize( 0 )

				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -2, 2 ) )

				particle:SetAirResistance( 100 )

				particle:SetColor( 255, 255, 255 )

				particle:SetCollide( true )

				particle:SetAngleVelocity( Angle( math.Rand( -160, 160 ), math.Rand( -160, 160 ), math.Rand( -160, 160 ) ) )

				particle:SetBounce( 1 )
				particle:SetLighting( false )

				if (i)%20 == 9 then
					table.insert( part2, particle)
				end
			end
		end)
		end
	end)


end

function EFFECT:Think()

end

function EFFECT:Render()

end