include('shared.lua')

function ENT:Draw()
  self:DrawModel()
end
VitroMod = VitroMod or {}
VitroMod.Bells = VitroMod.Bells or {}
VitroMod.BellCap = VitroMod.BellCap or false
--VitroMod.isRing = false
net.Receive("vitromod_bell_data", function(len, ply)
    VitroMod.Bells = net.ReadTable()
end)

net.Receive("vitromod_bell_cap", function(len, ply)
    VitroMod.BellCap = net.ReadBool()
end)

net.Receive("vitromod_bell", function(len, ply)
    --VitroMod.isRing = net.ReadEntity()
	local ent = net.ReadEntity()
	local snd = net.ReadBool()
	if not IsValid(ent) then return false end
	if snd then 
		if not ent.isPlaying then ent:Play() end
	else 
		ent:Stp() 
	end
end)

hook.Remove( "HUDPaint", "ToScreenExample")
hook.Add( "HUDPaint", "ToScreenExample", function()
	if not VitroMod.BellCap then return end
	for _, ent in ipairs( VitroMod.Bells ) do

		local point = ent.pos
		local data2D = point:ToScreen() -- Gets the position of the entity on your screen
		if ( not data2D.visible ) then continue end
		draw.SimpleText( ent.name , "DermaLarge", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end

end )

function ENT:Play()
	self:EmitSound( "ambient/bell1.wav", 90, pitch, 1, CHAN_AUTO, 0)
	self.isPlaying = true
end

function ENT:Stp()
	self:StopSound( "ambient/bell1.wav")
	self.isPlaying = false
end
