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
	local userAngle = Angle(self.settings.pitch, self.settings.yaw, self.settings.roll)
	VitroMod.Bells.atLook(trace, ply, self.settings.name, userOffset, userAngle)
	return true
end

function TOOL:RightClick(trace)
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if CLIENT then return true end
	VitroMod.Bells.remove(trace)
	return true
end

function TOOL:Reload(trace)
end

function TOOL:Deploy()
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if SERVER then
		VitroMod.Bells.send(ply)
		VitroMod.Bells.Caption = true
		VitroMod.Bells.sendCap(ply)
	end
end

function TOOL:Holster()
	local ply = self:GetOwner()
	if (ply:IsValid()) and (not ply:IsAdmin()) then return false end
	if SERVER then
		VitroMod.Bells.Caption = false
		VitroMod.Bells.sendCap(ply)
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
	net.Start "vitromod_belltool_send"
	net.WriteTable(self.settings)
	net.SendToServer()
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
	
    local VRightNum = CPanel:TextEntry("Name:")
	tool.settings = tool.settings or {}
	tool.settings.name = tool.settings.name or 'test'	
    VRightNum:SetValue(tool.settings.name)
	function VRightNum:OnChange()
		tool.settings.name = self:GetValue()
		SendSettings(tool)
	end
	local VXOffT = CPanel:NumSlider("X Offset:",nil,-100,100,0)
	VXOffT:SetValue(tool.settings.YOffset or 0)
	VXOffT.OnValueChanged = function(num)
		tool.settings.XOffset = VXOffT:GetValue()
		SendSettings(tool)
	end
	local VYOffT = CPanel:NumSlider("Y Offset:",nil,-100,100,0)
	VYOffT:SetValue(tool.settings.YOffset or 0)
	VYOffT.OnValueChanged = function(num)
		tool.settings.YOffset = VYOffT:GetValue()
		SendSettings(tool)
	end
	local VZOffT = CPanel:NumSlider("Z Offset:",nil,-100,100,0)
	VZOffT:SetValue(tool.settings.ZOffset or 0)
	VZOffT.OnValueChanged = function(num)
		tool.settings.ZOffset = VZOffT:GetValue()
		SendSettings(tool)
	end	
	local pitch = CPanel:NumSlider("Pitch",nil,0,360,0)
	pitch:SetValue(tool.settings.pitch or 0)
	pitch.OnValueChanged = function(num)
		tool.settings.pitch = pitch:GetValue()
		SendSettings(tool)
	end	
	local yaw = CPanel:NumSlider("Yaw",nil,0,360,0)
	yaw:SetValue(tool.settings.yaw or 0)
	yaw.OnValueChanged = function(num)
		tool.settings.yaw = yaw:GetValue()
		SendSettings(tool)
	end
	local roll = CPanel:NumSlider("Roll",nil,0,360,0)
	roll:SetValue(tool.settings.roll or 0)
	roll.OnValueChanged = function(num)
		tool.settings.roll = roll:GetValue()
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