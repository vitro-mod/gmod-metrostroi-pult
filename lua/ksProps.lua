SafeRemoveEntity(ssv_kosino_1)
SafeRemoveEntity(ssv_kosino_2)
SafeRemoveEntity(ssv_kosino_3)
SafeRemoveEntity(ssv_kosino_4)
SafeRemoveEntity(ssv_kosino_5)
SafeRemoveEntity(ssv_kosino_6)
SafeRemoveEntity(ssv_kosino_7)
SafeRemoveEntity(ssv_kosino_8)
SafeRemoveEntity(ssv_kosino_9)
SafeRemoveEntity(ssv_kosino_10)
SafeRemoveEntity(ssv_kosino_11)
SafeRemoveEntity(ssv_kosino_12)
SafeRemoveEntity(ssv_kosino_13)
SafeRemoveEntity(ssv_ostryak_1)
SafeRemoveEntity(ssv_ostryak_2)

--Изменить у ssv_kosino_4, ssv_kosino_5, ssv_kosino_7, ssv_kosino_8, ssv_kosino_9, ssv_kosino_11 prop_physics на другой тип.
--Изменить у ssv_kosino_1, ssv_kosino_2, ssv_kosino_3, ssv_kosino_6, ssv_ostryak_1, ssv_ostryak_2, ssv_kosino_10, ssv_kosino_12, ssv_kosino_13 последние три строчки.

ssv_kosino_1 = ents.Create("prop_physics")
ssv_kosino_1:SetModel("models/nekrasovskaya/tunnel_round_povorot_right_2a.mdl")
ssv_kosino_1:SetPos(Vector(-12773.95, -155.9, -12211.25))
ssv_kosino_1:SetAngles(Angle(0, 4, 1.5))
ssv_kosino_1:Spawn()
phys = ssv_kosino_1:GetPhysicsObject()
if (!IsValid(phys)) then return end
phys:EnableMotion(false)

ssv_kosino_3 = ents.Create("prop_physics")
ssv_kosino_3:SetModel("models/nekrasovskaya/tunnel_round_povorot_right_2b.mdl")
ssv_kosino_3:SetPos(Vector(-12681.3, 1368.25, -12171.45))
ssv_kosino_3:SetAngles(Angle(0.3, -10.865, 1))
ssv_kosino_3:Spawn()
phys = ssv_kosino_3:GetPhysicsObject()
if (!IsValid(phys)) then return end
phys:EnableMotion(false)

ssv_kosino_2 = ents.Create("prop_physics")
ssv_kosino_2:SetModel("models/nekrasovskaya/tunnel_round_povorot_right_1c.mdl")
ssv_kosino_2:SetPos(Vector(-12201, 2817.593750, -12146.125))
ssv_kosino_2:SetAngles(Angle(0.1, -25.681, 0.5))
ssv_kosino_2:Spawn()
phys = ssv_kosino_2:GetPhysicsObject()
if (!IsValid(phys)) then return end
phys:EnableMotion(false)

ssv_kosino_4 = ents.Create("prop_physics")
ssv_kosino_4:SetModel("models/nekrasovskaya/tunnel_kvad_round.mdl")
ssv_kosino_4:SetPos(Vector(-11417.968750, 4132.562500, -12132.9))
ssv_kosino_4:SetAngles(Angle(0, 144.311, 0))
ssv_kosino_4:Spawn()

ssv_kosino_5 = ents.Create("prop_physics")
ssv_kosino_5:SetModel("models/nekrasovskaya/tunnel_syezd_kosino_new_a.mdl")
ssv_kosino_5:SetPos(Vector(-9587.256836, 6865.423340, -12132.900391))
ssv_kosino_5:SetAngles(Angle(0, 330.699, 0))
ssv_kosino_5:Spawn()

ssv_kosino_6 = ents.Create("prop_physics")
ssv_kosino_6:SetModel("models/nekrasovskaya/tunnel_syezd_kosino_new_b.mdl")
ssv_kosino_6:SetPos(Vector(-9963.114258, 6195.680664, -12132.900391))
ssv_kosino_6:SetAngles(Angle(0, 150.699, 0))
ssv_kosino_6:Spawn()
local phys = ssv_kosino_6:GetPhysicsObject()
if (!IsValid( phys )) then return end
phys:EnableMotion(false)

ssv_kosino_7 = ents.Create("prop_physics")
ssv_kosino_7:SetModel("models/nekrasovskaya/tunnel_syezd_kosino_new_c.mdl")
ssv_kosino_7:SetPos(Vector(-10464.256836, 5302.690430, -12132.900391))
ssv_kosino_7:SetAngles(Angle(0, 150.699, 0))
ssv_kosino_7:Spawn()

ssv_kosino_8 = ents.Create("prop_physics")
ssv_kosino_8:SetModel("models/nekrasovskaya/tunnel_krestovina_kosino_new_d.mdl")
ssv_kosino_8:SetPos(Vector(-10965.4, 4409.7, -12132.9))
ssv_kosino_8:SetAngles(Angle(0, 150.699, 0))
ssv_kosino_8:Spawn()

ssv_ostryak_1 = ents.Create("prop_physics")
ssv_ostryak_1:SetModel("models/nekrasovskaya/strelka_1_9_right_ostryak_1.mdl")
ssv_ostryak_1:SetPos(Vector(-9909.972656, 6220.900391, -12132.900391))
ssv_ostryak_1:SetAngles(Angle(0, 150.699, 0))   --Стрелка в минусе
--ssv_ostryak_1:SetAngles(Angle(0, 151.699, 0)) --Стрелка в плюсе
ssv_ostryak_1:Spawn()
local phys = ssv_ostryak_1:GetPhysicsObject()
if (!IsValid(phys)) then return end
phys:EnableMotion(false)

ssv_ostryak_2 = ents.Create("prop_physics")
ssv_ostryak_2:SetModel("models/nekrasovskaya/strelka_1_9_right_ostryak_2.mdl")
ssv_ostryak_2:SetPos(Vector(-9976.249023, 6258.094238, -12132.900391))
ssv_ostryak_2:SetAngles(Angle(0, 149.699, 0))   --Стрелка в минусе
--ssv_ostryak_2:SetAngles(Angle(0, 150.699, 0)) --Стрелка в плюсе
ssv_ostryak_2:Spawn()
phys = ssv_ostryak_2:GetPhysicsObject()
if ( !IsValid(phys)) then return end
phys:EnableMotion(false)

ssv_kosino_9 = ents.Create("prop_physics")
ssv_kosino_9:SetModel("models/nekrasovskaya/tunnel_kvad_round.mdl")
ssv_kosino_9:SetPos(Vector(-9460.406250, 7086.593750, -12132.9))
ssv_kosino_9:SetAngles(Angle(0, -209.317, 0))
ssv_kosino_9:Spawn()

ssv_kosino_10 = ents.Create("prop_physics")
ssv_kosino_10:SetModel("models/nekrasovskaya/tunnel_kvadrat_314.mdl")
ssv_kosino_10:SetPos(Vector(-9462, 7088.5, -12132.9))
ssv_kosino_10:SetAngles(Angle(0, -29.317, 0))
ssv_kosino_10:Spawn()
phys = ssv_kosino_10:GetPhysicsObject()
if (!IsValid(phys)) then return end
phys:EnableMotion(false)

ssv_kosino_11 = ents.Create("prop_physics")
ssv_kosino_11:SetModel("models/nekrasovskaya/tunnel_kvad_round.mdl")
ssv_kosino_11:SetPos(Vector(-9303.980469, 7358.846680, -12132.9))
ssv_kosino_11:SetAngles(Angle(0, -29.317, 0))
ssv_kosino_11:Spawn()

ssv_kosino_12 = ents.Create("prop_physics")
ssv_kosino_12:SetModel("models/nekrasovskaya/tunnel_round_povorot_left_1a.mdl")
ssv_kosino_12:SetPos(Vector(-8672, 8758, -12141))
ssv_kosino_12:SetAngles(Angle(-3.5, 160.461, 0))
ssv_kosino_12:Spawn()
phys = ssv_kosino_12:GetPhysicsObject()
if (!IsValid(phys)) then return end
phys:EnableMotion(false)

ssv_kosino_13 = ents.Create("prop_physics")
ssv_kosino_13:SetModel("models/nekrasovskaya/tunnel_round_povorot_right_1a.mdl")
ssv_kosino_13:SetPos(Vector(-8672, 8758, -12141))
ssv_kosino_13:SetAngles(Angle(3.5, -19.539, 0))
--self:SetMoveType( MOVETYPE_VPHYSICS )

ssv_kosino_13:Spawn()
phys = ssv_kosino_13:GetPhysicsObject()
if (!IsValid(phys)) then return end
phys:EnableMotion(false)
ssv_kosino_13:SetSolid( SOLID_BBOX )
--if ( SERVER ) then ssv_kosino_13:PhysicsInit( SOLID_VPHYSICS ) end
ssv_kosino_13:PhysWake()
