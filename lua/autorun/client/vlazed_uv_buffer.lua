local shaderName = "vlazed_uv_buffer"

local rt_UV = GetRenderTargetEx(
	"_rt_UV",
	ScrW(),
	ScrH(),
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_NONE,
	bit.bor(4, 8, 16, 256, 512),
	0,
	29
)

local mat_UV_model = Material("vlazed/uv_model")
local mat_UV_world = Material("vlazed/uv_world")

---@type {[integer]: Entity}
local entities = {}
---@type Entity[]
local entityList = {}

local function refreshEntityList()
	entityList = {}
	for _, entity in pairs(entities) do
		table.insert(entityList, entity)
	end
end

local function drawEntities()
	for _, entity in ipairs(entityList) do
		if ( !IsValid( entity ) or entity:GetNoDraw() ) then continue end

		entity:DrawModel()
	end
end

function render.DrawUVBuffer()
	render.PushRenderTarget(rt_UV)
	-- render.PushRenderTarget() -- Debug mode

	-- Render world with screenspace UVs
	render.SetMaterial(mat_UV_world)
	render.DrawScreenQuad()

	-- Then render entities on top of world
	render.UpdateScreenEffectTexture()
	render.UpdateRefractTexture()

	---@type ViewSetup
	local viewSetup = render.GetViewSetup()

	cam.Start3D(viewSetup.origin, viewSetup.angles, viewSetup.fov)
	---FIXME: Are stencils necessary?
	render.SetStencilEnable(true)
	render.SuppressEngineLighting(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)

	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)

	render.MaterialOverride(mat_UV_model)
	drawEntities()

	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetStencilPassOperation(STENCIL_KEEP)

	cam.IgnoreZ(false)
	render.SuppressEngineLighting(false)
	render.SetStencilEnable(false)
	cam.End3D()

	---TODO: Maybe add viewmodel UVs?
	---Reason is that viewmodel doesn't draw at the correct FOV,
	---hence `isViewModelEntity` functions

	render.PopRenderTarget()
end

hook.Remove("RenderScreenspaceEffects", shaderName)
hook.Add("RenderScreenspaceEffects", shaderName, function()
	render.DrawUVBuffer()
end)

local function isViewModelEntity(ent)
	return ent:GetClass() == "viewmodel" or IsValid(ent:GetParent()) and ent:GetParent():GetClass() == "viewmodel"
end

local function initializeEntities()
	for _, entity in ents.Iterator() do
		if IsValid(entity) and not isViewModelEntity(entity) then
			entities[entity:EntIndex()] = entity
			table.insert(entityList, entity)
		end
	end
end

initializeEntities()

hook.Remove("EntityRemoved", shaderName)
hook.Add("EntityRemoved", shaderName, function(ent)
	---@cast ent Entity
	if IsValid(ent) then
		entities[ent:EntIndex()] = nil
		refreshEntityList()
	end
end)

hook.Remove("OnEntityCreated", shaderName)
hook.Add("OnEntityCreated", shaderName, function(ent)
	---@cast ent Entity
	timer.Simple(0, function()
		if IsValid(ent) and not isViewModelEntity(ent) then
			entities[ent:EntIndex()] = ent
			refreshEntityList()
		end
	end)
end)
