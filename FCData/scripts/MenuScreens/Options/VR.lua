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

		motioncontrols_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 149,
			width = 112,

			text="Motion controls",
		},

		motioncontrols=
		{
			left = 320, top = 149,
			width = 28, height = 28,

			skin = UI.skins.CheckBox,

			tabstop = 4,

			OnChanged=function(Sender)
				if (Sender:GetChecked()) then
					setglobal("vr_enable_motion_controllers", 1);
				else
					setglobal("vr_enable_motion_controllers", 0);
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

		turnmode_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 219,
			width = 112,

			text="Turn mode",
		},

		turnmode=
		{
			left = 320, top = 219,
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

			left = 200, top = 254,
			width = 112,

			text="Turn speed",
		},

		turnspeed =
		{
			skin = UI.skins.HScrollBar,

			left = 320, top = 254,
			width = 162, height = 24,

			tabstop = 5,

			OnChanged = function( sender )
				local newValue = tonumber( UI.PageOptionsVR.GUI.turnspeed:GetValue() );
				if( newValue < 0.0 ) then
					newValue = 0.0;
				elseif( newValue > 1.0 ) then
					newValue = 1.0;
				end;
				-- map to value range [0.5, 2.0]
				newValue = 0.5 + newValue * 1.5;
				setglobal( "vr_smooth_turn_speed", newValue );
			end,
		},

		weaponangle_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 289,
			width = 112,

			text="Weapon angle",
		},

		weaponangle =
		{
			skin = UI.skins.HScrollBar,

			left = 320, top = 289,
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

		sep_h0 =
		{
			skin = UI.skins.MenuBorder,

			left = 200, top = 341,
			width = 290, height = 2,
			bordersides = "t",

			zorder = -50,
		},

		yawdeadzone_text=
		{
			skin = UI.skins.Label,

			left = 200, top = 359,
			width = 112,

			text="Mouse yaw deadzone",
		},

		yawdeadzone =
		{
			skin = UI.skins.HScrollBar,

			left = 320, top = 359,
			width = 162, height = 24,

			tabstop = 5,

			OnChanged = function( sender )
				local newValue = tonumber( UI.PageOptionsVR.GUI.yawdeadzone:GetValue() );
				if( newValue < 0.0 ) then
					newValue = 0.0;
				elseif( newValue > 1.0 ) then
					newValue = 1.0;
				end;
				-- map to value range [0, 60]
				newValue = newValue * 60;
				setglobal( "vr_yaw_deadzone_angle", newValue );
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

		vegetationdist_text=
		{
			skin = UI.skins.Label,

			left = 488, top = 184,
			width = 112,

			text="Vegetation render dist",
		},

		vegetationdist =
		{
			skin = UI.skins.HScrollBar,

			left = 608, top = 184,
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

			left = 488, top = 219,
			width = 112,

			text="Mirror eye",
		},

		mirroreye=
		{
			left = 608, top = 219,
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

			left = 488, top = 254,
			width = 112,

			text="Crosshair",
		},

		crosshair=
		{
			left = 608, top = 254,
			width = 162, height = 28,

			skin = UI.skins.ComboBox,

			tabstop = 7,

			OnChanged = function( Sender )
				local eye = tonumber( UI.PageOptionsVR.GUI.crosshair:GetSelectionIndex() ) - 1;
				setglobal( "vr_crosshair", eye );
			end,
		},

		OnActivate= function(Sender)
			UI.PageOptionsVR.GUI.motioncontrols:SetChecked(vr_enable_motion_controllers);
			UI.PageOptionsVR.GUI.terrainlod:SetChecked(vr_render_force_max_terrain_detail);

			UI.PageOptionsVR.GUI.mainhand:Clear();
			UI.PageOptionsVR.GUI.mainhand:AddItem( "Right" );
			UI.PageOptionsVR.GUI.mainhand:AddItem( "Left" );

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
			local cur_turnmode = tonumber( getglobal( "vr_snap_turn_amount" ) ) / 15;
			UI.PageOptionsVR.GUI.turnmode:SelectIndex( cur_turnmode + 1 );

			UI.PageOptionsVR.GUI.turnspeed:SetValue( ( getglobal( "vr_smooth_turn_speed" ) - 0.5) / 1.5 );
			UI.PageOptionsVR.GUI.yawdeadzone:SetValue( getglobal( "vr_yaw_deadzone_angle" ) / 60.0 );
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
		end,

		OnDeactivate = function(Sender)
		end
	},

	------------------------------------------------------------------------
	ResetToDefaults=function()
		UI.PageOptionsVR.GUI.motioncontrols:SetChecked(1);
		UI.PageOptionsVR.GUI.mainhand:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.turnmode:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.turnspeed:SetValue( 0.5 );
		UI.PageOptionsVR.GUI.weaponangle:SetValue( 0.667 );
		UI.PageOptionsVR.GUI.yawdeadzone:SetValue( 0.5 );
		UI.PageOptionsVR.GUI.terrainlod:SetChecked(1);
		UI.PageOptionsVR.GUI.vegetationdist:SetValue( 1 );
		UI.PageOptionsVR.GUI.mirroreye:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.crosshair:SelectIndex( 1 );
		UI.PageOptionsVR.GUI.motioncontrols:OnChanged();
		UI.PageOptionsVR.GUI.mainhand:OnChanged();
		UI.PageOptionsVR.GUI.turnmode:OnChanged();
		UI.PageOptionsVR.GUI.turnspeed:OnChanged();
		UI.PageOptionsVR.GUI.weaponangle:OnChanged();
		UI.PageOptionsVR.GUI.yawdeadzone:OnChanged();
		UI.PageOptionsVR.GUI.terrainlod:OnChanged();
		UI.PageOptionsVR.GUI.vegetationdist:OnChanged();
		UI.PageOptionsVR.GUI.mirroreye:OnChanged();
		UI.PageOptionsVR.GUI.crosshair:OnChanged();
	end,
}

UI:CreateScreenFromTable("VROptions",UI.PageOptionsVR.GUI);