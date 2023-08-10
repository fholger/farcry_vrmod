--
-- video options menu page
--
----------------------------------------------------------------------------------------------

UI.PageOptionsVideo =
{
	GUI =
	{
		sep_v =
		{
			skin = UI.skins.MenuBorder,

			left = 540, top = 141,
			width = 220, height = 275,
			bordersides = "l",

			zorder = -50,
		},

		sep_h0 =
		{
			skin = UI.skins.MenuBorder,

			left = 540, top = 261,
			width = 240, height = 123,
			bordersides = "t",

			zorder = -50,
		},

		sep_h1 =
		{
			skin = UI.skins.MenuBorder,

			left = 200, top = 415,
			width = 580, height = 243,
			bordersides = "t",

			zorder = -50,
		},

		-- definition of "Apply" button (applies all changes of video options undertaken by user)
		widget_apply =
		{

			tabstop = 11,

			skin = UI.skins.BottomMenuButton,
			left = 780-180,

			text = Localize( "Apply" ),

			OnCommand = function( sender )
				UI.PageOptionsVideo.GUI:UpdateGlobals();
			end,
		},

		widget_reset =
		{
			skin = UI.skins.BottomMenuButton,
			left = 780-180-178.5,

			tabstop = 12,

			text = Localize("RestoreDefaults"),

			OnCommand = function( sender )
				UI.YesNoBox( Localize( "ResetToDefault" ), Localize( "GenericAreYouSure" ), UI.PageOptionsVideo.ResetToDefaults );
			end,
		},

		-- definition of "Advanced" button (takes user to advanced video menu)
		widget_advanced =
		{
			left = 208, top = 142 + 318 - 34,
			width = 160,
			skin = UI.skins.BottomMenuButton,
			bordersides = "lrtb",

			text = Localize( "AdvancedVidOptions" ),

			tabstop = 13,

			OnCommand = function( sender )
				GotoPage( "VideoAdvOptions" );
			end,
		},

		-- definition of "Renderer" combo box (allows user to change render type)
		widget_renderer_text =
		{
			skin = UI.skins.Label,
			left = 200, top = 164,
			width = 142,

			text = Localize( "Renderer" ),
		},

		widget_renderer =
		{
			skin = UI.skins.ComboBox,
			left = 350, top = 166,

			tabstop = 1,

			vscrollbar =
			{
				skin = UI.skins.VScrollBar,
			},

			-- data and code specific for "Renderer" combo box (separated in user table)
			user =
			{
				-- data
				initialSelectionIndex = 0,

				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
			},
		},

		-- definition of "Resolution" combo box (allows user to change screen resolution)
		widget_resolution_text =
		{
			skin = UI.skins.Label,
			left = 200, top = 206,
			width = 142,

			text = Localize( "Resolution" ),
		},

		widget_resolution =
		{
			skin = UI.skins.ComboBox,
			left = 350, top = 208,

			tabstop = 2,

			vscrollbar =
			{
				skin = UI.skins.VScrollBar,
			},

			-- data and code specific for "Resolution" combo box (separated in user table)
			user =
			{
				-- data
				lScreenResolutionAndBpp = nil,

				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
			},
		},

		-- definition of "Anti Aliasing" combo box (allows user to change FSAA)
		widget_fsaa_text =
		{
			skin = UI.skins.Label,
			left = 200, top = 248,
			width = 142,

			text = Localize( "FSAA" ),
		},

		widget_fsaa =
		{
			skin = UI.skins.ComboBox,
			left = 350, top = 250,

			tabstop = 3,

			vscrollbar =
			{
				skin = UI.skins.VScrollBar,
			},

			-- data and code specific for "Anti Aliasing" combo box (separated in user table)
			user =
			{
				-- data
				initialSelectionIndex = 0,

				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,
			},
		},

		-- definition of "Brightness" combo box (allows user to adjust brightness)
		widget_brightness_text =
		{
			skin = UI.skins.Label,
			left = 200, top = 290,
			width = 142,

			text = Localize( "Brightness" ),
		},

		widget_brightness =
		{
			skin = UI.skins.HScrollBar,

			left = 350, top = 292,
			width = 166, height = 24,

			tabstop = 4,

			OnChanged = function( sender )
				UI.PageOptionsVideo.GUI.widget_brightness.user.OnChanged();
			end,

			-- code specific for "Brightness" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,

				OnChanged = nil,
			},
		},

		-- definition of "Contrast" combo box (allows user to adjust contrast)
		widget_contrast_text =
		{
			skin = UI.skins.Label,
			left = 200, top = 334,
			width = 142,

			text = Localize( "Contrast" ),
		},

		widget_contrast =
		{
			skin = UI.skins.HScrollBar,

			left = 350, top = 336,
			width = 166, height = 24,

			tabstop = 5,

			OnChanged = function( sender )
				UI.PageOptionsVideo.GUI.widget_contrast.user.OnChanged();
			end,

			-- code specific for "Contrast" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,

				OnChanged = nil,
			},
		},

		-- definition of "Gamma Correction" combo box (allows user to adjust gamma correction)
		widget_gammacorrection_text =
		{
			skin = UI.skins.Label,
			left = 200, top = 376,
			width = 142,

			text = Localize( "GammaCorrection" ),
		},

		widget_gammacorrection =
		{
			skin = UI.skins.HScrollBar,

			left = 350, top = 378,
			width = 166, height = 24,

			tabstop = 6,

			OnChanged = function( sender )
				UI.PageOptionsVideo.GUI.widget_gammacorrection.user.OnChanged();
			end,

			-- code specific for "Gamma Correction" combo box (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
				UpdateAssignedGlobals = nil,

				OnChanged = nil,
			},
		},

		-- definition of "render mode" selection
		widget_rendermode_default =
		{
			skin = UI.skins.MenuStatic,

			left = 610, top = 282,
			width = 100, height = 75,

			texture = System:LoadImage( "textures/gui/rendermode_normal" ),
			color = "255 255 255 255",
			texrect = "0 0 128 128",
		},

		widget_rendermode_improved =
		{
			skin = UI.skins.MenuStatic,

			left = 610, top = 282,
			width = 100, height = 75,

			texture = System:LoadImage( "textures/gui/rendermode_normal" ),
			color = "255 255 255 255",
			texrect = "0 0 128 128",
		},

		widget_rendermode_paradise =
		{
			skin = UI.skins.MenuStatic,

			left = 610, top = 282,
			width = 100, height = 75,

			texture = System:LoadImage( "textures/gui/rendermode_paradise" ),
			color = "255 255 255 255",
			texrect = "0 0 128 128",
		},

		widget_rendermode_cold =
		{
			skin = UI.skins.MenuStatic,

			left = 610, top = 282,
			width = 100, height = 75,

			texture = System:LoadImage( "textures/gui/rendermode_cold" ),
			color = "255 255 255 255",
			texrect = "0 0 128 128",
		},

		widget_rendermode_cartoon =
		{
			skin = UI.skins.MenuStatic,

			left = 610, top = 282,
			width = 100, height = 75,

			texture = System:LoadImage( "textures/gui/rendermode_cartoon" ),
			color = "255 255 255 255",
			texrect = "0 0 128 128",
		},

		widget_rendermode =
		{
			skin = UI.skins.MenuStatic,

			left = 610, top = 282,
			width = 100, height = 75,

				-- code specific for "render mode" selection (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
			},
		},

		widget_no_rendermode =
		{
			skin = UI.skins.MenuStatic,

			left = 610, top = 282,
			width = 100, height = 75,
			color = "0 0 0 192",

			halign = UIALIGN_CENTER,
			text = Localize( "RenderModeNotSupported" ),

			fontsize = 12,
			zorder = 10,

			user =
			{
				Initialize = nil,
			},
		},

		widget_rendermode_text =
		{
			skin = UI.skins.Label,
			left = 540, top = 376,
			width = 112,

			text = Localize( "RenderMode" ),
		},

		widget_rendermode_select =
		{
			skin = UI.skins.ComboBox,
			left = 660, top = 378,
			width = 100,

			tabstop = 10,

			vscrollbar =
			{
				skin = UI.skins.VScrollBar,
			},

			OnChanged = function( Sender )
				local modes = { UI.PageOptionsVideo.GUI.widget_rendermode_default,
								UI.PageOptionsVideo.GUI.widget_rendermode_improved,
								UI.PageOptionsVideo.GUI.widget_rendermode_paradise,
								UI.PageOptionsVideo.GUI.widget_rendermode_cold,
								UI.PageOptionsVideo.GUI.widget_rendermode_cartoon };

				local curRenderMode = getglobal( "r_RenderMode" );
				local newRenderMode = UI.PageOptionsVideo.GUI.widget_rendermode_select:GetSelectionIndex() - 1;

				UI:ShowWidget( modes[ newRenderMode + 1 ] );
				UI:HideWidget( modes[ curRenderMode + 1 ] );

				UI:HideWidget( UI.PageOptionsVideo.GUI.widget_no_rendermode );

				if( tonumber( newRenderMode ) ~= 0 ) then
					local gpuQuality = System:GetGPUQuality();
					if( gpuQuality < 1 ) then
						UI:ShowWidget( UI.PageOptionsVideo.GUI.widget_no_rendermode );
						newRenderMode = 0;
					end
				end

				setglobal( "r_RenderMode", newRenderMode );
			end,

			-- code specific for "render mode" selection (separated in user table)
			user =
			{
				-- code (implemented below)
				Initialize = nil,
			},
		},

		-- GUI data members
		relaunchNeeded = 0,

		-- GUI methods
		OnActivate = function( sender )
			for key,val in UI.PageOptionsVideo.GUI do
				if type( val ) == "table" and val.user and val.user.Initialize then
					val.user.Initialize();
				end
			end

			if( not( UI:IsScreenActive( "Options" ) and ( UI:IsScreenActive( "Options" ) ~= 0 ) ) ) then
				UI:ActivateScreen( "Options" );
				UI.PageOptions.GUI.VideoOptions.OnCommand( UI.PageOptions.GUI.VideoOptions );
			end
		end,

		UpdateGlobals = function( self )
			for key,val in UI.PageOptionsVideo.GUI do
				if type( val ) == "table" and val.user and val.user.UpdateAssignedGlobals then
					val.user.UpdateAssignedGlobals();
				end
			end

			if( UI.PageOptionsVideo.GUI.relaunchNeeded ~= 0 ) then
				-- code below no longer needed as relaunch will effectively just reset device when game is running (no real game relaunch)
				--if( ClientStuff ) then
				--	UI.YesNoBox( Localize( "TerminateCurrentGame" ), Localize( "TerminateCurrentGameLabel" ), UI.PageOptionsVideo.Relaunch );
				--else
					UI.PageOptionsVideo.Relaunch();
				--end
			end

			-- to get the page refreshing itself
			--GotoPage("Options");
			--UI.PageOptions.GUI.VideoOptions.OnCommand(UI.PageOptions.GUI.VideoOptions);
		end,
	},

	Relaunch = function( self )
    	System:LogToConsole( "Relaunching..." );
		Game:SendMessage( "Relaunch" );
		UI.PageOptionsVideo.GUI.relaunchNeeded = 0;
	end
}

-- and create screen from table
UI:CreateScreenFromTable( "VideoOptions", UI.PageOptionsVideo.GUI );

-- code for specific behaviour of individual widgets
UI.PageOptionsVideo.GUI.widget_renderer.user.Initialize = function( self )
	-- initalize widget
	UI.PageOptionsVideo.GUI.widget_renderer:Clear();
	UI.PageOptionsVideo.GUI.widget_renderer:AddItem( Localize( "Direct3D9" ) );
	UI.PageOptionsVideo.GUI.widget_renderer:AddItem( Localize( "OpenGL" ) );

	-- let widget reflect state of globals
	local curRenderer = strlower( getglobal( "r_Driver" ) );
	if( curRenderer == "direct3d9" ) then
		UI.PageOptionsVideo.GUI.widget_renderer:SelectIndex( 1 );
	elseif( curRenderer == "opengl" ) then
		UI.PageOptionsVideo.GUI.widget_renderer:SelectIndex( 2 );
	end;

	-- save initial selection state
	UI.PageOptionsVideo.GUI.widget_renderer.user.initialSelectionIndex =
		UI.PageOptionsVideo.GUI.widget_renderer:GetSelectionIndex();

	UI:DisableWidget( UI.PageOptionsVideo.GUI.widget_renderer );
end

UI.PageOptionsVideo.GUI.widget_renderer.user.DefInitialize = function( self )
	UI.PageOptionsVideo.GUI.widget_renderer:SelectIndex( 1 );
end

UI.PageOptionsVideo.GUI.widget_renderer.user.UpdateAssignedGlobals = function( self )
	local curSelectionIndex = UI.PageOptionsVideo.GUI.widget_renderer:GetSelectionIndex();

	-- has selection changed
	if( curSelectionIndex ~= UI.PageOptionsVideo.GUI.widget_renderer.user.initialSelectionIndex ) then
		if( curSelectionIndex == 1 ) then
			setglobal( "r_Driver", "Direct3D9" );
		elseif( curSelectionIndex == 2 ) then
			setglobal( "r_Driver", "OpenGL" );
		end
		System:LogToConsole( "Renderer changed, relaunch necessary..." );
		UI.PageOptionsVideo.GUI.relaunchNeeded = 1;
		UI.PageOptionsVideo.GUI.widget_renderer.user.initialSelectionIndex = curSelectionIndex;
	end
end



UI.PageOptionsVideo.GUI.widget_resolution.user.Initialize = function( self )
	-- initalize widget
	UI.PageOptionsVideo.GUI.widget_resolution:Clear();

	UI.PageOptionsVideo.GUI.widget_resolution.user.ScreenResolutionAndBpp = {};
	local lTmpScreenResolutionAndBpp = System:EnumDisplayFormats();

	local ref = UI.PageOptionsVideo.GUI.widget_resolution.user.ScreenResolutionAndBpp;
	local j = 1;
	for i, DispFmt in lTmpScreenResolutionAndBpp do
		if( DispFmt.bpp == 32 and DispFmt.width > 640 and DispFmt.height > 480 ) then -- filter modes, 32 bit and higher than 640x480 only!
			ref[ j ] = DispFmt;
			j = j + 1;
		end
	end

	for i, DispFmt in ref do
		UI.PageOptionsVideo.GUI.widget_resolution:AddItem( DispFmt.width.."x"..DispFmt.height.."x"..DispFmt.bpp );
	end

	-- let widget reflect state of globals
	local bpp = tonumber( getglobal( "r_ColorBits" ) );
	local sCurrentRes = tonumber( getglobal( "vr_window_width" ) ).."x"..tonumber( getglobal( "vr_window_height" ) ).."x"..bpp;
	UI.PageOptionsVideo.GUI.widget_resolution:Select( sCurrentRes );
end

UI.PageOptionsVideo.GUI.widget_resolution.user.DefInitialize = function( self )
	UI.PageOptionsVideo.GUI.widget_resolution:Select( "1024x768x32" );
end



UI.PageOptionsVideo.GUI.widget_resolution.user.UpdateAssignedGlobals = function( self )
	local index = UI.PageOptionsVideo.GUI.widget_resolution:GetSelectionIndex();
	local newRes = UI.PageOptionsVideo.GUI.widget_resolution.user.ScreenResolutionAndBpp[ index ];

	if( tostring( vr_window_width ) ~= tostring( newRes.width ) or
		tostring( vr_window_height )~= tostring( newRes.height ) or
		tostring( r_ColorBits ) ~= tostring( newRes.bpp ) ) then

		--System:LogToConsole( "Resolution changed, relaunch necessary..." );
		--UI.PageOptionsVideo.GUI.relaunchNeeded = 1;

		setglobal( "vr_window_width", newRes.width );
		setglobal( "vr_window_height", newRes.height );
		setglobal( "r_ColorBits", newRes.bpp );

		g_reload_ui = "cmd_goto_video_options";
		UI:Reload( 1 );
	end
end



UI.PageOptionsVideo.GUI.widget_fsaa.user.Initialize = function( self )
	-- initalize widget
	UI.PageOptionsVideo.GUI.widget_fsaa:Clear();
	
	FSAAModes = System:EnumAAFormats();
	
	UI.PageOptionsVideo.GUI.widget_fsaa:AddItem(Localize("None"));
	
	UI.PageOptionsVideo.GUI.widget_fsaa.user.FSAAModes = {};
	
	for n, mode in FSAAModes do
		local i = UI.PageOptionsVideo.GUI.widget_fsaa:AddItem(mode.desc);
		
		UI.PageOptionsVideo.GUI.widget_fsaa.user.FSAAModes[i] = mode;
	end
	
	-- let widget reflect state of globals
	local fsaa = tonumber(getglobal("r_FSAA" ));
	local fsaaSamples = tonumber(getglobal("r_FSAA_samples"));
	local fsaaQuality = tonumber(getglobal("r_FSAA_quality"));
	if(fsaa ~= 0) then	
		-- find the correct match
		for n, mode in UI.PageOptionsVideo.GUI.widget_fsaa.user.FSAAModes do
			if ((fsaaSamples == tonumber(mode.samples)) and (fsaaQuality == tonumber(mode.quality))) then
				UI.PageOptionsVideo.GUI.widget_fsaa:SelectIndex(n);
				break;
			end			
		end
	else
		UI.PageOptionsVideo.GUI.widget_fsaa:SelectIndex(1);
	end;

	-- save initial selection state
	UI.PageOptionsVideo.GUI.widget_fsaa.user.initialSelectionIndex =
		UI.PageOptionsVideo.GUI.widget_fsaa:GetSelectionIndex();

	-- disable widget when game is running as FSAA can't be adjusted right now
	if( ClientStuff ) then
		UI:DisableWidget( UI.PageOptionsVideo.GUI.widget_fsaa );
	else
		UI:EnableWidget( UI.PageOptionsVideo.GUI.widget_fsaa );
	end
end

UI.PageOptionsVideo.GUI.widget_fsaa.user.DefInitialize = function( self )
	if( UI:IsWidgetEnabled( UI.PageOptionsVideo.GUI.widget_fsaa ) ) then
		UI.PageOptionsVideo.GUI.widget_fsaa:SelectIndex( 1 );
	end;
end

UI.PageOptionsVideo.GUI.widget_fsaa.user.UpdateAssignedGlobals = function( self )
	local curSelectionIndex = UI.PageOptionsVideo.GUI.widget_fsaa:GetSelectionIndex();

	-- has selection changed
	if( curSelectionIndex ~= UI.PageOptionsVideo.GUI.widget_fsaa.user.initialSelectionIndex ) then
		if( curSelectionIndex == 1 ) then
			setglobal( "r_FSAA", 0 );			-- no fsaa
			setglobal( "r_FSAA_samples", 1 );
			setglobal( "r_FSAA_quality", 0 );
		else
			local mode = UI.PageOptionsVideo.GUI.widget_fsaa.user.FSAAModes[curSelectionIndex];
			setglobal( "r_FSAA", 1 );			-- no fsaa
			setglobal( "r_FSAA_samples", mode.samples );
			setglobal( "r_FSAA_quality", mode.quality );
		end
		--System:LogToConsole( "FSAA mode and number of FSAA samples changed, relaunch necessary..." );
		--UI.PageOptionsVideo.GUI.relaunchNeeded = 1;
		UI.PageOptionsVideo.GUI.widget_fsaa.user.initialSelectionIndex = curSelectionIndex;
	end
end



UI.PageOptionsVideo.GUI.widget_brightness.user.Initialize = function( self )
	local brightness = tonumber( getglobal( "r_Brightness" ) );
	UI.PageOptionsVideo.GUI.widget_brightness:SetValue( brightness );
end

UI.PageOptionsVideo.GUI.widget_brightness.user.DefInitialize = function( self )
	UI.PageOptionsVideo.GUI.widget_brightness:SetValue( 0.5 );
end

UI.PageOptionsVideo.GUI.widget_brightness.user.UpdateAssignedGlobals = function( self )
end

UI.PageOptionsVideo.GUI.widget_brightness.user.OnChanged = function( self )
	-- get normalize brightness [0 .. 1] from slider widget
	local brightness = tonumber( UI.PageOptionsVideo.GUI.widget_brightness:GetValue() );
	if( brightness < 0.0 ) then
		brightness = 0.0;
	elseif( brightness > 1.0 ) then
		brightness = 1.0;
	end;
	-- set brightness
	setglobal( "r_Brightness", brightness );
end;



UI.PageOptionsVideo.GUI.widget_contrast.user.Initialize = function( self )
	local contrast = tonumber( getglobal( "r_Contrast" ) );
	UI.PageOptionsVideo.GUI.widget_contrast:SetValue( contrast );
end

UI.PageOptionsVideo.GUI.widget_contrast.user.DefInitialize = function( self )
	UI.PageOptionsVideo.GUI.widget_contrast:SetValue( 0.5 );
end

UI.PageOptionsVideo.GUI.widget_contrast.user.UpdateAssignedGlobals = function( self )
end

UI.PageOptionsVideo.GUI.widget_contrast.user.OnChanged = function( self )
	-- get normalize contrast [0 .. 1] from slider widget
	local contrast = tonumber( UI.PageOptionsVideo.GUI.widget_contrast:GetValue() );
	if( contrast < 0.0 ) then
		contrast = 0.0;
	elseif( contrast > 1.0 ) then
		contrast = 1.0;
	end;
	-- set contrast
	setglobal( "r_Contrast", contrast );
end;



UI.PageOptionsVideo.GUI.widget_gammacorrection.user.Initialize = function( self )
	-- get gamma and map it from [0.5 .. 3.0] into [0 .. 1] for slider widget
	local gamma = tonumber( getglobal( "r_Gamma" ) );
	gamma = ( gamma - 0.5 ) / 2.5;
	-- set normalized gamma
	UI.PageOptionsVideo.GUI.widget_gammacorrection:SetValue( gamma );
end

UI.PageOptionsVideo.GUI.widget_gammacorrection.user.DefInitialize = function( self )
	UI.PageOptionsVideo.GUI.widget_gammacorrection:SetValue( 0.2 );
end

UI.PageOptionsVideo.GUI.widget_gammacorrection.user.UpdateAssignedGlobals = function( self )
end

UI.PageOptionsVideo.GUI.widget_gammacorrection.user.OnChanged = function( self )
	-- get normalize gamma [0 .. 1] from slider widget
	local gamma = tonumber( UI.PageOptionsVideo.GUI.widget_gammacorrection:GetValue() );
	if( gamma < 0.0 ) then
		gamma = 0.0;
	elseif( gamma > 1.0 ) then
		gamma = 1.0;
	end;
	-- map it back into [0.5 .. 3.0] and set global variable
	gamma = gamma * 2.5 + 0.5;
	setglobal( "r_Gamma", gamma );
end;



UI.PageOptionsVideo.GUI.widget_rendermode.user.Initialize = function( self )
	UI:HideWidget( UI.PageOptionsVideo.GUI.widget_rendermode );
	UI:HideWidget( UI.PageOptionsVideo.GUI.widget_rendermode_default );
	UI:HideWidget( UI.PageOptionsVideo.GUI.widget_rendermode_improved );
	UI:HideWidget( UI.PageOptionsVideo.GUI.widget_rendermode_paradise );
	UI:HideWidget( UI.PageOptionsVideo.GUI.widget_rendermode_cold );
	UI:HideWidget( UI.PageOptionsVideo.GUI.widget_rendermode_cartoon );

	local modes = { UI.PageOptionsVideo.GUI.widget_rendermode_default,
					UI.PageOptionsVideo.GUI.widget_rendermode_improved,
					UI.PageOptionsVideo.GUI.widget_rendermode_paradise,
					UI.PageOptionsVideo.GUI.widget_rendermode_cold,
					UI.PageOptionsVideo.GUI.widget_rendermode_cartoon };

	local renderMode = tonumber( getglobal( "r_RenderMode" ) );
	UI:ShowWidget( modes[ renderMode + 1 ] );
end



UI.PageOptionsVideo.GUI.widget_rendermode_select.user.Initialize = function( self )
	UI.PageOptionsVideo.GUI.widget_rendermode_select:Clear();

	UI.PageOptionsVideo.GUI.widget_rendermode_select:AddItem( Localize( "Default" ) );
	UI.PageOptionsVideo.GUI.widget_rendermode_select:AddItem( Localize( "Improved" ) );
	UI.PageOptionsVideo.GUI.widget_rendermode_select:AddItem( Localize( "Paradise" ) );
	UI.PageOptionsVideo.GUI.widget_rendermode_select:AddItem( Localize( "Cold" ) );
	UI.PageOptionsVideo.GUI.widget_rendermode_select:AddItem( Localize( "Cartoon" ) );

	local renderMode = tonumber( getglobal( "r_RenderMode" ) );
	UI.PageOptionsVideo.GUI.widget_rendermode_select:SelectIndex( renderMode + 1 );

	local enableWidget = tonumber( getglobal( "r_Glare" ) );
	if( enableWidget == 0 ) then
		UI:DisableWidget( UI.PageOptionsVideo.GUI.widget_rendermode_select );
	else
		UI:EnableWidget( UI.PageOptionsVideo.GUI.widget_rendermode_select );
	end

	if( renderMode ~= 0 ) then
		local gpuQuality = System:GetGPUQuality();
		if( gpuQuality < 1 ) then
			UI:ShowWidget( UI.PageOptionsVideo.GUI.widget_no_rendermode );
		else
			UI:HideWidget( UI.PageOptionsVideo.GUI.widget_no_rendermode );
		end
	else
		UI:HideWidget( UI.PageOptionsVideo.GUI.widget_no_rendermode );
	end
end

UI.PageOptionsVideo.GUI.widget_rendermode_select.user.DefInitialize = function( self )
	UI.PageOptionsVideo.GUI.widget_rendermode_select:SelectIndex( 1 );
end



function UI.PageOptionsVideo.ResetToDefaults()
	for key,val in UI.PageOptionsVideo.GUI do
		if type( val ) == "table" and val.user and val.user.Initialize then
			val.user.Initialize();
			if( val.user.DefInitialize ) then
				val.user.DefInitialize();
			end
		end
	end
	UI.PageOptionsVideo.GUI.widget_brightness.user.OnChanged();
	UI.PageOptionsVideo.GUI.widget_contrast.user.OnChanged();
	UI.PageOptionsVideo.GUI.widget_gammacorrection.user.OnChanged();
end