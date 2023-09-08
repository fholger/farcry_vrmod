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

		restart_text=
		{
			skin = UI.skins.Label,

			left = 200,
			top = 464,
			width = 250,

			text="* Changes may require restart to apply",
		},

		separator=
		{
			skin = UI.skins.MenuBorder,
			left = 490, top = 141,
			width = 2, height = 317,
			color = "0 0 0 0",
			bordersides = "l",
		},

		seatedmode_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 149,
			width = 112,

			text="Seated mode",
		},

		seatedmode=
		{
			left = 320, top = 149,
			width = 28, height = 28,

			skin = UI.skins.CheckBox,

			tabstop = 4,

			OnChanged=function(Sender)
				if (Sender:GetChecked()) then
					setglobal("vr_seated_mode", 1);
				else
					setglobal("vr_seated_mode", 0);
				end
			end,
		},

		mainhand_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 184,
			width = 112,

			text="Dominant hand *",
		},

		mainhand=
		{
			left = 320, top = 184,
			width = 162, height = 28,

			skin = UI.skins.ComboBox,

			tabstop = 7,

			OnChanged = function( Sender )
				local lefthanded = tonumber( UI.PageOptionsVR.GUI.mainhand:GetSelectionIndex() ) - 1;
				setglobal( "g_LeftHanded", lefthanded );
			end,
		},

		movedir_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 219,
			width = 112,

			text="Movement dir",
		},

		movedir=
		{
			left = 320, top = 219,
			width = 162, height = 28,

			skin = UI.skins.ComboBox,

			tabstop = 7,

			OnChanged = function( Sender )
				local new_movedir = tonumber( UI.PageOptionsVR.GUI.movedir:GetSelectionIndex() ) - 2;
				setglobal( "vr_movement_dir", new_movedir );
			end,
		},

		turnmode_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 254,
			width = 112,

			text="Turn mode",
		},

		turnmode=
		{
			left = 320, top = 254,
			width = 162, height = 28,

			skin = UI.skins.ComboBox,

			tabstop = 7,

			OnChanged = function( Sender )
				local newSnapTurn = 15 * (tonumber( UI.PageOptionsVR.GUI.turnmode:GetSelectionIndex() ) - 1);
				setglobal( "vr_snap_turn_amount", newSnapTurn );
			end,
		},

		turnspeed_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 289,
			width = 112,

			text="Turn speed",
		},

		turnspeed =
		{
			skin = UI.skins.HScrollBar,

			left = 320, top = 289,
			width = 162, height = 24,

			tabstop = 5,

			OnChanged = function( sender )
				local newValue = tonumber( UI.PageOptionsVR.GUI.turnspeed:GetValue() );
				if( newValue < 0.0 ) then
					newValue = 0.0;
				elseif( newValue > 1.0 ) then
					newValue = 1.0;
				end;
				-- map to value range [0.5, 3.0]
				newValue = 0.5 + newValue * 2.5;
				setglobal( "vr_smooth_turn_speed", newValue );
			end,
		},

		weaponangle_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 324,
			width = 112,

			text="Weapon angle",
		},

		weaponangle =
		{
			skin = UI.skins.HScrollBar,

			left = 320, top = 324,
			width = 162, height = 24,

			tabstop = 5,

			OnChanged = function( sender )
				local newValue = tonumber( UI.PageOptionsVR.GUI.weaponangle:GetValue() );
				if( newValue < 0.0 ) then
					newValue = 0.0;
				elseif( newValue > 1.0 ) then
					newValue = 1.0;
				end;
				-- map to value range [-90, 90]
				newValue = (newValue - 0.5) * 180;
				setglobal( "vr_weapon_pitch_offset", newValue );
			end,
		},

		ladders_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 359,
			width = 112,

			text="Immersive ladders",
		},

		ladders=
		{
			left = 320, top = 359,
			width = 28, height = 28,

			skin = UI.skins.CheckBox,

			tabstop = 4,

			OnChanged=function(Sender)
				if (Sender:GetChecked()) then
					setglobal("vr_immersive_ladders", 1);
				else
					setglobal("vr_immersive_ladders", 0);
				end
			end,
		},

		terrainlod_text=
		{
			skin = UI.skins.Label,

			left = 488, top = 149,
			width = 112,

			text="Max terrain LOD",
		},

		terrainlod=
		{
			left = 608, top = 149,
			width = 28, height = 28,

			skin = UI.skins.CheckBox,

			tabstop = 4,

			OnChanged=function(Sender)
				if (Sender:GetChecked()) then
					setglobal("vr_render_force_max_terrain_detail", 1);
				else
					setglobal("vr_render_force_max_terrain_detail", 0);
				end
			end,
		},

		objdist_text=
		{
			skin = UI.skins.Label,

			left = 488, top = 184,
			width = 112,

			text="Render far objs *",
		},

		objdist=
		{
			left = 608, top = 184,
			width = 28, height = 28,

			skin = UI.skins.CheckBox,

			tabstop = 4,

			OnChanged=function(Sender)
				if (Sender:GetChecked()) then
					setglobal("vr_render_force_obj_draw_dist", 1);
				else
					setglobal("vr_render_force_obj_draw_dist", 0);
				end
			end,
		},

		vegetationdist_text=
		{
			skin = UI.skins.Label,

			left = 488, top = 219,
			width = 112,

			text="Vegetation render dist",
		},

		vegetationdist =
		{
			skin = UI.skins.HScrollBar,

			left = 608, top = 219,
			width = 162, height = 24,

			tabstop = 5,

			OnChanged = function( sender )
				local newValue = tonumber( UI.PageOptionsVR.GUI.vegetationdist:GetValue() );
				if( newValue < 0.0 ) then
					newValue = 0.0;
				elseif( newValue > 1.0 ) then
					newValue = 1.0;
				end;
				-- map to value range [0, 100]
				newValue = newValue * 100;
				setglobal( "e_vegetation_sprites_distance_ratio", newValue );
			end,
		},

		mirroreye_text=
		{
			skin = UI.skins.Label,

			left = 488, top = 254,
			width = 112,

			text="Mirror eye",
		},

		mirroreye=
		{
			left = 608, top = 254,
			width = 162, height = 28,

			skin = UI.skins.ComboBox,

			tabstop = 7,

			OnChanged = function( Sender )
				local eye = tonumber( UI.PageOptionsVR.GUI.mirroreye:GetSelectionIndex() ) - 1;
				setglobal( "vr_mirrored_eye", eye );
			end,
		},

		crosshair_text=
		{
			skin = UI.skins.Label,

			left = 488, top = 289,
			width = 112,

			text="Crosshair",
		},

		crosshair=
		{
			left = 608, top = 289,
			width = 162, height = 28,

			skin = UI.skins.ComboBox,

			tabstop = 7,

			OnChanged = function( Sender )
				local eye = tonumber( UI.PageOptionsVR.GUI.crosshair:GetSelectionIndex() ) - 1;
				setglobal( "vr_crosshair", eye );
			end,
		},

		vrscopes_text=
		{
			skin = UI.skins.Label,

			left = 488, top = 324,
			width = 112,

			text="Scopes in VR",
		},

		vrscopes_warning=
		{
			skin = UI.skins.Label,

			left = 660, top = 324,
			width = 100,

			text="high CPU perf. cost",
		},

		vrscopes=
		{
			left = 608, top = 324,
			width = 28, height = 28,

			skin = UI.skins.CheckBox,

			tabstop = 4,

			OnChanged=function(Sender)
				if (Sender:GetChecked()) then
					setglobal("vr_render_world_while_zoomed", 1);
				else
					setglobal("vr_render_world_while_zoomed", 0);
				end
			end,
		},

		OnActivate= function(Sender)
			UI.PageOptionsVR.GUI.seatedmode:SetChecked(vr_seated_mode);
			UI.PageOptionsVR.GUI.terrainlod:SetChecked(vr_render_force_max_terrain_detail);
			UI.PageOptionsVR.GUI.objdist:SetChecked(vr_render_force_obj_draw_dist);
			UI.PageOptionsVR.GUI.ladders:SetChecked(vr_immersive_ladders);

			UI.PageOptionsVR.GUI.mainhand:Clear();
			UI.PageOptionsVR.GUI.mainhand:AddItem( "Right" );
			UI.PageOptionsVR.GUI.mainhand:AddItem( "Left" );

			UI.PageOptionsVR.GUI.movedir:Clear();
			UI.PageOptionsVR.GUI.movedir:AddItem( "Head" );
			UI.PageOptionsVR.GUI.movedir:AddItem( "Left" );
			UI.PageOptionsVR.GUI.movedir:AddItem( "Right" );

			UI.PageOptionsVR.GUI.turnmode:Clear();
			UI.PageOptionsVR.GUI.turnmode:AddItem( "Smooth" );
			UI.PageOptionsVR.GUI.turnmode:AddItem( "Snap 15" );
			UI.PageOptionsVR.GUI.turnmode:AddItem( "Snap 30" );
			UI.PageOptionsVR.GUI.turnmode:AddItem( "Snap 45" );
			UI.PageOptionsVR.GUI.turnmode:AddItem( "Snap 60" );
			UI.PageOptionsVR.GUI.turnmode:AddItem( "Snap 75" );
			UI.PageOptionsVR.GUI.turnmode:AddItem( "Snap 90" );

			local cur_mainhand = tonumber( getglobal( "g_LeftHanded" ) );
			UI.PageOptionsVR.GUI.mainhand:SelectIndex( cur_mainhand + 1 );
			local cur_movedir = tonumber( getglobal( "vr_movement_dir" ) );
			UI.PageOptionsVR.GUI.movedir:SelectIndex( cur_movedir + 2 );
			local cur_turnmode = tonumber( getglobal( "vr_snap_turn_amount" ) ) / 15;
			UI.PageOptionsVR.GUI.turnmode:SelectIndex( cur_turnmode + 1 );

			UI.PageOptionsVR.GUI.turnspeed:SetValue( ( getglobal( "vr_smooth_turn_speed" ) - 0.5) / 2.5 );
			UI.PageOptionsVR.GUI.vegetationdist:SetValue( getglobal( "e_vegetation_sprites_distance_ratio" ) / 100.0 );
			UI.PageOptionsVR.GUI.weaponangle:SetValue( getglobal( "vr_weapon_pitch_offset" ) / 90 + 0.5 );

			UI.PageOptionsVR.GUI.mirroreye:Clear();
			UI.PageOptionsVR.GUI.mirroreye:AddItem( "Left" );
			UI.PageOptionsVR.GUI.mirroreye:AddItem( "Right" );

			UI.PageOptionsVR.GUI.crosshair:Clear();
			UI.PageOptionsVR.GUI.crosshair:AddItem( "None" );
			UI.PageOptionsVR.GUI.crosshair:AddItem( "Dot" );
			UI.PageOptionsVR.GUI.crosshair:AddItem( "Laser" );
			
			local cur_eye = tonumber( getglobal( "vr_mirrored_eye" ) );
			UI.PageOptionsVR.GUI.mirroreye:SelectIndex( cur_eye + 1 );
			local cur_crosshair = tonumber( getglobal( "vr_crosshair" ) );
			UI.PageOptionsVR.GUI.crosshair:SelectIndex( cur_crosshair + 1 );

			UI.PageOptionsVR.GUI.vrscopes:SetChecked(vr_render_world_while_zoomed);
		end,

		OnDeactivate = function(Sender)
		end
	},

	------------------------------------------------------------------------
	ResetToDefaults=function()
		UI.PageOptionsVR.GUI.seatedmode:SetChecked(0);
		UI.PageOptionsVR.GUI.movedir:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.mainhand:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.turnmode:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.turnspeed:SetValue( 0.5 );
		UI.PageOptionsVR.GUI.weaponangle:SetValue( 0.667 );
		UI.PageOptionsVR.GUI.ladders:SetChecked(1);
		UI.PageOptionsVR.GUI.terrainlod:SetChecked(1);
		UI.PageOptionsVR.GUI.objdist:SetChecked(1);
		UI.PageOptionsVR.GUI.vegetationdist:SetValue( 1 );
		UI.PageOptionsVR.GUI.mirroreye:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.crosshair:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.vrscopes:SetChecked(1);
		UI.PageOptionsVR.GUI.seatedmode:OnChanged();
		UI.PageOptionsVR.GUI.mainhand:OnChanged();
		UI.PageOptionsVR.GUI.movedir:OnChanged();
		UI.PageOptionsVR.GUI.turnmode:OnChanged();
		UI.PageOptionsVR.GUI.turnspeed:OnChanged();
		UI.PageOptionsVR.GUI.weaponangle:OnChanged();
		UI.PageOptionsVR.GUI.terrainlod:OnChanged();
		UI.PageOptionsVR.GUI.objdist:OnChanged();
		UI.PageOptionsVR.GUI.vegetationdist:OnChanged();
		UI.PageOptionsVR.GUI.mirroreye:OnChanged();
		UI.PageOptionsVR.GUI.crosshair:OnChanged();
		UI.PageOptionsVR.GUI.ladders:OnChanged();
		UI.PageOptionsVR.GUI.vrscopes:OnChanged();
	end,
}

UI:CreateScreenFromTable("VROptions",UI.PageOptionsVR.GUI);