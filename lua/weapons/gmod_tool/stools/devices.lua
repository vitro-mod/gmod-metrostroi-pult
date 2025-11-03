TOOL.Category = "Metro"
TOOL.Name = "Vitro's Devices Tool"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Information = {
    { name = "left" },
    { name = "right" },
    { name = "reload" },
}

if CLIENT then
    language.Add("Tool.devices.name", "Devices Tool")
    language.Add("Tool.devices.desc", "Adds or modifies devices")
    language.Add("Tool.devices.left", "Spawn device")
    language.Add("Tool.devices.right", "Remove device")
    language.Add("Tool.devices.reload", "")
end

if SERVER then util.AddNetworkString("vitromod_devicestool_send") end
TOOL.settings = TOOL.settings or {}
function TOOL:LeftClick(trace)
    if not self:CheckAction() then return false end
    VitroMod.Devices[self.settings.Type].atLook(trace, ply, self.settings)
    return true
end

function TOOL:RightClick(trace)
    if not self:CheckAction() then return false end
    VitroMod.Devices[self.settings.Type].remove(trace)
    return true
end

function TOOL:Reload(trace)
    if not self:CheckAction() then return false end
    if VitroMod.Devices[self.settings.Type].scan then
        self.settings = VitroMod.Devices[self.settings.Type].scan(trace, ply, self.settings)
    else
        local deviceConfig = VitroMod.Devices[self.settings.Type]
        local device
        for k, v in pairs(ents.FindInSphere(trace.HitPos, 50)) do
            if v:GetClass() ~= deviceConfig.class then continue end
            local name = v:GetName() or v:GetNW2String("Name", "") or ""
            device = v
            if name == self.settings.Name then break end
        end

        if not IsValid(device) then return false end
        self.settings.Name = device:GetName()
        self.settings.config = device.config
    end

    net.Start("vitromod_devicestool_send")
    net.WriteTable(self.settings)
    net.Send(self:GetOwner())
    return true
end

function TOOL:Deploy()
end

function TOOL:Holster()
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
    if not self.settings.Type then return end
    net.Start"vitromod_devicestool_send"
    net.WriteTable(self.settings)
    net.SendToServer()
end

net.Receive("vitromod_devicestool_send", function(_, ply)
    local TOOL = LocalPlayer and LocalPlayer():GetTool("devices") or ply:GetTool("devices")
    TOOL.settings = net.ReadTable()
    if CLIENT then NeedUpdate = true end
end)

function TOOL:BuildCPanel()
    local CPanel = controlpanel.Get("devices")
    if not CPanel then return end
    local tool = self
    tool.settings = tool.settings or {}
    tool.settings.config = tool.settings.config or {}
    CPanel:ClearControls()
    CPanel:SetPadding(0)
    CPanel:SetSpacing(0)
    CPanel:Dock(FILL)
    local TypeCB = vgui.Create("DComboBox")
    for k, v in SortedPairs(VitroMod.Devices) do
        TypeCB:AddChoice(v.name, k, k == tool.settings.Type)
    end

    function TypeCB:OnSelect(index, text, data)
        tool.settings.Type = data
        tool:SendSettings()
        tool:BuildCPanel()
    end

    CPanel:AddItem(TypeCB)
    tool.device = VitroMod.Devices[tool.settings.Type]
    if not tool.device then return end
    local nameText = CPanel:TextEntry("Name")
    nameText:SetValue(tool.settings.Name or "")
    nameText:SetEnterAllowed(false)
    function nameText:OnChange()
        tool.settings.Name = self:GetValue()
        tool:SendSettings(tool)
    end

    CPanel:AddItem(nameText)
    for _, data in pairs(tool.device.config) do
        if data.depends then
            local toshow = false
            for _, v in pairs(data.depends) do
                if tool.settings.config[v] then
                    toshow = true
                    break
                end
            end

            if not toshow then
                tool.settings.config[data.varName] = nil
                continue
            end
        end

        if data.onList then
            local toshow = false
            for _, v in pairs(data.onList.values) do
                if tool.settings.config[data.onList.varName] == v then
                    toshow = true
                    break
                end
            end

            if not toshow then
                tool.settings.config[data.varName] = nil
                continue
            end
        end

        if data.varType == "bool" then
            local checkbox = CPanel:CheckBox(data.name)
            checkbox:SetValue(tool.settings.config[data.varName] or false)
            function checkbox:OnChange()
                tool.settings.config[data.varName] = self:GetChecked()
                tool:BuildCPanel()
                tool:SendSettings()
            end
        elseif data.varType == "text" then
            local textArea = CPanel:TextEntry(data.name)
            textArea:SetValue(tool.settings.config[data.varName] or "")
            textArea:SetEnterAllowed(false)
            function textArea:OnChange()
                tool.settings.config[data.varName] = self:GetValue()
                tool:SendSettings(tool)
            end
        elseif data.varType == "int" then
            local slider = CPanel:NumSlider(data.name, nil, data.min, data.max, 0)
            slider:SetValue(tool.settings.config[data.varName] or 0)
            function slider:OnValueChanged(newValue)
                tool.settings.config[data.varName] = newValue
                tool:SendSettings(tool)
            end
        elseif data.varType == "list" then
            local combobox = CPanel:ComboBox(data.name)
            for k, v in SortedPairs(data.list) do
                if not tool.settings.config[data.varName] then tool.settings.config[data.varName] = k end
                combobox:AddChoice(v.name, k, k == tool.settings.config[data.varName])
            end

            function combobox:OnSelect(index, text, value)
                tool.settings.config[data.varName] = value
                tool:SendSettings()
                tool:BuildCPanel()
            end
        end
    end
end

function TOOL:DrawToolScreen(width, height)
    -- Draw black background
    surface.SetDrawColor(Color(20, 20, 20))
    --surface.DrawRect( 0, 0, width, height )
    -- Draw white text in middle
    draw.SimpleText(self.settings.Name, "DermaLarge", width / 2, height / 2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function TOOL:CheckPermissions()
    local ply = self:GetOwner()
    if ULib then
        if not ULib.ucl.query(ply, "editsignals", true) then return false end
    else
        if ply:IsValid() and (not ply:IsAdmin()) then return false end
    end
    return true
end

function TOOL:CheckAction()
    if CLIENT then return true end
    if not self:CheckPermissions() then return false end
    if not VitroMod then return false end
    if not self.settings then return false end
    if not self.settings.Type then return false end
    if not VitroMod.Devices[self.settings.Type] then return false end
    return true
end
