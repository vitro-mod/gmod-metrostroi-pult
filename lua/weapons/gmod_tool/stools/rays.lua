TOOL.Category   = "Metro"
TOOL.Name       = "Vitro's Rays Tool"
TOOL.Command    = nil
TOOL.ConfigName = ""
TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

if CLIENT then
	language.Add("Tool.rays.name", "Rays Tool")
	language.Add("Tool.rays.desc", "Adds or modifies rays")
	language.Add("Tool.rays.left", "Spawn ray")
	language.Add("Tool.rays.right", "Remove ray")
	language.Add("Tool.rays.reload", "")
end

if SERVER then util.AddNetworkString "vitromod_raytool_send" end
TOOL.settings = TOOL.settings or {}
TOOL.settings.name = TOOL.settings.name or 'test'

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if not VitroMod then return false end
	if not self.settings then return false end
	if not self.settings.name then return false end
	VitroMod.Rays.atLook(trace, ply, self.settings.name, self.settings)
	return true
end

function TOOL:RightClick(trace)
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if CLIENT then return true end
	VitroMod.Rays.remove(trace)
	return true
end

function TOOL:Reload(trace)
end

function TOOL:Deploy()
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if SERVER then
		VitroMod.Rays.send(ply)
		VitroMod.Rays.Caption = true
		VitroMod.Rays.sendCap(ply)
	end
end

function TOOL:Holster()
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if SERVER then
		VitroMod.Rays.Caption = false
		VitroMod.Rays.sendCap(ply)
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

local function SendSettings(self)
	if not self.settings.name then return end
	net.Start "vitromod_raytool_send"
	net.WriteTable(self.settings)
	net.SendToServer()
end

net.Receive("vitromod_raytool_send", function(_, ply)
    local TOOL = LocalPlayer and LocalPlayer():GetTool("rays") or ply:GetTool("rays")
    TOOL.settings = net.ReadTable()
    if CLIENT then
        NeedUpdate = true
    end
end)

function TOOL:BuildCPanel()
    local CPanel = controlpanel.Get("rays")
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
		SendSettings(tool)
	end

	local lampXOffset = CPanel:NumSlider("Lamp X Offset:",nil,-100,100,0)
	lampXOffset:SetValue(tool.settings.lampXOffset or 0)
	lampXOffset.OnValueChanged = function(num)
		tool.settings.lampXOffset = lampXOffset:GetValue()
		SendSettings(tool)
	end

	local lampZOffset = CPanel:NumSlider("Lamp Z Offset:",nil,-100,100,0)
	lampZOffset:SetValue(tool.settings.lampZOffset or 0)
	lampZOffset.OnValueChanged = function(num)
		tool.settings.lampZOffset = lampZOffset:GetValue()
		SendSettings(tool)
	end

	local sensorXOffset = CPanel:NumSlider("Sensor X Offset:",nil,-100,100,0)
	sensorXOffset:SetValue(tool.settings.sensorXOffset or 0)
	sensorXOffset.OnValueChanged = function(num)
		tool.settings.sensorXOffset = sensorXOffset:GetValue()
		SendSettings(tool)
	end

	local sensorZOffset = CPanel:NumSlider("Sensor Z Offset:",nil,-100,100,0)
	sensorZOffset:SetValue(tool.settings.sensorZOffset or 0)
	sensorZOffset.OnValueChanged = function(num)
		tool.settings.sensorZOffset = sensorZOffset:GetValue()
		SendSettings(tool)
	end
end

function TOOL:DrawToolScreen( width, height )
	-- Draw black background
	surface.SetDrawColor( Color( 20, 20, 20 ) )
	--surface.DrawRect( 0, 0, width, height )
	
	-- Draw white text in middle
	draw.SimpleText( self.settings.name, "DermaLarge", width / 2, height / 2, Color( 200, 200, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
