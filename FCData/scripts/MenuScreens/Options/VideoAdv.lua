--
-- advanced video options menu page
--
----------------------------------------------------------------------------------------------

UI.PageOptionsVideoAdv =
{
	GUI =
	{
	--	sep_v =
	--	{
	--		skin = UI.skins.MenuBorder,

	--		left = 510, top = 140,
	--		width = 271, height = 319,
	--		bordersides = "l",

	--		zorder = -50,
	--	},

	--	sep_h0 =
	--	{
	--		skin = UI.skins.MenuBorder,

	--		left = 510, top = 380,
	--		width = 271, height = 123,
	--		bordersides = "t",

	--		zorder = -50,
	--	},


		-- definition of "Back" button (takes user to back to basic video menu)
		widget_back =
		{
			left = 208, top = 142 + 318 - 34,
			width = 160,
			skin = UI.skins.BottomMenuButton,
			bordersides = "lrtb",

			text = Localize( "BasicVIdOptions" ),

			tabstop = 26,

			OnCommand = function( sender )
				GotoPage( "VideoOptions" );
			end,
		},

		-- definition of "Apply" button (applies all changes of video options undertaken by user)
		widget_apply =
		{
			skin = UI.skins.BottomMenuButton,
			left = 780 - 180,

			tabstop = 25,

			text = Localize( "Apply" ),

			OnCommand = function( sender )
				UI.PageOptionsVideoAdv.user:UpdateGlobals();
				System:SaveConfiguration();
			end,
		},

		-- definition of "Auto Detect" button (adjust settings to match machine's capabilities)
		widget_autodetect =
		{
			skin = UI.skins.TopMenuButton,
			left = 200,
			width = 181,

			tabstop = 15,

			text = Localize( "AutoDetect" ),

			OnCommand = function( sender )
				UI.PageOptionsVideoAdv.user:SetToAutoDetect();
			end,
		},

		-- definition of "Very High" button (adjust settings to match very high spec)
		widget_veryhighspec =
		{
			skin = UI.skins.TopMenuButton,
			left = 380,
			width = 101,

			tabstop = 16,

			text = Localize( "VeryHigh" ),

			OnCommand = function( sender )
				UI.PageOptionsVideoAdv.user:SetToVeryHighSpec();
			end,
		},

		-- definition of "High" button (adjust settings to match high spec)
		widget_highspec =
		{
			skin = UI.skins.TopMenuButton,
			left = 480,
			width = 101,

			tabstop = 17,

			text = Localize( "High" ),

			OnCommand = function( sender )
				UI.PageOptionsVideoAdv.user:SetToHighSpec();
			end,
		},

		-- definition of "Medium" button (adjust settings to match medium spec)
		widget_mediumspec =
		{
			skin = UI.skins.TopMenuButton,
			left = 580,
			width = 101,

			tabstop = 18,

			text = Localize( "Medium" ),

			OnCommand = function( sender )
				UI.PageOptionsVideoAdv.user:SetToMediumSpec();
			end,
		},

		-- definition of "Low" button (adjust settings to match low spec)
		widget_lowspec =
		{
			skin = UI.skins.TopMenuButton,
			left = 680,
			width = 100,

			tabstop = 19,

			text = Localize( "Low" ),

			OnCommand = function( sender )
				UI.PageOptionsVideoAdv.user:SetToLowSpec();
			end,
		},

		-- definition of "Texture Quality" combo box
		widget_TextureQuality_Text =
		{
			skin = UI.skins.Label,
			left = 200, top = 175,
			width = 160,

			text = Localize( "TextureQuality" ),
		},

		widget_TextureQuality =
		{
			skin = UI.skins.ComboBox,
			left = 370, top = 175,
			width = 120,

			tabstop = 1,

			-- code specific for "Texture Quality" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Texture Filter Quality" combo box
		widget_TextureFilterQuality_Text =
		{
			skin = UI.skins.Label,
			left = 200, top = 225,
			width = 160,

			text = Localize( "TextureFilterQuality" ),
		},

		widget_TextureFilterQuality =
		{
			skin = UI.skins.ComboBox,
			left = 370, top = 225,
			width = 120,

			tabstop = 2,

			-- code specific for "Texture Filter Quality" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Anisotropic Filtering Level" combo box
		widget_AnisotropicFilteringLevel_Text =
		{
			skin = UI.skins.Label,
			left = 200, top = 275,
			width = 160,

			text = Localize( "AnisotropicFilteringLevel" ),
		},

		widget_AnisotropicFilteringLevel =
		{
			skin = UI.skins.ComboBox,
			left = 370, top = 275,
			width = 120,

			tabstop = 3,

			-- code specific for "Anisotropic Filtering Level" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Particle Count" combo box
		widget_ParticleCount_Text =
		{
			skin = UI.skins.Label,
			left = 200, top = 325,
			width = 160,

			text = Localize( "ParticleCount" ),
		},

		widget_ParticleCount =
		{
			skin = UI.skins.ComboBox,
			left = 370, top = 325,
			width = 120,

			tabstop = 4,

			-- code specific for "Particle Count" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Special Effects Quality" combo box
		widget_SpecialEffects_Text =
		{
			skin = UI.skins.Label,
			left = 200, top = 375,
			width = 160,

			text = Localize( "SpecialEffectsQuality" ),
		},

		widget_SpecialEffects =
		{
			skin = UI.skins.ComboBox,
			left = 370, top = 375,
			width = 120,

			tabstop = 5,

			-- code specific for "Special Effects Quality" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Environment Quality" combo box
		widget_Environment_Text =
		{
			skin = UI.skins.Label,
			left = 490, top = 175,
			width = 150,

			text = Localize( "EnvironmentQuality" ),
		},

		widget_Environment =
		{
			skin = UI.skins.ComboBox,
			left = 650, top = 175,
			width = 120,

			tabstop = 6,

			-- code specific for "Environment Quality" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Shadow Quality" combo box
		widget_Shadow_Text =
		{
			skin = UI.skins.Label,
			left = 490, top =225,
			width = 150,

			text = Localize( "ShadowQuality" ),
		},

		widget_Shadow =
		{
			skin = UI.skins.ComboBox,
			left = 650, top = 225,
			width = 120,

			tabstop = 7,

			-- code specific for "Shadow Quality" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Water Quality" combo box
		widget_Water_Text =
		{
			skin = UI.skins.Label,
			left = 490, top = 275,
			width = 150,

			text = Localize( "WaterQuality" ),
		},

		widget_Water =
		{
			skin = UI.skins.ComboBox,
			left = 650, top = 275,
			width = 120,

			tabstop = 8,

			-- code specific for "Water Quality" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Lighting Quality" combo box
		widget_Lighting_Text =
		{
			skin = UI.skins.Label,
			left = 490, top = 325,
			width = 150,

			text = Localize( "LightingQuality" ),
		},

		widget_Lighting =
		{
			skin = UI.skins.ComboBox,
			left = 650, top = 325,
			width = 120,

			tabstop = 9,

			-- code specific for "Lighting Quality" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
				SetToSpec = nil,
			},
		},

		-- definition of "Lighting Quality" combo box
	--	widget_HDR_Text =
	--	{
	--		skin = UI.skins.Label,
	--		left = 570, top = 395,
	--		width = 150,

	--		text = Localize("EnableHDR"),
	--	},

	--	widget_HDR =
	--	{
	--		skin = UI.skins.CheckBox,
	--		left = 740, top = 395,

	--		tabstop = 10,

			-- code specific for "Lighting Quality" combo box (separated in user table)
	--		user =
	--		{
	--			-- code (implemented below)
	--			Initialize = nil,
	--			UpdateAssignedGlobals = nil,
	--			SetToSpec = nil,
	--		},
	--	},

		-- definition of "HDR exposure" combo box (allows user to adjust HDR level)
	--	widget_HDR_exposure_text =
	--	{
	--		skin = UI.skins.Label,
	--		left = 450, top = 425,
	--		width = 142,

	--		text = Localize( "HDRExposure" ),
	--	},

	--	widget_HDR_exposure =
	--	{
	--		skin = UI.skins.HScrollBar,

	--		left = 603, top = 425,
	--		width = 166, height = 24,

	--		tabstop = 11,

	--		OnChanged = function( sender )
	--			UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure.user.OnChanged();
	--		end,

			-- code specific for "HDRExposure" combo box (separated in user table)
	--		user =
	--		{
	--			-- code (implemented below)
	--			Initialize = nil,
	--			UpdateAssignedGlobals = nil,

	--			OnChanged = nil,
	--		},
	--	},

		OnActivate = function( sender )
			UI.PageOptionsVideoAdv.user:Initialize();
		end,
	},

	user =
	{
		relaunchNeeded = 0,
		setglobalTestOnly = 0,

		SetGlobal = function( self, nameOfGlobal, newValue )
			if( UI.PageOptionsVideoAdv.user.setglobalTestOnly ~= 0 ) then
				local oldValue = getglobal( nameOfGlobal );
				if( type( newValue ) ~= "string" ) then
					oldValue = tonumber( oldValue );
				end
				if( oldValue ~= newValue ) then
					if( UI.cvarsNeedingRelaunch[ nameOfGlobal ] == 1 ) then
						UI.PageOptionsVideoAdv.user.relaunchNeeded = 1;
					end
				end
			else
				setglobal( nameOfGlobal, newValue );
			end
		end,

		UpdateGlobalsAssignedToWidgets = function( self, testOnly )
			UI.PageOptionsVideoAdv.user.setglobalTestOnly = testOnly;
			for key, val in UI.PageOptionsVideoAdv.GUI do
				if type( val ) == "table" and val.user and val.user.UpdateAssignedGlobals then
					val.user.UpdateAssignedGlobals();
				end
			end
		end,

		UpdateGlobals = function( self )
			UI.PageOptionsVideoAdv.user.relaunchNeeded = 0;
			UI.PageOptionsVideoAdv.user:UpdateGlobalsAssignedToWidgets( 1 );

			local bRelaunch = UI.PageOptionsVideoAdv.user.relaunchNeeded;
			
			UI.PageOptionsVideoAdv.user:UpdateGlobalsAssignedToWidgets( 0 );

			if( bRelaunch ~= 0 ) then
				UI.MessageBox( Localize( "AdvChangeMess1" ), Localize( "AdvChangeMess2" ));		
			end		
		end,

		Initialize = function( self )
			for key, val in UI.PageOptionsVideoAdv.GUI do
				if type( val ) == "table" and val.user and val.user.Initialize then
					val.user.Initialize();
				end
			end
		end,

		SetToAutoDetect = function( self )
			UI.PageOptionsVideoAdv.GUI:DumpMachineStats();
			for key, val in UI.PageOptionsVideoAdv.GUI do
				if type( val ) == "table" and val.user and val.user.SetToSpec then
					val.user.SetToSpec( "auto" );
				end
			end
		end,

		SetToVeryHighSpec = function( self )
			for key, val in UI.PageOptionsVideoAdv.GUI do
				if type( val ) == "table" and val.user and val.user.SetToSpec then
					val.user.SetToSpec( "veryhigh" );
				end
			end
		end,

		SetToHighSpec = function( self )
			for key, val in UI.PageOptionsVideoAdv.GUI do
				if type( val ) == "table" and val.user and val.user.SetToSpec then
					val.user.SetToSpec( "high" );
				end
			end
		end,

		SetToMediumSpec = function( self )
			for key, val in UI.PageOptionsVideoAdv.GUI do
				if type( val ) == "table" and val.user and val.user.SetToSpec then
					val.user.SetToSpec( "medium" );
				end
			end
		end,

		SetToLowSpec = function( self )
			for key, val in UI.PageOptionsVideoAdv.GUI do
				if type( val ) == "table" and val.user and val.user.SetToSpec then
					val.user.SetToSpec( "low" );
				end
			end
		end,
	},
}

AddUISideMenu( UI.PageOptionsVideoAdv.GUI,
{
	{ "MainMenu", Localize( "MainMenu" ), "$MainScreen$", 0 },
} );

-- and create screen from table
UI:CreateScreenFromTable( "VideoAdvOptions", UI.PageOptionsVideoAdv.GUI );

-- helper function for auto detect
function UI.PageOptionsVideoAdv.GUI:DumpMachineStats()
	local cpuQuality = System:GetCPUQuality();
	local gpuQuality = System:GetGPUQuality();
	local systemMem  = System:GetSystemMem();
	local videoMem   = System:GetVideoMem();

	System:Log( "CPU Quality  : "..tostring( cpuQuality ) );
	System:Log( "GPU Quality  : "..tostring( gpuQuality ) );
	System:Log( "Sys Memory   : "..tostring( systemMem ) );
	System:Log( "Video Memory : "..tostring( videoMem ) );
end;

function UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( checkCPU, checkGPU, checkSysMem, checkVidMem )
	local cpuQuality = System:GetCPUQuality(); -- quality of detected GPU ranging from 0 ((s)low) to 3 (killer)
	local gpuQuality = System:GetGPUQuality(); -- quality of detected GPU ranging from 0 ((s)low) to 3 (killer)
	local systemMem  = System:GetSystemMem();  -- physical amount of RAM in MB (use safety net for comparisons; i.e. -12 for 512 MB, 24 for 1024 MB)
	local videoMem   = System:GetVideoMem();   -- on board video memory in MB (use safety net for comparisons; i.e. -32 for 256 MB, -16 for 128 MB)

	-- perform detection
	if( cpuQuality >= 3 * checkCPU and gpuQuality >= 3 * checkGPU and
	    systemMem >= 1000 * checkSysMem and videoMem >= 224 * checkVidMem ) then
		return( 4 ); -- very high spec
	elseif( cpuQuality >= 2 * checkCPU and gpuQuality >= 2 * checkGPU and
	    	systemMem >= 750 * checkSysMem and videoMem >= 224 * checkVidMem ) then
		return( 3 ); -- high spec
	elseif( cpuQuality >= 1 * checkCPU and gpuQuality >= 1 * checkGPU and
	    	systemMem >= 500 * checkSysMem and videoMem >= 112 * checkVidMem ) then
		return( 2 ); -- medium spec
	else
		return( 1 ); -- low spec
	end
end

--UI.PageOptionsVideoAdv.GUI.widget_HDR.user.Initialize = function()
	-- initalize widget
	-- let widget reflect state of globals
--	local cur_HDRRendering = tonumber( getglobal( "r_HDRRendering" ) );

--	if( cur_HDRRendering == 0) then
--		UI.PageOptionsVideoAdv.GUI.widget_HDR:SetChecked( 0 ); -- disabled
--	else
--		UI.PageOptionsVideoAdv.GUI.widget_HDR:SetChecked( 1 ); -- enabled
--	end
		
--	if (System:IsHDRSupported()) then
--		UI:EnableWidget(UI.PageOptionsVideoAdv.GUI.widget_HDR);
--	else
--		UI:DisableWidget(UI.PageOptionsVideoAdv.GUI.widget_HDR);
--	end	
--end

--UI.PageOptionsVideoAdv.GUI.widget_HDR.user.UpdateAssignedGlobals = function()
--	local curEnabled = UI.PageOptionsVideoAdv.GUI.widget_HDR:GetChecked();
	
--	if(curEnabled) then
		-- enabled
--		UI.PageOptionsVideoAdv.user:SetGlobal( "r_HDRRendering", 7 );
--	else
		-- disabled
--		UI.PageOptionsVideoAdv.user:SetGlobal( "r_HDRRendering", 0 );
--	end
--end

--UI.PageOptionsVideoAdv.GUI.widget_HDR.user.SetToSpec = function( spec )
--	if( spec == "auto" ) then
--		UI.PageOptionsVideoAdv.GUI.widget_HDR:SetChecked(0);
--	elseif(( spec == "veryhigh") and System:IsHDRSupported()) then
--		UI.PageOptionsVideoAdv.GUI.widget_HDR:SetChecked(1);
--	elseif( spec == "high" ) then
--		UI.PageOptionsVideoAdv.GUI.widget_HDR:SetChecked(0);
--	elseif( spec == "medium" ) then
--		UI.PageOptionsVideoAdv.GUI.widget_HDR:SetChecked(0);
--	else
--		UI.PageOptionsVideoAdv.GUI.widget_HDR:SetChecked(0);
--	end
--end
--UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure.user.Initialize = function( self )
--	local HDRLevel = tonumber( getglobal( "r_HDRLevel" ) );
--	UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure:SetValue( HDRLevel );

--	if (System:IsHDRSupported()) then
--		UI:EnableWidget(UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure);
--	else
--		UI:DisableWidget(UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure);
--	end	
	
--end

--UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure.user.DefInitialize = function( self )
--	UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure:SetValue( 0.6 );
--end

--UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure.user.UpdateAssignedGlobals = function( self )
--end

--UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure.user.OnChanged = function( self )
	-- get normalize level [0 .. 1] from slider widget
--	local level = tonumber( UI.PageOptionsVideoAdv.GUI.widget_HDR_exposure:GetValue() );
--	if( level < 0.1 ) then
--		level = 0.1;
--	elseif( level > 1.0 ) then
--		level = 1.0;
--	end;
	-- set HDR level
--	setglobal( "r_HDRLevel", level );
--end;

-- code for specific behaviour of individual widgets
UI.PageOptionsVideoAdv.GUI.widget_TextureQuality.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:AddItem( Localize( "Low" ) );
	UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:AddItem( Localize( "Medium" ) );
	UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:AddItem( Localize( "High" ) );
	UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:AddItem( Localize( "VeryHigh" ) );

	-- let widget reflect state of globals
	local cur_r_TexResolution = tonumber( getglobal( "r_TexResolution" ) );
	local cur_r_TexSkyResolution = tonumber( getglobal( "r_TexSkyResolution" ) );
	local cur_r_TexBumpResolution = tonumber( getglobal( "r_TexBumpResolution" ) );
	local cur_e_detail_texture_quality = tonumber( getglobal( "e_detail_texture_quality" ) );
	local cur_r_DetailTextures = tonumber( getglobal( "r_DetailTextures" ) );
	local cur_r_DetailNumLayers = tonumber( getglobal( "r_DetailNumLayers" ) );
	local cur_r_DetailDistance = tonumber( getglobal( "r_DetailDistance" ) );

	if( cur_r_TexResolution == 2 and
		cur_r_TexSkyResolution == 2 and
		cur_r_TexBumpResolution == 2 and
		cur_e_detail_texture_quality == 0 and
		cur_r_DetailTextures == 0 and
		cur_r_DetailNumLayers == 0 and
		cur_r_DetailDistance == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 1 ); -- low quality
	elseif( cur_r_TexResolution == 1 and
			cur_r_TexSkyResolution == 1 and
			cur_r_TexBumpResolution == 1 and
			cur_e_detail_texture_quality == 1 and
			cur_r_DetailTextures == 1 and
			cur_r_DetailNumLayers == 1 and
			cur_r_DetailDistance == 4 ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 2 ); -- medium quality
	elseif( cur_r_TexResolution == 0 and
			cur_r_TexSkyResolution == 0 and
			cur_r_TexBumpResolution == 0 and
			cur_e_detail_texture_quality == 1 and
			cur_r_DetailTextures == 1 and
			cur_r_DetailNumLayers == 1 and
			cur_r_DetailDistance == 8 ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 3 ); -- high quality
	elseif( cur_r_TexResolution == 0 and
			cur_r_TexSkyResolution == 0 and
			cur_r_TexBumpResolution == 0 and
			cur_e_detail_texture_quality == 1 and
			cur_r_DetailTextures == 1 and
			cur_r_DetailNumLayers == 2 and
			cur_r_DetailDistance == 16 ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 4 ); -- very high quality
	else
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 5 ); -- custom quality
	end
end

UI.PageOptionsVideoAdv.GUI.widget_TextureQuality.user.UpdateAssignedGlobals = function()
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		-- low quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexResolution", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexSkyResolution", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexBumpResolution", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_detail_texture_quality", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailTextures", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailNumLayers", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailDistance", 0 );
	elseif( curSelectionIndex == 2 ) then
		-- medium quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexResolution", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexSkyResolution", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexBumpResolution", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_detail_texture_quality", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailTextures", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailNumLayers", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailDistance", 4 );
	elseif( curSelectionIndex == 3 ) then
		-- high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexResolution", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexSkyResolution", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexBumpResolution", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_detail_texture_quality", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailTextures", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailNumLayers", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailDistance", 8 );
	elseif( curSelectionIndex == 4 ) then
		-- very high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexResolution", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexSkyResolution", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_TexBumpResolution", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_detail_texture_quality", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailTextures", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailNumLayers", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DetailDistance", 16 );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_TextureQuality.user.SetToSpec = function( spec )
	if( spec == "auto" ) then
		local res = tonumber( UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( 0, 1, 0, 1 ) );
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( res );
	elseif( spec == "veryhigh" ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 4 );
	elseif( spec == "high" ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 3 );
	elseif( spec == "medium" ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 2 );
	else
		UI.PageOptionsVideoAdv.GUI.widget_TextureQuality:SelectIndex( 1 );
	end
end



UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:AddItem( Localize( "Bilinear" ) );
	UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:AddItem( Localize( "Trilinear" ) );

	-- let widget reflect state of globals
	local cur_d3d9_TextureFilter = getglobal( "d3d9_TextureFilter" );
	local cur_GL_TextureFilter = getglobal( "GL_TextureFilter" );

	if( ( cur_d3d9_TextureFilter == "BILINEAR" or
		  cur_GL_TextureFilter == "GL_LINEAR_MIPMAP_NEAREST" ) ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:SelectIndex( 1 ); -- low quality
	elseif( ( cur_d3d9_TextureFilter == "TRILINEAR" or
			  cur_GL_TextureFilter == "GL_LINEAR_MIPMAP_LINEAR" ) ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:SelectIndex( 2 ); -- high quality
	else
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:SelectIndex( 3 ); -- custom quality
	end
end

UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality.user.UpdateAssignedGlobals = function( self )
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		-- bilinear quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "d3d9_TextureFilter", "BILINEAR" );
		UI.PageOptionsVideoAdv.user:SetGlobal( "GL_TextureFilter", "GL_LINEAR_MIPMAP_NEAREST" );
	elseif( curSelectionIndex == 2 ) then
		-- trilinear quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "d3d9_TextureFilter", "TRILINEAR" );
		UI.PageOptionsVideoAdv.user:SetGlobal( "GL_TextureFilter", "GL_LINEAR_MIPMAP_LINEAR" );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality.user.SetToSpec = function( spec )
	if( spec == "auto" ) then
		local res = tonumber( UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( 0, 1, 0, 0 ) );
		if( res > 2 ) then
			res = 2;
		end
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:SelectIndex( res );
	elseif( spec == "veryhigh" ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:SelectIndex( 2 );
	elseif( spec == "high" ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:SelectIndex( 2 );
	elseif( spec == "medium" ) then
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:SelectIndex( 2 );
	else
		UI.PageOptionsVideoAdv.GUI.widget_TextureFilterQuality:SelectIndex( 1 );
	end
end



UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:AddItem( 1 );
	UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:AddItem( 2 );
	UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:AddItem( 4 );
	UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:AddItem( 8 );
	UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:AddItem( 16 );

	-- let widget reflect state of globals
	local cur_r_Texture_Anisotropic_Level = tonumber( getglobal( "r_Texture_Anisotropic_Level" ) );

	if( cur_r_Texture_Anisotropic_Level == 1 ) then
		UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:SelectIndex( 1 ); -- level 1
	elseif( cur_r_Texture_Anisotropic_Level == 2 ) then
		UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:SelectIndex( 2 ); -- level 2
	elseif( cur_r_Texture_Anisotropic_Level == 4 ) then
		UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:SelectIndex( 3 ); -- level 4
	elseif( cur_r_Texture_Anisotropic_Level == 8 ) then
		UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:SelectIndex( 4 ); -- level 8
	elseif( cur_r_Texture_Anisotropic_Level == 16 ) then
		UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:SelectIndex( 5 ); -- level 16
	else
		UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:SelectIndex( 6 ); -- custom level
	end
end

UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel.user.UpdateAssignedGlobals = function()
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		setglobal( "r_Texture_Anisotropic_Level", 1 );
	elseif( curSelectionIndex == 2 ) then
		setglobal( "r_Texture_Anisotropic_Level", 2 );
	elseif( curSelectionIndex == 3 ) then
		setglobal( "r_Texture_Anisotropic_Level", 4 );
	elseif( curSelectionIndex == 4 ) then
		setglobal( "r_Texture_Anisotropic_Level", 8 );
	elseif( curSelectionIndex == 5 ) then
		setglobal( "r_Texture_Anisotropic_Level", 16 );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel.user.SetToSpec = function( spec )
	UI.PageOptionsVideoAdv.GUI.widget_AnisotropicFilteringLevel:SelectIndex( 4 );
end



UI.PageOptionsVideoAdv.GUI.widget_ParticleCount.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:AddItem( Localize( "Low" ) );
	UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:AddItem( Localize( "Medium" ) );
	UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:AddItem( Localize( "High" ) );
	UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:AddItem( Localize( "VeryHigh" ) );

	-- let widget reflect state of globals
	local cur_e_particles_max_count = tonumber( getglobal( "e_particles_max_count" ) );
	local cur_e_particles_lod = tonumber( getglobal( "e_particles_lod" ) );

	if( cur_e_particles_max_count == 512 and
	    cur_e_particles_lod == 0.5 ) then
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 1 ); -- low quality
	elseif( cur_e_particles_max_count == 2048 and
			cur_e_particles_lod == 0.75 ) then
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 2 ); -- medium quality
	elseif( cur_e_particles_max_count == 4096 and
			cur_e_particles_lod == 1.0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 3 ); -- high quality
	elseif( cur_e_particles_max_count == 8192 and
			cur_e_particles_lod == 1.0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 4 ); -- very high quality
	else
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 5 ); -- custom quality
	end
end

UI.PageOptionsVideoAdv.GUI.widget_ParticleCount.user.UpdateAssignedGlobals = function()
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		-- low quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_particles_max_count", 512 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_particles_lod", 0.5 );
	elseif( curSelectionIndex == 2 ) then
		-- medium quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_particles_max_count", 2048 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_particles_lod", 0.75 );
	elseif( curSelectionIndex == 3 ) then
		-- high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_particles_max_count", 4096 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_particles_lod", 1.0 );
	elseif( curSelectionIndex == 4 ) then
		-- very high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_particles_max_count", 8192 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_particles_lod", 1.0 );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_ParticleCount.user.SetToSpec = function( spec )
	if( spec == "auto" ) then
		local res = tonumber( UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( 1, 1, 0, 0 ) );
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( res );
	elseif( spec == "veryhigh" ) then
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 4 );
	elseif( spec == "high" ) then
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 3 );
	elseif( spec == "medium" ) then
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 2 );
	else
		UI.PageOptionsVideoAdv.GUI.widget_ParticleCount:SelectIndex( 1 );
	end
end



UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:AddItem( Localize( "Low" ) );
	UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:AddItem( Localize( "Medium" ) );
	UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:AddItem( Localize( "High" ) );
	UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:AddItem( Localize( "VeryHigh" ) );

	-- let widget reflect state of globals
	local cur_r_MotionBlur = tonumber( getglobal( "r_MotionBlur" ) );
	local cur_r_Glare = tonumber( getglobal( "r_Glare" ) );
	local cur_r_GlareQuality = tonumber( getglobal( "r_GlareQuality" ) );
	local cur_r_Flares = tonumber( getglobal( "r_Flares" ) );
	local cur_r_checkSunVis = tonumber( getglobal( "r_checkSunVis" ) );
	local cur_r_Coronas = tonumber( getglobal( "r_Coronas" ) );
	local cur_r_CoronaFade = tonumber( getglobal( "r_CoronaFade" ) );
	local cur_r_HeatHaze = tonumber( getglobal( "r_HeatHaze" ) );
	local cur_r_ScopeLens_fx = tonumber( getglobal( "r_ScopeLens_fx" ) );
	local cur_r_ProcFlares = tonumber( getglobal( "r_ProcFlares" ) );
	local cur_r_CryvisionType = tonumber( getglobal( "r_CryvisionType" ) );
	local cur_r_DisableSfx = tonumber( getglobal( "r_DisableSfx" ) );
	local cur_r_Beams = tonumber( getglobal( "r_Beams" ) );
	local cur_es_EnableCloth = tonumber( getglobal( "es_EnableCloth" ) );

	if( cur_r_MotionBlur == 0 and
	 	cur_r_Glare == 0 and
	 	cur_r_GlareQuality == 0 and
	 	cur_r_Flares == 0 and
	 	cur_r_checkSunVis == 0 and
	 	cur_r_Coronas == 0 and
	 	cur_r_CoronaFade == 0.0 and
	 	cur_r_HeatHaze == 0 and
	 	cur_r_ScopeLens_fx == 0 and
	 	cur_r_ProcFlares == 0 and
	 	cur_r_CryvisionType == 2 and
	 	cur_r_DisableSfx == 1 and
	 	cur_r_Beams == 0 and
	 	cur_es_EnableCloth == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 1 ); -- low quality
	elseif( cur_r_MotionBlur == 0 and
		 	cur_r_Glare == 0 and
		 	cur_r_GlareQuality == 1 and
		 	cur_r_Flares == 1 and
		 	cur_r_checkSunVis == 1 and
		 	cur_r_Coronas == 1 and
		 	cur_r_CoronaFade == 0.2 and
		 	cur_r_HeatHaze == 0 and
		 	cur_r_ScopeLens_fx == 0 and
		 	cur_r_ProcFlares == 1 and
		 	cur_r_CryvisionType == 1 and
	 		cur_r_DisableSfx == 0 and
	 		cur_r_Beams == 1 and
		 	cur_es_EnableCloth == 1 ) then
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 2 ); -- medium quality
	elseif( cur_r_MotionBlur == 0 and
		 	cur_r_Glare > 0 and
		 	cur_r_GlareQuality == 2 and
		 	cur_r_Flares == 1 and
		 	cur_r_checkSunVis == 2 and
		 	cur_r_Coronas == 1 and
		 	cur_r_CoronaFade == 0.1625 and
		 	cur_r_HeatHaze == 1 and
		 	cur_r_ScopeLens_fx == 1 and
		 	cur_r_ProcFlares == 1 and
		 	cur_r_CryvisionType == 0 and
	 		cur_r_DisableSfx == 0 and
	 		cur_r_Beams == 1 and
		 	cur_es_EnableCloth == 1 ) then
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 3 ); -- high quality
	elseif( cur_r_MotionBlur == 0 and
		 	cur_r_Glare > 0 and
		 	cur_r_GlareQuality == 2 and
		 	cur_r_Flares == 1 and
		 	cur_r_checkSunVis == 2 and
		 	cur_r_Coronas == 1 and
		 	cur_r_CoronaFade == 0.125 and
		 	cur_r_HeatHaze == 1 and
		 	cur_r_ScopeLens_fx == 1 and
		 	cur_r_ProcFlares == 1 and
		 	cur_r_CryvisionType == 0 and
	 		cur_r_DisableSfx == 0 and
	 		cur_r_Beams == 1 and
		 	cur_es_EnableCloth == 1 ) then
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 4 ); -- very high quality
	else
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 5 ); -- custom quality
	end
end

UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects.user.UpdateAssignedGlobals = function()
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		-- low quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_MotionBlur", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Glare", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_RenderMode", 0 ); -- additionally set render mode to "Default" as r_Glare is set to "0"
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_GlareQuality", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Flares", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_checkSunVis", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Coronas", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_CoronaFade", 0.0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_HeatHaze", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ScopeLens_fx", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ProcFlares", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_CryvisionType", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DisableSfx", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Beams", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "es_EnableCloth", 0 );
	elseif( curSelectionIndex == 2 ) then
		-- medium quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_MotionBlur", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Glare", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_RenderMode", 0 ); -- additionally set render mode to "Default" as r_Glare is set to "0"
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_GlareQuality", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Flares", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_checkSunVis", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Coronas", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_CoronaFade", 0.2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_HeatHaze", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ScopeLens_fx", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ProcFlares", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_CryvisionType", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DisableSfx", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Beams", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "es_EnableCloth", 1 );
	elseif( curSelectionIndex == 3 ) then
		-- high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_MotionBlur", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Glare", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_GlareQuality", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Flares", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_checkSunVis", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Coronas", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_CoronaFade", 0.1625 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_HeatHaze", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ScopeLens_fx", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ProcFlares", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_CryvisionType", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DisableSfx", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Beams", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "es_EnableCloth", 1 );
	elseif( curSelectionIndex == 4 ) then
		-- very high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_MotionBlur", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Glare", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_GlareQuality", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Flares", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_checkSunVis", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Coronas", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_CoronaFade", 0.125 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_HeatHaze", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ScopeLens_fx", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ProcFlares", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_CryvisionType", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_DisableSfx", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Beams", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "es_EnableCloth", 1 );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects.user.SetToSpec = function( spec )
	if( spec == "auto" ) then
		local res = tonumber( UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( 1, 1, 0, 0 ) );
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( res );
	elseif( spec == "veryhigh" ) then
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 4 );
	elseif( spec == "high" ) then
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 3 );
	elseif( spec == "medium" ) then
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 2 );
	else
		UI.PageOptionsVideoAdv.GUI.widget_SpecialEffects:SelectIndex( 1 );
	end
end



UI.PageOptionsVideoAdv.GUI.widget_Environment.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_Environment:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_Environment:AddItem( Localize( "Low" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Environment:AddItem( Localize( "Medium" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Environment:AddItem( Localize( "High" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Environment:AddItem( Localize( "VeryHigh" ) );

	-- let widget reflect state of globals
	local cur_r_VolumetricFog = tonumber( getglobal( "r_VolumetricFog" ) );
	local cur_r_EnvCMResolution = tonumber( getglobal( "r_EnvCMResolution" ) );
	local cur_r_EnvCMupdateInterval = tonumber( getglobal( "r_EnvCMupdateInterval" ) );
	local cur_r_EnvTexResolution = tonumber( getglobal( "r_EnvTexResolution" ) );
	local cur_r_EnvTexUpdateInterval = tonumber( getglobal( "r_EnvTexUpdateInterval" ) );
	local cur_e_decals = tonumber( getglobal( "e_decals" ) );
	local cur_e_decals_life_time_scale = tonumber( getglobal( "e_decals_life_time_scale" ) );
	local cur_ca_EnableDecals = tonumber( getglobal( "ca_EnableDecals" ) );
	local cur_e_overlay_geometry = tonumber( getglobal( "e_overlay_geometry" ) );
	local cur_e_obj_lod_ratio = tonumber( getglobal( "e_obj_lod_ratio" ) );
	local cur_e_vegetation_sprites_distance_ratio = tonumber( getglobal( "e_vegetation_sprites_distance_ratio" ) );
	local cur_e_cgf_load_lods = tonumber( getglobal( "e_cgf_load_lods" ) );
	local cur_e_vegetation_min_size = tonumber( getglobal( "e_vegetation_min_size" ) );
	local cur_e_flocks = tonumber( getglobal( "e_flocks" ) );
	local cur_e_EntitySuppressionLevel = tonumber( getglobal( "e_EntitySuppressionLevel" ) );
	local cur_sys_skiponlowspec = tonumber( getglobal( "sys_skiponlowspec" ) );

	if( cur_r_VolumetricFog == 0 and
		cur_r_EnvCMResolution == 1 and
		cur_r_EnvCMupdateInterval == 0.2 and
		cur_r_EnvTexResolution == 1 and
		cur_r_EnvTexUpdateInterval == 0.1 and
		cur_e_decals == 0 and
		cur_e_decals_life_time_scale == 0.5 and
		cur_ca_EnableDecals == 0 and
		cur_e_overlay_geometry == 0 and
		cur_e_obj_lod_ratio == 5 and
		cur_e_vegetation_sprites_distance_ratio == 0.9 and
		cur_e_cgf_load_lods == 1 and
		cur_e_vegetation_min_size == 2.2 and
		cur_e_flocks == 0 and
		cur_e_EntitySuppressionLevel == 2 and
		cur_sys_skiponlowspec == 1 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 1 ); -- low quality
	elseif( cur_r_VolumetricFog == 1 and
			cur_r_EnvCMResolution == 1 and
			cur_r_EnvCMupdateInterval == 0.15 and
			cur_r_EnvTexResolution == 2 and
			cur_r_EnvTexUpdateInterval == 0.075 and
			cur_e_decals == 1 and
			cur_e_decals_life_time_scale == 1.0 and
			cur_ca_EnableDecals == 1 and
			cur_e_overlay_geometry == 1 and
			cur_e_obj_lod_ratio == 5 and
			cur_e_vegetation_sprites_distance_ratio == 0.9 and
			cur_e_cgf_load_lods == 1 and
			cur_e_vegetation_min_size == 2.2 and
			cur_e_flocks == 0 and
			cur_e_EntitySuppressionLevel == 2 and
			cur_sys_skiponlowspec == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 2 ); -- medium quality
	elseif( cur_r_VolumetricFog == 1 and
			cur_r_EnvCMResolution == 2 and
			cur_r_EnvCMupdateInterval == 0.1 and
			cur_r_EnvTexResolution == 3 and
			cur_r_EnvTexUpdateInterval == 0.05 and
			cur_e_decals == 1 and
			cur_e_decals_life_time_scale == 2.0 and
			cur_ca_EnableDecals == 1 and
			cur_e_overlay_geometry == 1 and
			cur_e_obj_lod_ratio == 10 and
			cur_e_vegetation_sprites_distance_ratio == 50.0 and
			cur_e_cgf_load_lods == 1 and
			cur_e_vegetation_min_size == 0 and
			cur_e_flocks == 1 and
			cur_e_EntitySuppressionLevel == 0 and
			cur_sys_skiponlowspec == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 3 ); -- high quality
	elseif( cur_r_VolumetricFog == 1 and
			cur_r_EnvCMResolution == 2 and
			cur_r_EnvCMupdateInterval == 0.05 and
			cur_r_EnvTexResolution == 3 and
			cur_r_EnvTexUpdateInterval == 0.001 and
			cur_e_decals == 1 and
			cur_e_decals_life_time_scale == 3.0 and
			cur_ca_EnableDecals == 1 and
			cur_e_overlay_geometry == 1 and
			cur_e_obj_lod_ratio == 10 and
			cur_e_vegetation_sprites_distance_ratio == 100.0 and
			cur_e_cgf_load_lods == 0 and
			cur_e_vegetation_min_size == 0 and
			cur_e_flocks == 1 and
			cur_e_EntitySuppressionLevel == 0 and
			cur_sys_skiponlowspec == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 4 ); -- very high quality
	else
		UI.PageOptionsVideoAdv.GUI.widget_Environment:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 5 ); -- custom quality
	end
end

UI.PageOptionsVideoAdv.GUI.widget_Environment.user.UpdateAssignedGlobals = function()
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_Environment:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		-- low quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_VolumetricFog", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvCMResolution", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvCMupdateInterval", 0.2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvTexResolution", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvTexUpdateInterval", 0.1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_decals", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_decals_life_time_scale", 0.5 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_EnableDecals", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_overlay_geometry", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_obj_lod_ratio", 5 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_vegetation_sprites_distance_ratio", 0.9 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_cgf_load_lods", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_vegetation_min_size", 2.2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_flocks", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_EntitySuppressionLevel", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "sys_skiponlowspec", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "vr_render_force_obj_draw_dist", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "vr_render_force_max_terrain_detail", 0 );
	elseif( curSelectionIndex == 2 ) then
		-- medium quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_VolumetricFog", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvCMResolution", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvCMupdateInterval", 0.15 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvTexResolution", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvTexUpdateInterval", 0.075 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_decals", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_decals_life_time_scale", 1.0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_EnableDecals", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_overlay_geometry", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_obj_lod_ratio", 5 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_vegetation_sprites_distance_ratio", 0.9 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_cgf_load_lods", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_vegetation_min_size", 2.2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_flocks", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_EntitySuppressionLevel", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "sys_skiponlowspec", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "vr_render_force_obj_draw_dist", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "vr_render_force_max_terrain_detail", 0 );
	elseif( curSelectionIndex == 3 ) then
		-- high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_VolumetricFog", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvCMResolution", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvCMupdateInterval", 0.1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvTexResolution", 3 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvTexUpdateInterval", 0.05 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_decals", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_decals_life_time_scale", 2.0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_EnableDecals", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_overlay_geometry", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_obj_lod_ratio", 10 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_vegetation_sprites_distance_ratio", 50.0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_cgf_load_lods", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_vegetation_min_size", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_flocks", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_EntitySuppressionLevel", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "sys_skiponlowspec", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "vr_render_force_obj_draw_dist", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "vr_render_force_max_terrain_detail", 1 );
	elseif( curSelectionIndex == 4 ) then
		-- very high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_VolumetricFog", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvCMResolution", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvCMupdateInterval", 0.05 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvTexResolution", 3 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvTexUpdateInterval", 0.001 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_decals", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_decals_life_time_scale", 3.0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_EnableDecals", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_overlay_geometry", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_obj_lod_ratio", 50 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_vegetation_sprites_distance_ratio", 100.0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_cgf_load_lods", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_vegetation_min_size", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_flocks", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_EntitySuppressionLevel", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "sys_skiponlowspec", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "vr_render_force_obj_draw_dist", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "vr_render_force_max_terrain_detail", 1 );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_Environment.user.SetToSpec = function( spec )
	if( spec == "auto" ) then
		local res = tonumber( UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( 1, 1, 0, 0 ) );
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( res );
	elseif( spec == "veryhigh" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 4 );
	elseif( spec == "high" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 3 );
	elseif( spec == "medium" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 2 );
	else
		UI.PageOptionsVideoAdv.GUI.widget_Environment:SelectIndex( 1 );
	end
end



UI.PageOptionsVideoAdv.GUI.widget_Shadow.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_Shadow:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_Shadow:AddItem( Localize( "Low" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Shadow:AddItem( Localize( "Medium" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Shadow:AddItem( Localize( "High" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Shadow:AddItem( Localize( "VeryHigh" ) );

	-- let widget reflect state of globals
	local cur_e_stencil_shadows = tonumber( getglobal( "e_stencil_shadows" ) );
	local cur_e_shadow_maps = tonumber( getglobal( "e_shadow_maps" ) );
	local cur_e_active_shadow_maps_receving = tonumber( getglobal( "e_active_shadow_maps_receving" ) );
	local cur_r_ShadowBlur = tonumber( getglobal( "r_ShadowBlur" ) );
	--local cur_r_SelfShadow  = tonumber( getglobal( "r_SelfShadow" ) );
	local cur_e_shadow_maps_view_dist_ratio = tonumber( getglobal( "e_shadow_maps_view_dist_ratio" ) );

	if( cur_e_stencil_shadows == 0 and
		cur_e_shadow_maps == 0 and
		cur_e_active_shadow_maps_receving == 0 and
		cur_r_ShadowBlur == 0 and --cur_r_SelfShadow == 0 and
		cur_e_shadow_maps_view_dist_ratio == 10 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 1 ); -- low quality
	elseif( cur_e_stencil_shadows == 1 and
			cur_e_shadow_maps == 0 and
			cur_e_active_shadow_maps_receving == 0 and
			cur_r_ShadowBlur == 0 and --cur_r_SelfShadow == 0 and
			cur_e_shadow_maps_view_dist_ratio == 10 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 2 ); -- medium quality
	elseif( cur_e_stencil_shadows == 1 and
			cur_e_shadow_maps == 1 and
			cur_e_active_shadow_maps_receving == 1 and
			cur_r_ShadowBlur == 1 and --cur_r_SelfShadow == 0 and
			cur_e_shadow_maps_view_dist_ratio == 15 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 3 ); -- high quality
	elseif( cur_e_stencil_shadows == 1 and
			cur_e_shadow_maps == 1 and
			cur_e_active_shadow_maps_receving == 2 and
			cur_r_ShadowBlur == 2 and --cur_r_SelfShadow == 1 and
			cur_e_shadow_maps_view_dist_ratio == 20 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 4 ); -- very high quality
	else
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 5 ); -- custom quality
	end
end

UI.PageOptionsVideoAdv.GUI.widget_Shadow.user.UpdateAssignedGlobals = function()
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_Shadow:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		-- low quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_stencil_shadows", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_shadow_maps", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_active_shadow_maps_receving", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ShadowBlur", 0 );
		--UI.PageOptionsVideoAdv.user:SetGlobal( "r_SelfShadow", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_shadow_maps_view_dist_ratio", 10 );
	elseif( curSelectionIndex == 2 ) then
		-- medium quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_stencil_shadows", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_shadow_maps", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_active_shadow_maps_receving", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ShadowBlur", 0 );
		--UI.PageOptionsVideoAdv.user:SetGlobal( "r_SelfShadow", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_shadow_maps_view_dist_ratio", 10 );
	elseif( curSelectionIndex == 3 ) then
		-- high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_stencil_shadows", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_shadow_maps", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_active_shadow_maps_receving", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ShadowBlur", 1 );
		--UI.PageOptionsVideoAdv.user:SetGlobal( "r_SelfShadow", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_shadow_maps_view_dist_ratio", 15 );
	elseif( curSelectionIndex == 4 ) then
		-- very high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_stencil_shadows", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_shadow_maps", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_active_shadow_maps_receving", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_ShadowBlur", 2 );
		--UI.PageOptionsVideoAdv.user:SetGlobal( "r_SelfShadow", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_shadow_maps_view_dist_ratio", 20 );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_Shadow.user.SetToSpec = function( spec )
	if( spec == "auto" ) then
		local res = tonumber( UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( 1, 1, 0, 0 ) );
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( res );
	elseif( spec == "veryhigh" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 4 );
	elseif( spec == "high" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 3 );
	elseif( spec == "medium" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 2 );
	else
		UI.PageOptionsVideoAdv.GUI.widget_Shadow:SelectIndex( 1 );
	end
end



UI.PageOptionsVideoAdv.GUI.widget_Water.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_Water:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_Water:AddItem( Localize( "Low" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Water:AddItem( Localize( "Medium" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Water:AddItem( Localize( "High" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Water:AddItem( Localize( "VeryHigh" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Water:AddItem( Localize( "UltraHigh" ) );

	-- let widget reflect state of globals
	local cur_r_WaterRefractions = tonumber( getglobal( "r_WaterRefractions" ) );
	local cur_r_WaterReflections = tonumber( getglobal( "r_WaterReflections" ) );
	local cur_r_WaterUpdateFactor = tonumber( getglobal( "r_WaterUpdateFactor" ) );
	local cur_r_Quality_Reflection = tonumber( getglobal( "r_Quality_Reflection" ) );
	local cur_e_beach = tonumber( getglobal( "e_beach" ) );
	local cur_e_use_global_fog_in_fog_volumes = tonumber( getglobal( "e_use_global_fog_in_fog_volumes" ) );

	if( cur_r_WaterRefractions == 0 and
		cur_r_WaterReflections == 0 and
		cur_r_WaterUpdateFactor == 0.02 and
		cur_r_Quality_Reflection == 0 and
		cur_e_beach== 0 and
		cur_e_use_global_fog_in_fog_volumes == 1 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 1 ); -- low quality
	elseif( cur_r_WaterRefractions == 0 and
		cur_r_WaterReflections == 1 and
		cur_r_WaterUpdateFactor == 0.015 and
		cur_r_Quality_Reflection == 0 and
		cur_e_beach== 1 and
		cur_e_use_global_fog_in_fog_volumes == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 2 ); -- medium quality
	elseif( cur_r_WaterRefractions == 1 and
		cur_r_WaterReflections == 1 and
		cur_r_WaterUpdateFactor == 0.01 and
		cur_r_Quality_Reflection == 0 and
		cur_e_beach== 1 and
		cur_e_use_global_fog_in_fog_volumes == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 3 ); -- high quality
	elseif( cur_r_WaterRefractions == 1 and
		cur_r_WaterReflections == 1 and
		cur_r_WaterUpdateFactor == 0.001 and
		cur_r_Quality_Reflection == 0 and
		cur_e_beach== 1 and
		cur_e_use_global_fog_in_fog_volumes == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 4 ); -- very high quality
	elseif( cur_r_WaterRefractions == 1 and
		cur_r_WaterReflections == 1 and
		cur_r_WaterUpdateFactor == 0.001 and
		cur_r_Quality_Reflection == 1 and
		cur_e_beach== 1 and
		cur_e_use_global_fog_in_fog_volumes == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 5 ); -- ultra high quality
	else
		UI.PageOptionsVideoAdv.GUI.widget_Water:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 6 ); -- custom quality
	end
end

UI.PageOptionsVideoAdv.GUI.widget_Water.user.UpdateAssignedGlobals = function()
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_Water:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		-- low quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterRefractions", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterReflections", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterUpdateFactor", 0.02 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_Reflection", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_beach", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_use_global_fog_in_fog_volumes", 1 );
	elseif( curSelectionIndex == 2 ) then
		-- medium quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterRefractions", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterReflections", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterUpdateFactor", 0.015 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_Reflection", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_beach", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_use_global_fog_in_fog_volumes", 0 );
	elseif( curSelectionIndex == 3 ) then
		-- high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterRefractions", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterReflections", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterUpdateFactor", 0.01 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_Reflection", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_beach", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_use_global_fog_in_fog_volumes", 0 );
	elseif( curSelectionIndex == 4 ) then
		-- very high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterRefractions", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterReflections", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterUpdateFactor", 0.001 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_Reflection", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_beach", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_use_global_fog_in_fog_volumes", 0 );
	elseif( curSelectionIndex == 5 ) then
		-- very high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterRefractions", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterReflections", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_WaterUpdateFactor", 0.001 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_Reflection", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_beach", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_use_global_fog_in_fog_volumes", 0 );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_Water.user.SetToSpec = function( spec )
	if( spec == "auto" ) then
		local res = tonumber( UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( 0, 1, 0, 0 ) );
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( res );
	elseif( spec == "veryhigh" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 4 );
	elseif( spec == "high" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 3 );
	elseif( spec == "medium" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 2 );
	else
		UI.PageOptionsVideoAdv.GUI.widget_Water:SelectIndex( 1 );
	end
end



UI.PageOptionsVideoAdv.GUI.widget_Lighting.user.Initialize = function()
	-- initalize widget
	UI.PageOptionsVideoAdv.GUI.widget_Lighting:Clear();

	UI.PageOptionsVideoAdv.GUI.widget_Lighting:AddItem( Localize( "Low" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Lighting:AddItem( Localize( "Medium" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Lighting:AddItem( Localize( "High" ) );
	UI.PageOptionsVideoAdv.GUI.widget_Lighting:AddItem( Localize( "VeryHigh" ) );

	-- let widget reflect state of globals
	local cur_r_Quality_BumpMapping = tonumber( getglobal( "r_Quality_BumpMapping" ) );
	local cur_r_Vegetation_PerpixelLight = tonumber( getglobal( "r_Vegetation_PerpixelLight" ) );
	local cur_e_light_maps_quality = tonumber( getglobal( "e_light_maps_quality" ) );
	local cur_ca_ambient_light_intensity = tonumber( getglobal( "ca_ambient_light_intensity" ) );
	local cur_ca_ambient_light_range = tonumber( getglobal( "ca_ambient_light_range" ) );
	local cur_e_max_entity_lights = tonumber( getglobal( "e_max_entity_lights" ) );
	local cur_e_stencil_shadows_only_from_strongest_light = tonumber( getglobal( "e_stencil_shadows_only_from_strongest_light" ) );
	local cur_p_lightrange = tonumber( getglobal( "p_lightrange" ) );
	local cur_r_EnvLightCMSize = tonumber( getglobal( "r_EnvLightCMSize" ) );
	local cur_r_EnvLCMupdateInterval = tonumber( getglobal( "r_EnvLCMupdateInterval" ) );
	local cur_cl_projectile_light = tonumber(  getglobal( "cl_projectile_light" ) );
	local cur_cl_weapon_light = tonumber(  getglobal( "cl_weapon_light" ) );

	local ps20Support = tonumber( System:IsPS20Supported() );

	if( cur_r_Quality_BumpMapping == 0 and
	    cur_r_Vegetation_PerpixelLight == 0 and
		cur_e_light_maps_quality == 0 and
		cur_ca_ambient_light_intensity == 0.2 and
		cur_ca_ambient_light_range == 0 and
		cur_e_max_entity_lights == 2 and
		cur_e_stencil_shadows_only_from_strongest_light == 1 and
		cur_p_lightrange == 8 and
		cur_r_EnvLightCMSize == 8 and
		cur_r_EnvLCMupdateInterval == 0.1 and
		cur_cl_projectile_light == 0 and
		cur_cl_weapon_light == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 1 ); -- low quality
	elseif( cur_r_Quality_BumpMapping == 1 and
			cur_r_Vegetation_PerpixelLight == 0 and
			cur_e_light_maps_quality == 1 and
			cur_ca_ambient_light_intensity == 0.2 and
			cur_ca_ambient_light_range == 10 and
			cur_e_max_entity_lights == 2 and
			cur_e_stencil_shadows_only_from_strongest_light == 1 and
     		cur_p_lightrange == 10 and
			cur_r_EnvLightCMSize == 8 and
			cur_r_EnvLCMupdateInterval == 0.1 and
			cur_cl_projectile_light == 0 and
			cur_cl_weapon_light == 0 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 2 ); -- medium quality
	elseif( cur_r_Quality_BumpMapping == 2 and
			cur_r_Vegetation_PerpixelLight == 1 and
			cur_e_light_maps_quality == 2 and
			cur_ca_ambient_light_intensity == 0.2 and
			cur_ca_ambient_light_range == 10 and
			cur_e_max_entity_lights == 3 and
			cur_e_stencil_shadows_only_from_strongest_light == 0 and
			cur_p_lightrange == 15 and
			cur_r_EnvLightCMSize == 8 and
			cur_r_EnvLCMupdateInterval == 0.1 and
			cur_cl_projectile_light == 1 and
			cur_cl_weapon_light == 1 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 3 ); -- high quality
	elseif( ( cur_r_Quality_BumpMapping == 3 or ps20Support == 0 ) and
			cur_r_Vegetation_PerpixelLight == 1 and
			cur_e_light_maps_quality == 2 and
			cur_ca_ambient_light_intensity == 0.2 and
			cur_ca_ambient_light_range == 10 and
			cur_e_max_entity_lights == 4 and
			cur_e_stencil_shadows_only_from_strongest_light == 0 and
			cur_p_lightrange == 15 and
			cur_r_EnvLightCMSize == 16 and
			cur_r_EnvLCMupdateInterval == 0.05 and
			cur_cl_projectile_light == 1 and
			cur_cl_weapon_light == 2 ) then
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 4 ); -- very high quality
	else
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:AddItem( Localize( "Custom" ) );
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 5 ); -- custom quality
	end
end

UI.PageOptionsVideoAdv.GUI.widget_Lighting.user.UpdateAssignedGlobals = function()
	local curSelectionIndex = UI.PageOptionsVideoAdv.GUI.widget_Lighting:GetSelectionIndex();
	if( curSelectionIndex == 1 ) then
		-- low quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_BumpMapping", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Vegetation_PerpixelLight", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_light_maps_quality", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_ambient_light_intensity", 0.2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_ambient_light_range", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_max_entity_lights", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_stencil_shadows_only_from_strongest_light", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "p_lightrange", 8 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvLightCMSize", 8 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvLCMupdateInterval", 0.1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "cl_projectile_light", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "cl_weapon_light", 0 );
	elseif( curSelectionIndex == 2 ) then
		-- medium quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_BumpMapping", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Vegetation_PerpixelLight", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_light_maps_quality", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_ambient_light_intensity", 0.2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_ambient_light_range", 10 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_max_entity_lights", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_stencil_shadows_only_from_strongest_light", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "p_lightrange", 10 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvLightCMSize", 8 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvLCMupdateInterval", 0.1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "cl_projectile_light", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "cl_weapon_light", 0 );
	elseif( curSelectionIndex == 3 ) then
		-- high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_BumpMapping", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Vegetation_PerpixelLight", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_light_maps_quality", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_ambient_light_intensity", 0.2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_ambient_light_range", 10 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_max_entity_lights", 3 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_stencil_shadows_only_from_strongest_light", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "p_lightrange", 15 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvLightCMSize", 8 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvLCMupdateInterval", 0.1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "cl_projectile_light", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "cl_weapon_light", 1 );
	elseif( curSelectionIndex == 4 ) then
		-- very high quality
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Quality_BumpMapping", 3 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_Vegetation_PerpixelLight", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_light_maps_quality", 2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_ambient_light_intensity", 0.2 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "ca_ambient_light_range", 10 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_max_entity_lights", 4 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "e_stencil_shadows_only_from_strongest_light", 0 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "p_lightrange", 15 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvLightCMSize", 16 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "r_EnvLCMupdateInterval", 0.05 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "cl_projectile_light", 1 );
		UI.PageOptionsVideoAdv.user:SetGlobal( "cl_weapon_light", 2 );
	end
end

UI.PageOptionsVideoAdv.GUI.widget_Lighting.user.SetToSpec = function( spec )
	if( spec == "auto" ) then
		local res = tonumber( UI.PageOptionsVideoAdv.GUI:DetermineMachineSpec( 1, 1, 0, 0 ) );
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( res );
	elseif( spec == "veryhigh" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 4 );
	elseif( spec == "high" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 3 );
	elseif( spec == "medium" ) then
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 2 );
	else
		UI.PageOptionsVideoAdv.GUI.widget_Lighting:SelectIndex( 1 );
	end
end


