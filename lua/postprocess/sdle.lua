if CLIENT then
	local dl_intensity = CreateClientConVar("pp_dlens_intensity", "12", true, false)
	local dl_blur = CreateClientConVar("pp_dlens_blurrange", "28", true, false)
	local dl_lenson = CreateClientConVar("pp_dlens", "1", true, false)
	local dl_mul = CreateClientConVar("pp_dlens_mul", "1", true, false)
	local dl_darken = CreateClientConVar("pp_dlens_darken", "0.45", true, false)
	local dl_mode = CreateClientConVar("pp_dlens_mode", "1", true, false)
	local dl_texture = CreateClientConVar("pp_dlens_texture", "dlenstexture/dlensdefault", true, false)
	local dl_fov = GetConVar("fov_desired")
	
	list.Set("PostProcess", "Dirt Lens", {
		icon = "gui/postprocess/sdle.jpg",
		convar = "pp_dlens",
		category = "#shaders_pp",
		cpanel = function(CPanel)
			
			local params = {
				Options = {},
              			CVars = {},
              			MenuButton = "1",
				Folder = "sdle"
			}

			params.Options["#preset.default"] = {
				pp_dlens_intensity = "30",
				pp_dlens_blurrange = "10",
				pp_dlens_mul = "1",
				pp_dlens_mode = "1",
				pp_dlens_darken = "0.30",
				pp_dlens_texture = "dlenstexture/dlensdefault"
			}				
				
			params.CVars = table.GetKeys(params.Options["#preset.default"])
			CPanel:AddControl("ComboBox", params)
			
			CPanel:AddControl("CheckBox", { 
				Label = "Enable", 
				Command = "pp_dlens" 
			})

			local combobox, label = CPanel:ComboBox("Texture", "pp_dlens_texture")
				combobox:AddChoice("Default", "dlenstexture/dlensdefault")
				combobox:AddChoice("Lens01", "dlenstexture/dlens01")
				combobox:AddChoice("Lens02", "dlenstexture/dlens02")
				combobox:AddChoice("Lens03", "dlenstexture/dlens03")
				combobox:AddChoice("Lens04", "dlenstexture/dlens04")
				combobox:AddChoice("Lens05", "dlenstexture/dlens05")
				combobox:AddChoice("Lens06", "dlenstexture/dlens06")
				combobox:AddChoice("Lens07", "dlenstexture/dlens07")
				combobox:AddChoice("Lens08", "dlenstexture/dlens08")
				combobox:AddChoice("Lens09", "dlenstexture/dlens09")
				combobox:AddChoice("Lens10", "dlenstexture/dlens10")
				combobox:AddChoice("Lens11", "dlenstexture/dlens11")
				combobox:AddChoice("Lens12", "dlenstexture/dlens12")
				combobox:AddChoice("Lens13", "dlenstexture/dlens13")
				combobox:AddChoice("Lens14", "dlenstexture/dlens14")
				combobox:AddChoice("Lens15", "dlenstexture/dlens15")
				combobox:AddChoice("Lens16", "dlenstexture/dlens16")
				combobox:AddChoice("Lens17", "dlenstexture/dlens17")
				combobox:AddChoice("Lens18", "dlenstexture/dlens18")
				combobox:AddChoice("Lens19", "dlenstexture/dlens19")
				combobox:AddChoice("Lens20", "dlenstexture/dlens20")
			
			CPanel:AddControl("Slider", {
				Label = "Range",
				Command = "pp_dlens_blurrange",
				Type = "Integer",
				Min = "0",
				Max = "100"
			})

			CPanel:AddControl("Slider", {
				Label = "Passes",
				Command = "pp_dlens_intensity",
				Type = "Integer",
				Min = "0",
				Max = "30"
			})

			CPanel:AddControl("Slider", {
				Label = "Multiply",
				Command = "pp_dlens_mul",
				Type = "Float",
				Min = "0",
				Max = "10"
			})
	
			CPanel:AddControl("Slider", {
				Label = "Darken",
				Command = "pp_dlens_darken",
				Type = "Float",
				Min = "0",
				Max = "1"
			})
			
			CPanel:ControlHelp(" ")
			CPanel:AddControl("Label", {Text = ":EXPERIMENTAL:"})
			CPanel:AddControl("Label", {Text = "This mode has bugs with any bloom modification; disabled that before use this mode."})
			
			CPanel:AddControl("CheckBox", { 
				Label = "Lensflare Mode", 
				Command = "pp_dlens_mode" 
			})
			
			CPanel:AddControl("Label", {Text = "Change the bloom effect to a lensflare-like effect; recommended for use in dark or nighttime maps"})
			
		end
	})
	
	local mat_Downsample = Material("pp/downsample")
	local mat_Bloom = Material("dlenstexture/dlensmat")
	local OldRT = render.GetRenderTarget()	
	local RTBloom = GetRenderTarget("RtNewBloom", ScrW(), ScrH(), false)
	local w, h = ScrW(), ScrH()

	local function DrawScene()
		if not dl_lenson:GetBool() then return end
		local mode = dl_mode:GetFloat()
		if mode == 1 then
			render.SetViewPort(0, 0, w, h)
			render.SetRenderTarget(RTBloom)
				render.Clear(0, 0, 0, 255, false)
				render.ClearDepth()
				local CamData = {
				x = 0,
				y = 0,
				w = w,
				h = h,
				origin = LocalPlayer():EyePos(),
				angles = LocalPlayer():EyeAngles() + Angle(0, 0, 180),
				fov = dl_fov,
				drawhud = false,
				drawviewmodel = false,
				dopostprocess = false,
				}
				render.RenderView(CamData)
			render.SetRenderTarget(OldRT)
			render.SetViewPort(0, 0, w, h)
		end
	end
		
	local function DrawLens()
		if not dl_lenson:GetBool() then return end
		if not render.SupportsPixelShaders_2_0() then return end
        
		local intensity = dl_intensity:GetFloat()
		local blur = dl_blur:GetFloat()
		local mul = dl_mul:GetFloat()
		local darken = dl_darken:GetFloat()
		local mode = dl_mode:GetFloat()
		local lens_texture = dl_texture:GetString()
		mat_Downsample:SetFloat("$darken", darken)
		mat_Downsample:SetFloat("$multiply", mul)
				
		if mode == 0 then
			mat_Downsample:SetTexture("$fbtexture", render.GetScreenEffectTexture())
		elseif mode == 1 then
			mat_Downsample:SetTexture("$fbtexture", RTBloom)
		end
		
		render.SetViewPort(0, 0, w, h)
		render.SetRenderTarget(RTBloom)
			render.SetBlend(1)
			render.SetMaterial(mat_Downsample)
			render.DrawScreenQuad()
			render.BlurRenderTarget(RTBloom, blur, blur, intensity)
			render.ClearDepth()
		render.SetRenderTarget(OldRT)
		render.SetViewPort(0, 0, w, h)
		
		mat_Bloom:SetFloat("$levelr", 1)
		mat_Bloom:SetFloat("$levelg", 1)
		mat_Bloom:SetFloat("$levelb", 1)
		mat_Bloom:SetFloat("$colormul", 16)
		mat_Bloom:SetTexture("$basetexture", RTBloom)

		if mat_Bloom:GetTexture("$basetexture") ~= lens_texture then
			mat_Bloom:SetTexture("$basetexture", lens_texture)
			mat_Bloom:SetTexture("$dudvmap", lens_texture)
			mat_Bloom:SetTexture("$normalmap", lens_texture)
		end
		mat_Bloom:SetTexture("$refracttinttexture", RTBloom)

		render.SetMaterial(mat_Bloom)
		render.DrawScreenQuad()
	end
    
	hook.Add("RenderScene", "RenderDirtyLensBloom", DrawScene)
	hook.Add("RenderScreenspaceEffects", "DrawDirtyLens", DrawLens)

end
