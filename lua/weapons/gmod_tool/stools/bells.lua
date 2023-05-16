TOOL.Category   = "Metro"
TOOL.Name       = "Vitro's Bells Tool"
TOOL.Command    = nil
TOOL.ConfigName = ""
TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

if CLIENT then
	language.Add("Tool.bells.name", "Bells Tool")
	language.Add("Tool.bells.desc", "Adds or modifies bells")
	language.Add("Tool.bells.left", "Spawn bell")
	language.Add("Tool.bells.right", "Remove bell")
	language.Add("Tool.bells.reload", "")
end

if SERVER then util.AddNetworkString "vitromod_belltool_send" end
TOOL.settings = TOOL.settings or {}
TOOL.settings.name = TOOL.settings.name or 'test'

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if not VitroMod then return false end
	if not self.settings then return false end
	if not self.settings.name then return false end
	local userOffset = Vector(self.settings.XOffset, self.settings.YOffset, self.settings.ZOffset)
	VitroMod.bellAtLook(trace, ply, self.settings.name, userOffset)
	return true
end

function TOOL:RightClick(trace)
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if CLIENT then return true end
	VitroMod.bellRemove(trace)
	return true
end

function TOOL:Reload(trace)
end

function TOOL:Deploy()
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if SERVER then
		VitroMod.bellSend()
		VitroMod.BellCap = true
		VitroMod.bellSendCap(ply)
	end
end

function TOOL:Holster()
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if SERVER then
		VitroMod.BellCap = false
		VitroMod.bellSendCap(ply)
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

function TOOL:Initialize()
	self:SendSettings = function()
		if not self.settings.name then return end
		net.Start "vitromod_belltool_send"
		net.WriteTable(self.settings)
		net.SendToServer()
	end
end

net.Receive("vitromod_belltool_send", function(_, ply)
    local TOOL = LocalPlayer and LocalPlayer():GetTool("bells") or ply:GetTool("bells")
    TOOL.settings = net.ReadTable()
    if CLIENT then
        NeedUpdate = true
    end
end)

function TOOL:BuildCPanel()
    local CPanel = controlpanel.Get("bells")
    if not CPanel then return end
	local tool = self
    CPanel:ClearControls()
    CPanel:SetPadding(0)
    CPanel:SetSpacing(0)
    CPanel:Dock( FILL )

	tool.settings = tool.settings or {}
	tool.settings.name = tool.settings.name or 'test'		

    local VRightNum = CPanel:TextEntry("Name:")
    VRightNum:SetValue(tool.settings.name)
	function VRightNum:OnChange()
		tool.settings.name = self:GetValue()
		tool:SendSettings()
	end
	local VXOffT = CPanel:NumSlider("X Offset:",nil,-100,100,0)
	VXOffT:SetValue(tool.settings.YOffset or 0)
	VXOffT.OnValueChanged = function(num)
		tool.settings.XOffset = VXOffT:GetValue()
		tool:SendSettings()
	end
	local VYOffT = CPanel:NumSlider("Y Offset:",nil,-100,100,0)
	VYOffT:SetValue(tool.settings.YOffset or 0)
	VYOffT.OnValueChanged = function(num)
		tool.settings.YOffset = VYOffT:GetValue()
		tool:SendSettings()
	end
	local VZOffT = CPanel:NumSlider("Z Offset:",nil,-100,100,0)
	VZOffT:SetValue(tool.settings.ZOffset or 0)
	VZOffT.OnValueChanged = function(num)
		tool.settings.ZOffset = VZOffT:GetValue()
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