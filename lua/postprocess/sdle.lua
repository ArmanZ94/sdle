if CLIENT then
	local dl_enable = CreateClientConVar("pp_dlens", "0", true, false)
	local dl_blurrange = CreateClientConVar("pp_dlens_blurrange", "10", true, false)
	local dl_blurpasses = CreateClientConVar("pp_dlens_blurpasses", "30", true, false)
	local dl_multiply = CreateClientConVar("pp_dlens_multiply", "1", true, false)
	local dl_darken = CreateClientConVar("pp_dlens_darken", "0.30", true, false)
	local dl_texture = CreateClientConVar("pp_dlens_texture", "dlenstexture/dlensdefault", true, false)

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
				pp_dlens_blurrange = "15",
				pp_dlens_blurpasses = "30",
				pp_dlens_multiply = "1.30",
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
				Max = "50"
			})

			CPanel:AddControl("Slider", {
				Label = "Passes",
				Command = "pp_dlens_blurpasses",
				Type = "Integer",
				Min = "0",
				Max = "30"
			})

			CPanel:AddControl("Slider", {
				Label = "Multiply",
				Command = "pp_dlens_multiply",
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
		end
	})
	
	local mat_Downsample = Material("pp/downsample")
	local mat_Bloom = Material("dlenstexture/dlensmat")
	local OldRT = render.GetRenderTarget()	
	local tex_Bloom0 = render.GetBloomTex0()
	local w, h = ScrW(), ScrH()

	hook.Add("RenderScreenspaceEffects", "DrawDirtLens", function()
		if not dl_enable:GetBool() then return end
		if not render.SupportsPixelShaders_2_0() then return end
        
		local blur = dl_blurrange:GetFloat()
		local passes = dl_blurpasses:GetFloat()
		local multiply = dl_multiply:GetFloat()
		local darken = dl_darken:GetFloat()
		local lens_texture = dl_texture:GetString()
		mat_Downsample:SetFloat("$darken", darken)
		mat_Downsample:SetFloat("$multiply", multiply)	
		mat_Downsample:SetTexture("$fbtexture", render.GetScreenEffectTexture())

        	render.SetViewPort(0, 0, w, h)
		render.SetRenderTarget(tex_Bloom0)
			render.SetBlend(1)
			render.SetMaterial(mat_Downsample)
			render.DrawScreenQuad()
			render.BlurRenderTarget(tex_Bloom0, blur, blur, passes)
			render.ClearDepth()
		render.SetRenderTarget(OldRT)
		
		mat_Bloom:SetFloat("$levelr", 1)
		mat_Bloom:SetFloat("$levelg", 1)
		mat_Bloom:SetFloat("$levelb", 1)
		mat_Bloom:SetFloat("$colormul", 16)
		
		mat_Bloom:SetTexture("$basetexture", lens_texture)
		mat_Bloom:SetTexture("$dudvmap", lens_texture)
		mat_Bloom:SetTexture("$normalmap", lens_texture)
		mat_Bloom:SetTexture("$refracttinttexture", tex_Bloom0)

		render.SetMaterial(mat_Bloom)
		render.DrawScreenQuad()
	end)
end
