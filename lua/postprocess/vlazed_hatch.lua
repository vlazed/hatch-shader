local mat_hatching = Material("pp/vlazed/hatching")

local pp_hatching = CreateClientConVar("pp_vlazedhatching", "0", true, false, "Enable hatching", 0, 1)
local pp_hatching_scale = CreateClientConVar("pp_vlazedhatching_scale", "8", true, false, "Hatching scale")
local pp_hatching_tam = CreateClientConVar("pp_vlazedhatching_tam", "hatch", true, false, "Tonal art map")
local pp_hatching_angle = CreateClientConVar("pp_vlazedhatching_angle", "0", true, false, "Hatching angle", -180, 180)
local pp_hatching_intensity =
	CreateClientConVar("pp_vlazedhatching_intensity", "6.0", true, false, "Hatching intensity")

local width, height = ScrW(), ScrH()

---@enum toneMap
local tonalArtMap = {
	hatch = 1,
	lines = 2,
	halftone = 3,
	pixel = 4,
}
local tonalArtMapName = table.Flip(tonalArtMap)

function render.DrawVlazedHatching()
	-- TODO: Use local variables

	render.UpdateScreenEffectTexture()

	local tam = pp_hatching_tam:GetString()

	mat_hatching:SetTexture("$texture1", tam .. "1")
	mat_hatching:SetTexture("$texture2", tam .. "2")
	mat_hatching:SetFloat("$c0_x", pp_hatching_scale:GetFloat())
	mat_hatching:SetFloat("$c0_y", math.rad(pp_hatching_angle:GetFloat()))
	mat_hatching:SetFloat("$c0_z", pp_hatching_intensity:GetFloat())
	mat_hatching:SetFloat("$c3_x", 1 / ScrW())
	mat_hatching:SetFloat("$c3_y", 1 / ScrH())
	render.SetMaterial(mat_hatching)
	render.DrawScreenQuad()
end

local function enableHatching()
	if pp_hatching:GetBool() then
		hook.Add("RenderScreenspaceEffects", "vlazed_hatching_hook", function()
			render.DrawVlazedHatching()
		end)
	else
		hook.Remove("RenderScreenspaceEffects", "vlazed_hatching_hook")
	end
end

cvars.AddChangeCallback("pp_vlazedhatching", function(cvar, old, new)
	enableHatching()
end, "vlazed_hatching_callback")
enableHatching()

---Helper for DForm
---@param cPanel ControlPanel|DForm
---@param name string
---@param type "ControlPanel"|"DForm"
---@return ControlPanel|DForm
local function makeCategory(cPanel, name, type)
	---@type DForm|ControlPanel
	local category = vgui.Create(type, cPanel)

	category:SetLabel(name)
	cPanel:AddItem(category)
	return category
end

list.Set("PostProcess", "Hatching (vlazed)", {

	icon = "gui/postprocess/vlazedhatching.png",
	convar = "pp_vlazedhatching",
	category = "#shaders_pp",

	cpanel = function(CPanel)
		---@cast CPanel ControlPanel

		CPanel:Help("Draw hatches over the scene.")

		local options = {}
		CPanel:ToolPresets("vlazedhatching", options)

		CPanel:CheckBox("Enable", "pp_vlazedhatching")

		local hatchSettings = makeCategory(CPanel, "Hatch Settings", "ControlPanel")
		local uvSettings = makeCategory(CPanel, "UV Settings", "ControlPanel")

		hatchSettings:ColorPicker(
			"Color",
			"pp_vlazedhatching_r",
			"pp_vlazedhatching_g",
			"pp_vlazedhatching_b",
			"pp_vlazedhatching_a"
		)

		hatchSettings:NumSlider("Hatch scale", "pp_vlazedhatching_scale", 0, 100)
		hatchSettings:NumSlider("Hatch angle", "pp_vlazedhatching_angle", -180, 180)
		hatchSettings:NumSlider("Hatch intensity", "pp_vlazedhatching_intensity", -100, 100)
		---@class HatchComboBox: DComboBox
		local combo = hatchSettings:ComboBox("Tone map") ---@diagnostic disable-line: missing-parameter
		for i, tam in ipairs(tonalArtMapName) do
			combo:AddChoice(tam, i)
		end
		---@class HatchEntry: DTextEntry
		local tamEntry = hatchSettings:TextEntry("Tonal art map path", "pp_vlazedhatching_tam")

		uvSettings:CheckBox("UV buffer enabled", "uv_buffer_enable")

		uvSettings:NumSlider("World scale", "uv_buffer_worldscale", 0, 256, 5)
		uvSettings:NumSlider("Model scale X", "uv_buffer_modelscale_x", 0, 256, 5)
		uvSettings:NumSlider("Model scale Y", "uv_buffer_modelscale_y", 0, 256, 5)

		function combo:OnSelect(i, val, data)
			local newPath = "pp/vlazed/" .. val
			pp_hatching_tam:SetString(newPath)
		end
	end,
})
