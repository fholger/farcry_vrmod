--------------------------------------------------------------------------------
-- System Initialization
--------------------------------------------------------------------------------
function UI:OnInit()

	-- get the list of videofiles
	local szScriptFolder = "Scripts/MenuScreens/";

	----------------------
	-- Load Configuration
	----------------------
	Script:LoadScript(szScriptFolder.."UISystemCfg.lua", 1);				-- Load Configuration File

	-- Load the skin
	Script:LoadScript(UI.szSkinPath, 1);

	-- Load Utilities
	Script:LoadScript(szScriptFolder.."UISystemUtils.lua", 1);

	-- Set background and mouse cursor
	UI:SetMouseCursor(System:LoadImage(UI.szMouseCursor));
	UI:SetMouseCursorSize(24, 24);

	-- Language Table
	Language:LoadStringTable("MenuTable.xml");

	-- Load Music
	UI.MusicId = Sound:LoadStreamSound(UI.szMenuMusic, SOUND_LOOP+SOUND_MUSIC+SOUND_UNSCALABLE);

	----------------------
	-- Load Screen Scripts
	----------------------

	-- Load Common Generic Screens
	Script:LoadScript(szScriptFolder.."Common/BackScreen.lua", 1);				-- Back Borders
	Script:LoadScript(szScriptFolder.."Common/Confirmation.lua", 1);			-- Confirmation Dialog
	Script:LoadScript(szScriptFolder.."Common/MessageDialog.lua", 1);			-- Message Dialog
	Script:LoadScript(szScriptFolder.."Common/InputDialog.lua", 1);				-- Input Dialog
	Script:LoadScript(szScriptFolder.."Common/LoginDialog.lua", 1);				-- Login Dialog
	Script:LoadScript(szScriptFolder.."Common/ProgressDialog.lua", 1);			-- Progress Dialog
	Script:LoadScript(szScriptFolder.."Common/JoinIPDialog.lua", 1);			-- Join by IP Dialog

	-- Load Main Menu
	Script:LoadScript(szScriptFolder.."MainScreen.lua", 1);

	-- Load Single Player Menu
	Script:LoadScript(szScriptFolder.."Campaign.lua", 1);

	-- Load Multiplayer Screens
	Script:LoadScript(szScriptFolder.."Multiplayer.lua", 1);
	Script:LoadScript(szScriptFolder.."Multiplayer/CreateServer.lua", 1);
	Script:LoadScript(szScriptFolder.."MultiPlayer/LANServerList.lua", 1);
	Script:LoadScript(szScriptFolder.."MultiPlayer/NETServerList.lua", 1);
	Script:LoadScript(szScriptFolder.."MultiPlayer/WaitServer.lua", 1);
	Script:LoadScript(szScriptFolder.."MultiPlayer/BannerUpdate.lua", 1);
    	Script:LoadScript(szScriptFolder.."MultiPlayer/ServerAdmin.lua", 1);
    	Script:LoadScript(szScriptFolder.."MultiPlayer/VotePanel.lua", 1);

	-- Load Options Screens
	Script:LoadScript(szScriptFolder.."Options.lua", 1);
	Script:LoadScript(szScriptFolder.."Options/Game.lua", 1);
	Script:LoadScript(szScriptFolder.."Options/Control.lua", 1);
	Script:LoadScript(szScriptFolder.."Options/Video.lua", 1);
	Script:LoadScript(szScriptFolder.."Options/VideoAdv.lua", 1);
	Script:LoadScript(szScriptFolder.."Options/Sound.lua", 1);
	Script:LoadScript(szScriptFolder.."Options/BindWaitForKey.lua", 1);
	Script:LoadScript(szScriptFolder.."Options/VR.lua", 1);

	-- Load Profiles Menu
	Script:LoadScript(szScriptFolder.."Profiles.lua", 1);

	-- Load Demo Loop Menu
	Script:LoadScript(szScriptFolder.."DemoLoop.lua", 1);

	-- Load Cut Scene Player Screen
	Script:LoadScript(szScriptFolder.."CutScenePlayer.lua", 1);

	-- Load Credits Screen
	Script:LoadScript(szScriptFolder.."Credits.lua", 1);

	-- Load Mods Screen
	Script:LoadScript(szScriptFolder.."Mods.lua", 1);

	-- Load Video Sequence Player
	Script:LoadScript(szScriptFolder.."VideoSequencer.lua", 1);

	-- Load Splash Screen Player
	Script:LoadScript(szScriptFolder.."SplashScreen.lua", 1);

	-- Load InGame Screens
	Script:LoadScript(szScriptFolder.."Ingame/InGameSingle.lua", 1);
	Script:LoadScript(szScriptFolder.."Ingame/InGameNonTeam.lua", 1);
	Script:LoadScript(szScriptFolder.."Ingame/InGameTeam.lua", 1);
	Script:LoadScript(szScriptFolder.."Ingame/InGameTeamClass.lua", 1);
	Script:LoadScript(szScriptFolder.."Ingame/Disconnect.lua", 1);

	-- Load Message Mode Handler Screen
	-- MessageMode, is the handler of ingame say, sayteam, tell, and other commands
	Script:LoadScript(szScriptFolder.."MessageMode.lua", 1);				-- MessageMode handler

	UI:DeactivateAllScreens();

	if( g_reload_ui == "cmd_goto_video_options" ) then
		g_reload_ui = 0;
		GotoPage( "MainScreen", 0 );
		GotoPage( "Options" );
		UI.PageOptions.GUI.VideoOptions.OnCommand( UI.PageOptions.GUI.VideoOptions );
	elseif( g_reload_ui == "cmd_goto_profiles" ) then
		g_reload_ui = 0;
		GotoPage( "Profiles" );
	elseif( g_reload_ui == "cmd_goto_profiles_and_warn" ) then
		g_reload_ui = 0;
		GotoPage( "Profiles" );
		UI.MessageBox( Localize( "AdvChangeMess1" ), Localize( "AdvChangeMess2" ));
	else
		local IntroSequence=
		{
			{ "Governmental_Message.bik", 1 },	-- "name", canskip
			{ "Ubi.bik", 1 },	-- "name", canskip
			{ "Crytek.bik", 1 },
			{ "Sandbox.bik", 1 },
			{ "AMD64.bik", 1 },
		};

		VideoSequencer:Play(IntroSequence, UI.CheckOptions);
	end;

	UI:EnableSwitch(1);
	UI:PrecacheMPModels();
end

--------------------------------------------------------------------------------
-- System Deinitialization
--------------------------------------------------------------------------------
function UI:OnRelease()
	UI:StopMusic();
	UI.MusicId = nil;

	if (NewUbisoftClient) then
		System:Log("DISCONNECTED FROM UBI.com");
		NewUbisoftClient:Client_Disconnect();
	end
end

--------------------------------------------------------------------------------
-- System Idle
--------------------------------------------------------------------------------
function UI:OnIdle(fIdleTime)
	-- 60 seconds of idle before doing something
	if (fIdleTime > 120.0) then
		if (UI:GetScreen("DemoLoop")) then
			if ((UI:IsScreenActive("DemoLoop") == 0) and (UI:IsScreenActive("MainScreen") ~= 0) and (UI:IsScreenActive("MainScreenInGame") ~= 0)) then
				UI.bWasIdle = 1;
				UI:ActivateScreen("DemoLoop");
			end
		end
	end
end

--------------------------------------------------------------------------------
-- System Switch (e.g. user pressed ESC to switch between game and menu)
--------------------------------------------------------------------------------
-- /param bSwitchOn 1=on, 0=off
function UI:OnSwitch( bSwitchOn )

--	System:Log("UI:OnSwitch");		-- debugging

	System:ShowConsole(0);

	if (bSwitchOn) then
--		System:Log("SwichOn 1");

		Input:SetMouseSensitivityScale(1.0);

		-- make sure that we disable some stuff for the localplayer
		if (ClientStuff and _localplayer and ClientStuff.OnMenuEnter) then
			ClientStuff:OnMenuEnter();
		end

		if (ClientStuff) and (not UI.bInGameOverride) then

--		System:Log("SwichOn 2");

			UI:PlayMusic();

			if (not UI.PageBackScreen.GUI.Video:IsPlaying()) then
				UI.PageBackScreen:PlayRandomVideo();
			end

			local iVideoOn = 1;

			if (ClientStuff.GetInGameMenuVideoOn) then
				iVideoOn = ClientStuff:GetInGameMenuVideoOn();
			end

			local sMenuPageName=ClientStuff:GetInGameMenuName();

--			System:Log("UI:OnSwitch MenuPage="..sMenuPageName);		-- debugging

			if (iVideoOn ~= 0) then
				GotoPage(sMenuPageName, 1, 0);
			else
				GotoPage(sMenuPageName, 1, 1);
			end

		elseif (UI.bInGameOverride) then

--			System:Log("UI:OnSwitch UI.bInGameOverride");		-- debugging

			UI.bInGameOverride = nil;
		end
	else
--		System:Log("SwichOff");
		UI:DeactivateAllScreens();

		UI:StopMusic();
	end
end



-----------------------------------------------------------------------------
-- Can we render the game in the background ?
------------------------------------------------------------------------------
function UI:CanRenderGame()
	if (not ClientStuff) then
		return nil;
	end

	if (Game:IsInMenu()) then
		if (ClientStuff.GetInGameMenuVideoOn) then
			if (ClientStuff:GetInGameMenuVideoOn() ~= 0) then
				return nil;
			end
		end
	end

	return 1;
end

--------------------------------------------------------------------------------
-- System Can Switch ? (e.g. user pressed ESC to switch between game and menu)
--------------------------------------------------------------------------------
-- /param bSwitchOn 1=on, 0=off
function UI:CanSwitch( bSwitchOn )
	if (bSwitchOn) then
		if ((UI.bCanSwitchOn and UI.bCanSwitchOn ~= 0) or (not UI.bCanSwitchOn)) then
			return 1;
		end

		return nil;
	else
		if (UI.bCanSwitchOff and UI.bCanSwitchOff == 0) then
			return nil;
		end

		return 1;
	end
end