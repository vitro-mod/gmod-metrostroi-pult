include('shared.lua')

function ENT:Draw()
  self:DrawModel()
end
VitroMod = VitroMod or {}
VitroMod.Bells = VitroMod.Bells or {}
VitroMod.BellCap = VitroMod.BellCap or false
net.Receive("vitromod_bell_data", function(len, ply)
    VitroMod.Bells = net.ReadTable()
end)

net.Receive("vitromod_bell_cap", function(len, ply)
    VitroMod.BellCap = net.ReadBool()
end)

net.Receive("vitromod_bell", function(len, ply)
	local rec = net.ReadTable()
	if VitroMod.Bells[rec.name] ~= nil then
		VitroMod.Bells[rec.name]['status'] = rec.status
	end
end)

local function hudName(name, ent)
	if not ent then return end
	if not VitroMod.BellCap then return end

	--for name,ent in pairs( VitroMod.Bells ) do
		local point = ent.pos
		local data2D = point:ToScreen() -- Gets the position of the entity on your screen
		if ( not data2D.visible ) then return end
		draw.SimpleText( name , "DermaLarge", data2D.x, data2D.y, Color( ent.status and 0 or 255, 255, ent.status and 0 or 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	--end
end



function ENT:Play()
	if self.isPlaying then return end
	self:EmitSound( "ambient/bell1.wav", 90, pitch, 1, CHAN_AUTO, 0)
	self.isPlaying = true
end

function ENT:Stop()
	if not self.isPlaying then return end
	self:StopSound( "ambient/bell1.wav")
	self.isPlaying = false
end

function ENT:Think()
	self.name = self.name or self:GetNW2String('Name')
	if not VitroMod.Bells[self.name] then return false end
	local status = VitroMod.Bells[self.name].status
	--&& LocalPlayer():GetPos():DistToSqr( self:GetPos() ) > 7200*7200 )
	if self:IsDormant()  or not status or self.Removing then 
		self:Stop()
	else
		self:Play()
	end
	
	if self:IsDormant() then 
		hook.Remove( "HUDPaint", "VitroMod.Bells.Caption"..self:EntIndex())
	else
		hook.Add( "HUDPaint", "VitroMod.Bells.Caption"..self:EntIndex(), function() hudName(self.name, VitroMod.Bells[self.name]) end)
	end
end

function ENT:OnRemove()
	self:Stop()
end
