ENT.Type                  = "anim"
ENT.PrintName             = "Signalling Element"
ENT.Category              = "Metrostroi (utility)"

ENT.Spawnable             = false
ENT.AdminSpawnable        = false

ENT.MainModels            = {}
ENT.TrafficLightModels    = {}
ENT.AutostopModel         = {}
ENT.RenderOffset          = {}
ENT.LongThreshold         = {}
ENT.UseRoutePointerFont   = {}
ENT.RoutePointerFontWidth = {}
ENT.BasePos               = {}
ENT.BasePosition          = Vector(-110, 32, 0)
if (game.GetMap() == "gm_metro_minsk_1984") then
	ENT.BasePosition = Vector(-97, 32, 0)
end
ENT.ReloadModels = true
ENT.Signal_IS = "W"
Metrostroi.LiterWarper = {
	A = "f",
	B = ",",
	V = "d",
	G = "u",
	D = "l",
	E = "t",
	J = ";",
	Z = "p",
	I = "b",
	Y = "q",
	K = "r",
	L = "k",
	M = "v",
	N = "y",
	O = "j",
	P = "g",
	R = "h",
	S = "c",
	T = "n",
	U = "e",
	F = "a",
	H = "[",
	C = "w",
	--Y = "",--ЧЩЪЫЬЭЮ
	W = "o",
	Q = "z",
}

vector_mirror = Vector(-1, 1, 1)
angle_right = Angle(0, 90, 0)
angle_mirror = Angle(0, 180, 0)

-- Lamp indexes
-- 0 Red
-- 1 Yellow
-- 2 Green
-- 3 Blue
-- 4 Second yellow (flashing yellow)
-- 5 White
Metrostroi.RoutePointer = {
	[""] = 0,
	["0"] = 10,
	["D"] = 11,
}
for i = 1, 9 do
	Metrostroi.RoutePointer[tostring(i)] = i
end
Metrostroi.Lenses = {
	["R"] = Color(255, 0, 0),
	["Y"] = Color(255, 127, 0),
	["G"] = Color(0, 255, 144),
	["W"] = Color(150, 200, 255),
	["B"] = Color(0, 10, 255),
	["I"] = Color(226, 190, 154),
}

Metrostroi.SigSpriteOffset = Vector(0, 32, 0)
--[[
ENT.LightType = 0
ENT.Name = ""
ENT.Lenses = {
}
ENT.RouteNumber = ""
ENT.OnlyARS = false

ENT.Routes = {
}
]]

ENT.OldRouteNumberSetup = {
	"1234DPABVGEZIklMNOSTot",
	"WKFXd", "LR",
	Vector(6, 0, 10.5),
	{ D = 4,     P = 5,     A = 6,     B = 7, V = 8, G = 9, E = 10, Z = 11, I = 12, k = 13, l = 14, M = 15, N = 16, O = 17, S = 18, T = 19, o = 20, t = 21 },
	{ ["F"] = 0, ["L"] = 2, ["R"] = 0, W = 3, K = 4, d = 1 },
}
ENT.SpriteMat = Material("sprites/light_ignorez")
-- ENT.SpriteMat = Material("sprites/light_glow02_add_noz")
-- ENT.SpriteMat = Material("sprites/glow04_noz")

Metrostroi.SigTypeNames = {}
Metrostroi.SigTypeSpriteMul = {}
--------------------------------------------------------------------------------
-- Inside
--------------------------------------------------------------------------------
Metrostroi.SigTypeNames[0] = 'Inside'
Metrostroi.SigTypeSpriteMul[0] = 1
ENT.RenderOffset[0] = Vector(0, 0.5, 113.35)
ENT.MainModels[0] = {
	m1          = { model = "models/metrostroi/signals/mus/box.mdl" },
	m2          = { model = "models/metrostroi/signals/mus/pole_2.mdl" },
	m2_long     = { model = "models/metrostroi/signals/mus/pole_2_long.mdl" },
	m2_long_pos = Vector(0, 0, 46),
}
ENT.TrafficLightModels[0] = {
	name       = Vector(-1.75, 2.5, 3),
	name_one   = Vector(7.41, 0.5, 1),
	name_s     = Vector(112, 10, 0.5),
	name_s_ang = Angle(0, 0, -90),
	name_out   = Vector(11.5, 2.5 + 30, 36.6 + 16),
	[1]        = { Vector(0, 0, 32), "models/metrostroi/signals/mus/light_2.mdl", {
		[0] = Vector(7.41, -27.54, 25.26),
		[1] = Vector(7.41, -27.54, 14.2), --
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.43, 4.46, 25) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.43, 4.46, 14) },
		}
	} },
	[2]        = { Vector(0, 0, 43), "models/metrostroi/signals/mus/light_3.mdl", {
		[0] = Vector(7.41, -27.54, 35.1),
		[1] = Vector(7.41, -27.54, 25.26),
		[2] = Vector(7.41, -27.54, 14.2), ---27.54
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.43, 4.46, 35.2) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.43, 4.46, 25) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.43, 4.46, 14) },
		}
	} },

	M          = { Vector(0, 0, 24), "models/metrostroi/signals/mus/light_pathindicator.mdl", {}, Vector(13.1, 2, 19.5), 1.75, 2.05, 4 },
	arsletter  = true,
}


--------------------------------------------------------------------------------
-- Outside
--------------------------------------------------------------------------------
Metrostroi.SigTypeNames[1] = 'Outside'
Metrostroi.SigTypeSpriteMul[1] = 0.75
ENT.RenderOffset[1] = Vector(0, 0, 200)
ENT.LongThreshold[1] = 1
ENT.MainModels[1] = {
	m1 = { model = "models/metrostroi/signals/mus/pole_1.mdl" },
}
ENT.TrafficLightModels[1] = {
	name = Vector(0, 3, 30),
	[1] = { Vector(0, 0, 46), "models/metrostroi/signals/mus/light_outside_2.mdl", {
		[0] = { right = Vector(-0.51, -18.76, 19.95), left = Vector(-0.51, -18.76, 19.95) },
		[1] = { right = Vector(-0.51, -18.76, 7.97), left = Vector(-0.51, -18.76, 7.97) },
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(0, 13.3, 19.95) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(0, 13.3, 7.97) },
		}
	} },
	[2] = { Vector(0, 0, 56), "models/metrostroi/signals/mus/light_outside_3.mdl", {
		[0] = { right = Vector(-0.51, -18.76, 30.88), left = Vector(-0.51, -18.76, 30.88) },
		[1] = { right = Vector(-0.51, -18.76, 19.95), left = Vector(-0.51, -18.76, 19.95) },
		[2] = { right = Vector(-0.51, -18.76, 7.97), left = Vector(-0.51, -18.76, 7.97) },
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(0, 13.3, 30.88) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(0, 13.3, 19.95) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(0, 13.3, 7.97) },
		}
	} },

	W = { Vector(0, 0, 25), "models/metrostroi/signals/mus/light_outside_1.mdl", {
		[0] = Vector(-0.51, -18.76, 7.97),
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(0, 13.3, 7.97) },
		}
	} },
	M = { Vector(0, 0, 40), "models/metrostroi/signals/mus/light_pathindicator3.mdl", {}, Vector(7, 11, 25), 3.6, 3.4, 5 },
	noleft = true,
}

--------------------------------------------------------------------------------
-- Outside box
--------------------------------------------------------------------------------
Metrostroi.SigTypeNames[2] = 'Outside box'
Metrostroi.SigTypeSpriteMul[2] = 0.75
ENT.RenderOffset[2] = Vector(0, 0., 112)
ENT.LongThreshold[2] = 1
ENT.MainModels[2] = {
	m1 = { model = "models/metrostroi/signals/mus/box_outside.mdl" },
	m2 = { model = "models/metrostroi/signals/mus/pole_3.mdl" },
}
ENT.TrafficLightModels[2] = {
	["name"] = Vector(-3, 2.5, 7),
	name_one = Vector(10.07, 0.5, 3),
	[1] = { Vector(0, 0, 42), "models/metrostroi/signals/mus/light_outside2_2.mdl", {
		[0] = Vector(10.07, -29.7, 27.55),
		[1] = Vector(10.07, -29.7, 16),
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 27.55) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 16) },
		}
	} },
	[2] = { Vector(0, 0, 47), "models/metrostroi/signals/mus/light_outside2_3.mdl", {
		[0] = Vector(10.07, -29.7, 39.37),
		[1] = Vector(10.07, -29.7, 27.55),
		[2] = Vector(10.07, -29.7, 16),
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 39.37) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 27.55) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 16) },
		}
	} },
	[3] = { Vector(0, 0, 47), "models/metrostroi/signals/mus/light_outside2_4.mdl", {
		[0] = Vector(10.07, -29.7, 50.45),
		[1] = Vector(10.07, -29.7, 39.37),
		[2] = Vector(10.07, -29.7, 27.55),
		[3] = Vector(10.07, -29.7, 16),
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 50.45) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 39.37) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 27.55) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39, 2.32, 16) },
		}
	} },

	M = { Vector(0, 0, 24), "models/metrostroi/signals/mus/light_pathindicator.mdl", {}, Vector(13.8, 2, 22.8), 1.8, 2.1, 4 },
}

--------------------------------------------------------------------------------
-- Small
--------------------------------------------------------------------------------
Metrostroi.SigTypeNames[3] = 'Small'
Metrostroi.SigTypeSpriteMul[3] = 0.75
ENT.RenderOffset[3] = Vector(15, 0, -3.85)
if game.GetMap() == "gm_metro_minsk_1984" then ENT.RenderOffset[3] = Vector(0, 0, 3.85) end
ENT.MainModels[3] = {}
ENT.TrafficLightModels[3] = {
	name = Vector(10.07 - 10, 0.5 + 6, 42.5),
	name_one = Vector(10.07 - 10, 0.5 + 6, 42.5),
	[1] = { Vector(15, 0, 0), "models/metrostroi/signals/mus/fixed_outside_2.mdl", {
		[0] = Vector(10.07 - 10, -29.7 + 2.5, 27.55 + 38.7),
		[1] = Vector(10.07 - 10, -29.7 + 2.5, 16 + 38.7),
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39 - 10, 2.32 + 2.5, 27.55 + 38.7) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39 - 10, 2.32 + 2.5, 16 + 38.7) },
		}
	} },
	[2] = { Vector(15, 0, 0), "models/metrostroi/signals/mus/fixed_outside_2.mdl", {
		[0] = Vector(10.07 - 10, -29.7 + 2.5, 39.1 + 38.7),
		[1] = Vector(10.07 - 10, -29.7 + 2.5, 27.55 + 38.7),
		[2] = Vector(10.07 - 10, -29.7 + 2.5, 16 + 38.7),
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39 - 10, 2.32 + 2.5, 39.1 + 38.7) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39 - 10, 2.32 + 2.5, 27.55 + 38.7) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(10.39 - 10, 2.32 + 2.5, 16 + 38.7) },
		}
	} },
	noleft = true,
}
--------------------------------------------------------------------------------
-- ARS
--------------------------------------------------------------------------------
Metrostroi.SigTypeNames[4] = 'ARS'
Metrostroi.SigTypeSpriteMul[4] = 1
ENT.RenderOffset[4] = Vector(0, 0, 100)
ENT.MainModels[4] = {
	m1 = { model = "models/metrostroi/signals/mus/box.mdl" },
	m2 = { model = "models/mn_r/mn_r_joint3.mdl" },
}
ENT.TrafficLightModels[4] = {
	["name"]       = Vector(11.5, 19.5, 52.5),
	["name_s"]     = Vector(0, 10, 0.5),
	--["name_s_ang"]	= Angle(50, 0, -90),
	["name_s_ang"] = Angle(0, 0, 0),
	--["name_out"] 	= Vector(11.5,2.5+17,36.6),
	["name_out"]   = Vector(112.5, 15, 4),
	arsletter      = true,
}
--------------------------------------------------------------------------------
-- Virus New
--------------------------------------------------------------------------------
Metrostroi.SigTypeNames[5] = 'Virus New'
Metrostroi.SigTypeSpriteMul[5] = 1
ENT.RenderOffset[5] = Vector(1, 0, 113.35)
ENT.MainModels[5] = {
	m1 = { model = "models/jar/ars_drossel.mdl" },
	m2 = { model = "models/virus/new_signals/pole_2.mdl" },
	m2_long = { model = "models/virus/new_signals/pole_2_long.mdl" },
	m2_long_pos = Vector(0, 0, 46),
}
ENT.TrafficLightModels[5] = {
	name = Vector(-1.75, 2.5, 3),
	name_one = Vector(-1.75, 2.5, 0),
	kronOff = Vector(0, 0, 13),
	step = Vector(0, 0, 11.79),
	single = { Vector(0, 0, 24), "models/virus/new_signals/light_single.mdl", {
		[0] = Vector(7.22, -29.56, 12.93), --
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.22, 3, 12.93) },
		}
	} },
	[0] = { Vector(0, 0, 24), "models/virus/new_signals/light_1.mdl", {
		[0] = Vector(7.22, -29.56, 12.93), --
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.22, 3, 12.93) },
		}
	} },
	[1] = { Vector(0, 0, 35), "models/virus/new_signals/light_2.mdl", {
		[0] = Vector(7.22, -29.56, 24.72),
		[1] = Vector(7.22, -29.56, 12.93), --
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.22, 3, 24.72) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.22, 3, 12.93) },
		}
	} },
	[2] = { Vector(0, 0, 46), "models/virus/new_signals/light_3.mdl", {
		[0] = Vector(7.22, -29.56, 36.54),
		[1] = Vector(7.22, -29.56, 24.72),
		[2] = Vector(7.22, -29.56, 12.93), ---27.54
		["glass"] = {
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.22, 3, 36.54) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.22, 3, 24.72) },
			{ "models/metrostroi/signals/mus/lamp_lens.mdl", Vector(7.22, 3, 12.93) },
		}
	} },

	M = { Vector(0, 0, 24.5), "models/virus/new_signals/path_ind.mdl", {}, Vector(13.1, 2, 19.5), 1.75, 2.05, 4 },
	M_single = { Vector(0, 0, 24.5), "models/virus/new_signals/path_ind_single.mdl", {} },
}

ENT.SignalConverter = {
	R = 1,
	Y = 2,
	G = 3,
	B = 4,
	W = 5
}

ENT.SpriteConverter = {
	[1] = 'R',
	[2] = 'Y',
	[3] = 'G',
	[4] = 'B',
	[5] = 'W'
}
ENT.SpriteMultiplier = {
	[1] = 1,
	[2] = 1,
	[3] = 0.75,
	[4] = 1.25,
	[5] = 1
}


for i = 0, (#ENT.TrafficLightModels) do
	--SERVER
	ENT.TrafficLightModels[i].ArsBox = { model = "models/metrostroi/signals/mus/ars_box.mdl" }
	ENT.TrafficLightModels[i].ArsBoxMittor = { model = "models/metrostroi/signals/mus/ars_box_mittor.mdl" }
	if (game.GetMap() == "gm_metro_minsk_1984") then
		ENT.TrafficLightModels[i].ArsBox = { model = "models/mn_r/mn_r_joint1.mdl" }
		ENT.TrafficLightModels[i].ArsBoxMittor = { model = "models/mn_r/mn_r_joint2.mdl" }
		ENT.TrafficLightModels[4].ArsBox = { model = "models/mn_r/mn_r_joint3.mdl" }
		ENT.TrafficLightModels[4].ArsBoxMittor = { model = "models/mn_r/mn_r_joint4.mdl" }
		Metrostroi.SigTypeSpriteMul[1] = 1
		Metrostroi.SigTypeSpriteMul[2] = 1
		Metrostroi.SigTypeSpriteMul[3] = 1
	end

	--CLIENT
	ENT.BasePos[i] = ENT.BasePos[i] or ENT.BasePosition
	ENT.TrafficLightModels[i].LampIndicator = {
		models = {
			"models/metrostroi/signals/mus/light_lampindicator.mdl", -- kron full
			"models/metrostroi/signals/mus/light_lampindicator2.mdl", -- kron half
			"models/metrostroi/signals/mus/light_lampindicator3.mdl", -- sep half
			"models/metrostroi/signals/mus/light_lampindicator4.mdl", -- sep full
			"models/metrostroi/signals/mus/light_lampindicator5.mdl", -- empty kron
			numb = "models/metrostroi/signals/mus/light_lampindicator_numb_l.mdl",
			lamp = "models/metrostroi/signals/mus/light_lampindicator_lamp.mdl",
		},
		Vector(7.9),  -- Indicator model offset if left
		Vector(0),    -- Indicator model offset
		Vector(8),    -- Sep (on short kron) Indicator model offset
		Vector(-12, 0, 0), -- Sep (on short kron) Indicator model offset if left
		Vector(3, 0, 3), -- Arrow offset
		Vector(0, 0, -12), -- Arrow offset if left
	}
	ENT.TrafficLightModels[i].LampBase = { model = "models/metrostroi/signals/mus/lamp_base.mdl" }
	ENT.TrafficLightModels[i].SignLetterSmall = {
		model = "models/metrostroi/signals/mus/sign_letter_small.mdl",
		Vector(
			1.5, 0, 0),
		Vector(-1.5, 0, 0)
	}
	ENT.TrafficLightModels[i].SignLetter = { model = "models/metrostroi/signals/mus/sign_letter.mdl", z = 5.85 }
	ENT.TrafficLightModels[i].LetMaterials = { str = "models/metrostroi/signals/let/" }

	ENT.TrafficLightModels[i].RouteNumberOffset = Vector(10, 0, 0)
	ENT.TrafficLightModels[i].DoubleOffset = Vector(0, 0, 1.62)
	ENT.TrafficLightModels[i].RouteNumberOffset2 = Vector(0, 0, 7.2)
	ENT.TrafficLightModels[i].SpecRouteNumberOffset = Vector(3, -1, 3)
	ENT.TrafficLightModels[i].RouteNumberOffset3 = Vector(10.5, 0, -6)
	ENT.TrafficLightModels[i].SpecRouteNumberOffset2 = Vector(-0.8, 1, 0.94)
	ENT.TrafficLightModels[i].RouaOffset = Vector(6.2, 0, 24.5)

	ENT.AutostopModel[i] = { "models/metrostroi/signals/mus/autostop.mdl", Vector(41, -0.5, 1.5) }
end
