local mat_hatching = Material("pp/vlazed/hatching")

local pp_hatching = CreateClientConVar("pp_vlazedhatching", "0", true, false, "Enable outlines", 0, 1)

local width, height = ScrW(), ScrH()

function render.DrawVlazedHatching()
	-- TODO: Use local variables

	render.UpdateScreenEffectTexture()

	mat_hatching:SetFloat("$c3_x", 1 / ScrW())
	mat_hatching:SetFloat("$c3_y", 1 / ScrH())
	render.SetMaterial(mat_hatching)
	render.DrawScreenQuad()

	-- render.DrawScreenQuad()
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

list.Set("PostProcess", "Hatching (vlazed)", {

	icon = "gui/postprocess/vlazedhatching.png",
	convar = "pp_vlazedhatching",
	category = "#shaders_pp",

	cpanel = function(CPanel)
		---@cast CPanel ControlPanel

		CPanel:Help("Draw hatches over the scene.")

		local options = {}
		CPanel:ToolPresets("vlazedhatching", options)

		CPanel:ColorPicker(
			"Color",
			"pp_vlazedhatching_r",
			"pp_vlazedhatching_g",
			"pp_vlazedhatching_b",
			"pp_vlazedhatching_a"
		)

		CPanel:CheckBox("Enable", "pp_vlazedhatching")
	end,
})
