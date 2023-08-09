--
-- player options menu page
--

UI.PageOptionsVR=
{
	GUI=
	{
		reset=
		{
			skin = UI.skins.BottomMenuButton,
			left = 780-180,

			tabstop = 8,

			text=Localize("RestoreDefaults"),

			OnCommand=function(Sender)
				UI.YesNoBox(Localize("ResetToDefault"), Localize("GenericAreYouSure"), UI.PageOptionsVR.ResetToDefaults);
			end,
		},

		separator=
		{
			skin = UI.skins.MenuBorder,
			left = 490, top = 141,
			width = 2, height = 317,
			color = "0 0 0 0",
			bordersides = "l",
		},

		modelview=
		{
			skin = UI.skins.MenuStatic,
			left = 536, top = 254,
			width = 200, height = 203,
			color = "0 0 0 0",
			bordersides = "",
		},


		playernametext=
		{
			skin = UI.skins.Label,

			left = 488, top = 149,
			width = 112,

			text=Localize("MultiplayerName"),
		},

		playername=
		{
			skin =	 UI.skins.EditBox,
			left = 608, top = 149,
			width = 162,

			tabstop = 1,
			maxlength = 60,
			namesafe = 1,
			disallow = "\"'",
		},

		pmodeltext=
		{
			skin = UI.skins.Label,

			left = 488, top = 184,
			width = 112,

			text=Localize("MultiplayerModel"),
		},

		pmodel=
		{
			skin = UI.skins.ComboBox,

			left = 608, top = 184,
			width = 162,

			tabstop = 2,

			vscrollbar =
			{
				skin = UI.skins.VScrollBar,
			},

			OnChanged=function(Sender)
				UI.PageOptionsVR.Update3dModel();
			end,
		},

		pcolortext=
		{
			skin = UI.skins.Label,

			left = 488, top = 219,
			width = 112,

			text=Localize("MultiplayerColor"),
		},

		pcolor=
		{
			skin = UI.skins.ComboBox,

			left = 608, top = 219,
			width = 162,

			tabstop = 3,

			vscrollbar =
			{
				skin = UI.skins.VScrollBar,
			},

			OnChanged=function(Sender)
				UI.PageOptionsVR.Update3dModel();
				if (Sender:GetSelectionIndex()) then
					setglobal("p_color", Sender:GetSelectionIndex()-1);
				else
					setglobal("p_color", 0);
				end
			end,
		},

		goretext=
		{
			skin = UI.skins.Label,

			left = 200, top = 149,
			width = 112,

			text=Localize("EnableGore"),
		},

		gore=
		{
			left = 320, top = 149,
			width = 28, height = 28,

			skin = UI.skins.CheckBox,

			tabstop = 4,

			OnChanged=function(Sender)
				if (Sender:GetChecked()) then
					setglobal("g_gore", 2);
				else
					setglobal("g_gore", 0);
				end
			end,
		},

		lazyweapontext =
		{
			skin = UI.skins.Label,
			left = 200, top = 184,
			width = 112,

			text = Localize( "LazyWeapon" ),
		},

		lazyweapon =
		{
			skin = UI.skins.HScrollBar,

			left = 320, top = 184,
			width = 162, height = 24,

			tabstop = 5,

			OnChanged = function( sender )
				local newValue = tonumber( UI.PageOptionsVR.GUI.lazyweapon:GetValue() );
				if( newValue < 0.0 ) then
					newValue = 0.0;
				elseif( newValue > 1.0 ) then
					newValue = 1.0;
				end;
				setglobal( "cl_lazy_weapon", newValue );
			end,
		},

		deathtimetext =
		{
			skin = UI.skins.Label,
			left = 200, top = 219,
			width = 112,

			text = Localize( "DeathTime" ),
		},

		deathtime =
		{
			skin = UI.skins.EditBox,
			left = 320, top = 219,
			width = 162,

			tabstop = 6,
			
			disallow = ".",

			maxlength = 3,
			numeric = 1,
			-- disallow = ".",
		},

		sysspec_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 254,
			width = 112,

			text=Localize("SysSpec"),
		},

		sysspec=
		{
			left = 320, top = 254,
			width = 162, height = 28,

			skin = UI.skins.ComboBox,

			tabstop = 7,

			OnChanged = function( Sender )
				local newSysSpec = tonumber( UI.PageOptionsVR.GUI.sysspec:GetSelectionIndex() ) - 1;
				setglobal( "sys_spec", newSysSpec );
				ApplySysSpecSettings();
			end,
		},

		OnActivate= function(Sender)
			local playername = getglobal("p_name");

			if (playername and strlen(playername) > 0) then
				UI.PageOptionsVR.GUI.playername:SetText(playername);
			else
				setglobal("p_name", "unnamed");
			end
--			UI.PageOptionsVR.GUI.lefthanded:SetChecked(g_LeftHanded);
			UI.PageOptionsVR.GUI.gore:SetChecked(g_gore);

			UI.PageOptionsVR.GUI.sysspec:Clear();
			UI.PageOptionsVR.GUI.sysspec:AddItem( Localize( "Low" ) );
			UI.PageOptionsVR.GUI.sysspec:AddItem( Localize( "Medium" ) );
			UI.PageOptionsVR.GUI.sysspec:AddItem( Localize( "High" ) );
			UI.PageOptionsVR.GUI.sysspec:AddItem( Localize( "VeryHigh" ) );

			local cur_sysspec = tonumber( getglobal( "sys_spec" ) );
			UI.PageOptionsVR.GUI.sysspec:SelectIndex( cur_sysspec + 1 );

			if (ClientStuff and Game:IsMultiplayer()) then
				UI:DisableWidget("pmodel", "GameOptions");
				UI:DisableWidget("pcolor", "GameOptions");
			else
				UI:EnableWidget("pmodel", "GameOptions");
				UI:EnableWidget("pcolor", "GameOptions");
			end

			UI.PageOptionsVR.GUI.pmodel:Clear();
			UI.PageOptionsVR.GUI.pcolor:Clear();

			for i, Color in MultiplayerUtils.ModelColor do
				local szColor = min(255, floor(Color[1]*255)).." "..min(255, floor(Color[2]*255)).." "..min(255, floor(Color[3]*255)).." 255";

				UI.PageOptionsVR.GUI.pcolor:AddItem("", nil, nil, szColor);
			end

			local iColorIndex=floor(tonumber(getglobal("p_color")));
			if(iColorIndex>=0 and iColorIndex<=9)then
				UI.PageOptionsVR.GUI.pcolor:SelectIndex(iColorIndex+1);
			end

			local iSelection = 1;

			UI.PageOptionsVR.IDToModel = {};
			for i, Model in MPModelList do
				if (Model.name and strlen(Model.name) > 0) then
					local iIndex = UI.PageOptionsVR.GUI.pmodel:AddItem(Model.name);
					UI.PageOptionsVR.IDToModel[iIndex] = Model.model;

					if (strlower(Model.model) == strlower(getglobal("mp_model"))) then
						iSelection = iIndex;
					end
				end
			end

			UI.PageOptionsVR.GUI.pmodel:SelectIndex(iSelection);
			UI.PageOptionsVR.Update3dModel();


			-----------------------------------------------------------------

			UI.PageOptionsVR.GUI.lazyweapon:SetValue( getglobal( "cl_lazy_weapon" ) );

			-----------------------------------------------------------------

			local strDeathTime = floor(getglobal( "p_deathtime" ));
			if( strDeathTime and strlen( strDeathTime ) > 0 ) then
				UI.PageOptionsVR.GUI.deathtime:SetText( strDeathTime );
			else
				UI.PageOptionsVR.GUI.deathtime:SetText("30");
			end
		end,

		OnDeactivate = function(Sender)
			setglobal("p_deathtime", UI.PageOptionsVR.GUI.deathtime:GetText());
			setglobal("p_name", UI.PageOptionsVR.GUI.playername:GetText());
			if (Client) then
				Client:SetName(UI.PageOptionsVR.GUI.playername:GetText());
			end
		end
	},

	------------------------------------------------------------------------
	Update3dModel = function()

		local iSelection = UI.PageOptionsVR.GUI.pmodel:GetSelectionIndex();

		if (not iSelection) then
			return;
		end

		local szName = UI.PageOptionsVR.IDToModel[iSelection];

		if (szName and strlen(szName) > 0) then
			local ModelView = UI.PageOptionsVR.GUI.modelview;
			local ColorCombo = UI.PageOptionsVR.GUI.pcolor;

			local bResult = ModelView:LoadModel(szName)

			if (bResult and tonumber(bResult) ~= 0) then
				ModelView:SetAnimation("swalkfwd");
				ModelView:SetView(3.5);
				ModelView:SetSecondShader("PlayerMaskModulate");

				setglobal("mp_model", szName);

				local Color = {0,0,0};

				if (ColorCombo:GetSelectionIndex()) then
					local iColor = ColorCombo:GetSelectionIndex();

					if (MultiplayerUtils.ModelColor[iColor]) then
						Color = MultiplayerUtils.ModelColor[iColor];
					end
				end

				ModelView:SetShaderFloat("ColorR", Color[1]);
				ModelView:SetShaderFloat("ColorG", Color[2]);
				ModelView:SetShaderFloat("ColorB", Color[3]);
			end
		end
	end,
	

	------------------------------------------------------------------------
	ResetToDefaults=function()
		UI.PageOptionsVR.GUI.playername:SetText("Jack Carver");
		
		if not (ClientStuff and Game:IsMultiplayer()) then
			UI.PageOptionsVR.GUI.pmodel:SelectIndex(1);
			UI.PageOptionsVR.GUI.pcolor:SelectIndex(5);
		end
		
		UI.PageOptionsVR.GUI.gore:SetChecked(1);
		UI.PageOptionsVR.GUI.lazyweapon:SetValue(0);
		UI.PageOptionsVR.GUI.deathtime:SetText( "30" );
		local cpuQuality = tonumber( System:GetCPUQuality() );
		UI.PageOptionsVR.GUI.sysspec:SelectIndex( cpuQuality + 1 );
		--UI.PageOptionsVR.GUI.mods:SelectIndex(1);
		UI.PageOptionsVR.GUI.pmodel:OnChanged();
		UI.PageOptionsVR.GUI.pcolor:OnChanged();
		UI.PageOptionsVR.GUI.gore:OnChanged();
		UI.PageOptionsVR.GUI.lazyweapon:OnChanged();
		UI.PageOptionsVR.GUI.sysspec:OnChanged();
			--UI.PageOptionsVR.GUI.mods:OnChanged(UI.PageOptionsVR.GUI.mods);
	end,
}

UI:CreateScreenFromTable("VROptions",UI.PageOptionsVR.GUI);