	-- todo:
-- -get current levelname
-- -position better
-- -add difficulty
-- -make loading

UI.PageInGameSingle=
{
	CheckpointName = {},

	GUI=
	{
		thumbnail=
		{
			skin = UI.skins.MenuBorder,
			left = 222, top = 204,
			width = 256, height = 192,
			
			color = "255 255 255 255",
		},	

		CheckpointLabel=
		{
			skin = UI.skins.MenuBorder,
			left = 496, top = 151,
			width = 275, height = 28,
			bordersides = "tlr",
			
			halign = UIALIGN_CENTER,
			
			text = Localize("Checkpoint"),
		},	

		CheckpointList=
		{
			skin = UI.skins.ListView,
			left = 496, top = 178,
			width = 275, height = 270,
			
			fontsize = 12,
			
			zorder = 10,
			
			tabstop = 1,
			
			vscrollbar=
			{
				skin = UI.skins.VScrollBar,
			},
			hscrollbar=
			{
				skin = UI.skins.HScrollBar,
			},
			
			OnChanged = function(Sender)
				UI.PageInGameSingle:SetPicture();
			end,
		},

		LoadGame=
		{
			text = Localize("Load_SaveGame"),
			left = 600,
			skin = UI.skins.BottomMenuButton,
			
			tabstop = 2,
			
			OnCommand = function(Sender)
			
				local iSelection = UI.PageInGameSingle.GUI.CheckpointList:GetSelection(0);
				
				if not iSelection then
					return
				end
				
				printf(iSelection);

				local szFilename = UI.PageInGameSingle.CheckpointName[iSelection];
				
				printf(szFilename);
				
				if (szFilename) then
					UI.PageInGameSingle.LoadGame(szFilename);
				end
			end,
		},

		OnActivate = function(Sender)
		
			Sender.CheckpointList.OnCommand = Sender.LoadGame.OnCommand;
			
			local szCurrentLevel = getglobal("g_LevelName");
			local szProfileName = getglobal("g_playerprofile");
		
			if ((not szProfileName) or (strlen(szProfileName) < 1)) then
				szProfileName = "default";
				g_playerprofile = "default";
			end
			
			local SaveList = Game:GetSaveGameList(szProfileName);
			local iCPCount = 0;
			
			for x, SaveGame in SaveList do
				if (strlower(tostring(SaveGame.Level)) == strlower(tostring(szCurrentLevel))) then
					iCPCount = iCPCount + 1;
				end
			end
			
			local iLastCheckpoint;
			Sender.CheckpointList:Clear();
			
			local i = 0;
			for x, SaveGame in SaveList do
				if (strlower(tostring(SaveGame.Level)) == strlower(tostring(szCurrentLevel))) then
					i = i + 1;
				
					local szFileName = strsub(SaveGame.Filename, 1, strlen(SaveGame.Filename)-strlen(".sav"));	
					local szCheckpointName;			
					local iCheckpoint;
					
					local szDate = "%.2d/%.2d/%.2d";
					
					if (getglobal("g_language") and strlower(getglobal("g_language")) == "french") then
						szDate = format(szDate, SaveGame.Day, SaveGame.Month, SaveGame.Year);
					else
						szDate = format(szDate, SaveGame.Month, SaveGame.Day, SaveGame.Year);
					end
					
					if (i == iCPCount) then
						szCheckpointName = format(szDate.." [%.2d:%.2d:%.2d] @CheckpointLast", SaveGame.Hour, SaveGame.Minute, SaveGame.Second);
						iCheckpoint = UI.PageInGameSingle.GUI.CheckpointList:InsertItem(0, szCheckpointName);
						iLastCheckpoint = iCheckpoint;
					else
						szCheckpointName = format(szDate.." [%.2d:%.2d:%.2d]", SaveGame.Hour, SaveGame.Minute, SaveGame.Second);
						iCheckpoint = UI.PageInGameSingle.GUI.CheckpointList:InsertItem(0, szCheckpointName)
					end

					UI.PageInGameSingle.CheckpointName[iCheckpoint] = szFileName;
				end
			end
			
			if (iLastCheckpoint) then
				UI:SetFocus(UI.PageInGameSingle.GUI.CheckpointList);
				UI.PageInGameSingle.GUI.CheckpointList:SelectIndex(iLastCheckpoint);
			end
			
			UI.PageInGameSingle:SetPicture();
		
			if (Hud) then
				Hud.bHide = 1;
			end
			
		end,
		
		OnDeactivate = function(Sender)
			if (Hud) then
				Hud.bHide = nil;
			end	
		end,
	},
	

	LoadGame = function(szFilename)
		if (szFilename) then

			setglobal("g_GameType","Default");
			
--			UI.PageCampaign.SetAIDifficulty(UI.PageInGameSingle.iDifficultyLevel);

			Game:SendMessage("LoadGame "..szFilename);
		end
	end,
	
	SetPicture = function()
		local iSelection = UI.PageInGameSingle.GUI.CheckpointList:GetSelection(0);

		if iSelection then
		
			local szFileName = UI.PageInGameSingle.CheckpointName[iSelection];
			
			if (szFileName and strlen(szFileName) > 1) then
			
				--szFileName = "profiles/player/"..getglobal("g_playerprofile").."/savegames/"..szFileName;
				szFileName = "textures/checkpoints/"..szFileName;
			
				local iTexture = System:LoadImage(szFileName);
	
				if (iTexture) then
					UI.PageInGameSingle.GUI.thumbnail:SetColor("255 255 255 255");
					UI.PageInGameSingle.GUI.thumbnail:SetTexture(iTexture);
	
					return;
				end
			end
		end

		UI.PageInGameSingle.GUI.thumbnail:SetColor("0 0 0 64");
		UI.PageInGameSingle.GUI.thumbnail:SetTexture(nil);
	end,

};

AddUISideMenu(UI.PageInGameSingle.GUI,
{
	{ "Return", Localize("ReturnToGame"), "$Return$", },
	{ "QuickSave", "Quick save", UI.PageMainScreenInGame.QuickSave, },
	{ "-", "-", "-", },	-- separator
	{ "MainMenu", Localize("MainMenu"), "$MainScreen$", 0},
	{ "Options", Localize("Options"), "Options", },
	{ "-", "-", "-", },	-- separator
	{ "Quit", "@Quit", UI.PageMainScreen.ShowConfirmation, },	
});
	
UI:CreateScreenFromTable("InGameSingle",UI.PageInGameSingle.GUI);


UI.PageInGameSingleSaving=
{
	GUI=
	{
		backpane=
		{
			classname = "static",
			left = 0, top = 0,
			width = 800, height = 600,
			
			color = UI.szMessageBoxColor,
			
			valign = UIALIGN_MIDDLE,
			halign = UIALIGN_CENTER,
			style = UISTYLE_TRANSPARENT,
			
			fontsize = 24,
					
			text = "@SavingGame",
		},
	},
}

UI:CreateScreenFromTable("InGameSingleSaving",UI.PageInGameSingleSaving.GUI);

function Game:OnBeforeSave()

	UI:HideBackground();
	UI:HideMouseCursor();

	UI:DeactivateAllScreens();	
	UI:ActivateScreen("InGameSingleSaving");
	
	Game:EnableUIOverlay(1, 1);

end

function Game:OnAfterSave()
	
	UI:ShowMouseCursor();
	UI:DeactivateAllScreens();
	
	Game:EnableUIOverlay(0, 0);
	
end