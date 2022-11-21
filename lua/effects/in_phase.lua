local emitter = nil
local ply = nil
function EFFECT:Init( data )

	local vOffset = data:GetStart()
	self.pos = data:GetOrigin()
	self.npos = vOffset

	self.NumParticles = 180
	self.Particles = {}
	self.emitter = ParticleEmitter( vOffset, true )

	self.anim = 0
	timer.Simple(1,function()
		self.anim = 1
	end)
	timer.Simple(1.5,function()
		self.anim = 2
	end)
	timer.Simple(3,function()
		self.anim = 3
		for i = 1, #self.Particles do
			local rand = math.random(0,360)
			local Pos = Vector( math.sin(rand)*math.Rand( -1, 1 ), math.cos(rand)*math.Rand( -1, 1 ), math.Rand( -1, 1 ) )
			self.Particles[i]:SetVelocity( Pos * 30 )
			self.Particles[i]:SetGravity( Vector( 0, 0, 0 ) )
		end
	end)

	local emitter = self.emitter
	for i = 0, self.NumParticles do
		local rand = math.random(0,360)
		local Pos = Vector( math.sin(rand)*math.Rand( -1, 1 ), math.cos(rand)*math.Rand( -1, 1 ), math.Rand( -1, 1 ) )

		local particle = emitter:Add( "particles/balloon_bit", vOffset + Pos * 8 )
		if ( particle ) then

			particle:SetVelocity( Pos * 1000 )

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 20 )

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
		table.insert( self.Particles, particle )
	end



	local dlight = DynamicLight( self )

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

	if self.anim == 1 then
		for i = 1, #self.Particles do

			self.Particles[i]:SetPos( self.Particles[i]:GetPos() + ( self.npos - self.Particles[i]:GetPos()) / 6.1111 )
		end
	end
	if self.anim == 2 then
		if #self.Particles > 30 then
			for i = 1 , math.random(1,#self.Particles/20) do
				local rand = math.random(1,#self.Particles)
				self.Particles[rand]:SetEndAlpha( 55 )
				self.Particles[rand]:SetGravity( Vector( 0, 0, -20 ) )
				table.remove(self.Particles, rand)
			end
		end
		for i = 1, #self.Particles do
			self.Particles[i]:SetPos( self.Particles[i]:GetPos() + ( self.pos - self.Particles[i]:GetPos()) / 11.1111 )
		end
	end
	return self.emitter:GetNumActiveParticles() > 0
end

function EFFECT:Render()

end