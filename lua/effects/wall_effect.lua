local emitter = nil
local ply = nil
function EFFECT:Init( data )

	local vOffset = data:GetStart()
	self.pos = data:GetOrigin()
	self.npos = vOffset

	self.NumParticles = 4080
	self.Particles = {}
	self.Particles2 = {}
	self.Particles3 = {}
	self.emitter = ParticleEmitter( vOffset, true )

	self.anim = 0
	timer.Simple(0.5,function()
		self.anim = 1
	end)
	timer.Simple(4.5,function()
		self.anim = 2
	end)

	local emitter = self.emitter
	for i = 0, self.NumParticles do
		local rand = math.random(0,360)
		local Pos = Vector( math.sin(rand)*math.Rand( -1, 1 ), math.cos(rand)*math.Rand( -1, 1 ), 0 )

		local particle = emitter:Add( "particles/balloon_bit", self.pos + Pos * 8 )
		if ( particle ) then

			particle:SetVelocity( Pos * 10 )

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


end

function EFFECT:Think()

	if self.anim == 1 then
		for i = 1 , 40 do
			local rand = math.random(1,#self.Particles)
			table.insert( self.Particles2, self.Particles[rand] )
			table.remove(self.Particles, rand)
		end
		for i = 1, #self.Particles do
			self.Particles[i]:SetPos( self.Particles[i]:GetPos() + ( self.npos - self.Particles[i]:GetPos()) / 81.1111 )
		end
	end
	if self.anim == 2 then
		for i = 1 , 40 do
			local rand = math.random(1,#self.Particles2)
			table.insert( self.Particles3, self.Particles2[rand] )
			table.remove(self.Particles2, rand)
		end
		for i = 1, #self.Particles3 do
			local dot = self.Particles2[math.min(i,#self.Particles2)]
			if i <= #self.Particles2 then
				dot:SetPos( dot:GetPos() + ( Vector( dot:GetPos()[1], dot:GetPos()[2],self.npos[3] + 300) - dot:GetPos()) / 31.1111 )
			end
		end
	end
	return self.emitter:GetNumActiveParticles() > 0
end

function EFFECT:Render()

end