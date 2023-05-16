TOOL.Category   = "Metro"
TOOL.Name       = "Vitro's Trigger Tool"
TOOL.Command    = nil
TOOL.ConfigName = ""
TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

if CLIENT then
	language.Add("Tool.trig_tool.name", "Trigger Tool")
	language.Add("Tool.trig_tool.desc", "Adds or modifies triggers")
	language.Add("Tool.trig_tool.left", "Set/Update start of the trigger")
	language.Add("Tool.trig_tool.right", "Set/Update end of the trigger")
	language.Add("Tool.trig_tool.reload", "Remove trigger")
end

if SERVER then util.AddNetworkString "vitromod_trigger_send" end
TOOL.settings = TOOL.settings or {}
TOOL.settings.name = TOOL.settings.name or 'test'

function TOOL:LeftClick(trace)
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if CLIENT then return true end
	if not VitroMod.trigInit then return false end
	if not VitroMod.Triggers then return false end
	local newnum = nil
	local pos = trace.HitPos
	local ang = Angle(0,0,0)
	local name = self.settings.name
    local tr = Metrostroi.RerailGetTrackData(trace.HitPos,ply:GetAimVector())
    if tr then pos = tr.centerpos end
	if tr then ang = tr.right:Angle() end	
	for k,v in pairs(ents.FindInSphere(trace.HitPos, 45)) do
		if v:GetClass() == 'gmod_vitromod_trigger' then
			if pos:Distance(v.beg) < 40 then
				--pos = v:GetPos()
				name = v:GetName()
				newnum = v.num
				break
			end
		end
	end
	VitroMod.moveTrig(name,newnum,pos,ang)
	--if newnum == nil then self.settings.newlast = true end
	return true
end


function TOOL:RightClick(trace)
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if CLIENT then return true end
	VitroMod.Triggers = VitroMod.Triggers or {}
	lastnum = 1
	if VitroMod.Triggers.Entities[self.settings.name] then lastnum = #VitroMod.Triggers.Entities[self.settings.name] end
	local pos = trace.HitPos
	local ang = Angle(0,0,0)	
    local tr = Metrostroi.RerailGetTrackData(trace.HitPos,ply:GetAimVector())
    if tr then pos = tr.centerpos end
	if tr then ang = tr.right:Angle() end
	local r = true
	local findnum = nil
	for k,v in pairs(ents.FindInSphere(trace.HitPos, 45)) do
		if v:GetClass() == 'gmod_vitromod_trigger' then
			--r = true
			if pos:Distance(v.fin) < 100 then
				--pos = v:GetPos()
				name = v:GetName()
				findnum = v.num
				break
			end
		end
	end
	if findnum ~= nil then lastnum = findnum end
	VitroMod.setTrigEnd(self.settings.name,lastnum,pos)
	return r
end

function TOOL:Reload(trace)
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if CLIENT then return true end
	local Vt = nil
	for k,v in pairs(ents.FindInSphere(trace.HitPos, 40)) do
		if v:GetClass() == 'gmod_vitromod_trigger' then
			--VitroMod.trigRemove(v:GetName(), v.num)
			Vt = v
		end
	end
	if Vt then
		VitroMod.trigRemove(Vt:GetName(), Vt.num)
		return true
	end
end

TOOL.NotBuilt = true

function TOOL:Think()
    if CLIENT and (self.NotBuilt or NeedUpdate) then
		self:BuildCPanel()
		self.NotBuilt = false
        NeedUpdate = false
	end
end

function TOOL:SendSettings()
    if not self.settings.name then return end
	net.Start "vitromod_trigger_send"
    net.WriteTable(self.settings)
    net.SendToServer()
end

net.Receive("vitromod_trigger_send", function(_, ply)
    local TOOL = LocalPlayer and LocalPlayer():GetTool("trig_tool") or ply:GetTool("trig_tool")
    TOOL.settings = net.ReadTable()
    if CLIENT then
        NeedUpdate = true
    end
end)

function TOOL:BuildCPanel()
    local CPanel = controlpanel.Get("trig_tool")
    if not CPanel then return end
	local tool = self
    CPanel:ClearControls()
    CPanel:SetPadding(0)
    CPanel:SetSpacing(0)
    CPanel:Dock( FILL )
	
    local VRightNum = CPanel:TextEntry("Name:")
	tool.settings = tool.settings or {}
	tool.settings.name = tool.settings.name or 'test'	
    VRightNum:SetValue(tool.settings.name)
	function VRightNum:OnChange()
		tool.settings.name = self:GetValue()
		tool:SendSettings()
	end
end

function TOOL:DrawToolScreen( width, height )
	-- Draw black background
	surface.SetDrawColor( Color( 20, 20, 20 ) )
	--surface.DrawRect( 0, 0, width, height )
	
	-- Draw white text in middle
	draw.SimpleText( self.settings.name, "DermaLarge", width / 2, height / 2, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end