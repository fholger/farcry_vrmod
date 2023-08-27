UI.PageMainScreen =
{	
	GUI=
	{
		OnActivate = function(self)
			self.fActivateTime = System:GetCurrAsyncTime();
		end,

		-- quickfix to prevent credits/demoloops from going to game after quitting with escape..
		-- this happens becase the switch is made in the next frame (it's a message)
		OnUpdate = function(self)
			if ((self.fActivateTime) and (System:GetCurrAsyncTime() - self.fActivateTime > 0.125)) then
				self.fActivateTime = nil;
				UI:EnableSwitch(1);
			end
		end
	},
	
	QuitYes = function()
		Game:SendMessage("Quit-Yes");
	end,

	ShowConfirmation = function()
		UI.YesNoBox(Localize("Quit"), Localize("QuitConfirmation"), UI.PageMainScreen.QuitYes);
	end,
}

AddUISideMenu(UI.PageMainScreen.GUI,
{
	{ "Campaign", Localize("Campaign"), "Campaign", },
	{ "Multiplayer", Localize("Multiplayer"), "Multiplayer", },
--    	{ "ServerAdmin", "Server Admin", "ServerAdmin",},
--    	{ "VotePanel", "Vote Panel", "VotePanel",},
	{ "Options", Localize("Options"), "Options", },
	{ "Profiles", Localize("Profiles"), "Profiles", },
	{ "Mods", Localize("Mods"), "Mods", },
	{ "DemoLoop", Localize("DemoLoop"), "DemoLoop", 0},
	{ "Credits", Localize("Credits"), "Credits", 0},	
	{ "Quit", Localize("Quit"), UI.PageMainScreen.ShowConfirmation, },	
});

UI:CreateScreenFromTable("MainScreen", UI.PageMainScreen.GUI);

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
UI.PageMainScreenInGame =
{	
	GUI=
	{
		OnActivate = function(self)
			self.fActivateTime = System:GetCurrAsyncTime();
		end,

		-- quickfix to prevent credits/demoloops from going to game after quitting with escape..
		-- this happens becase the switch is made in the next frame (it's a message)
		OnUpdate = function(self)
			if ((self.fActivateTime) and (System:GetCurrAsyncTime() - self.fActivateTime > 0.125)) then
				self.fActivateTime = nil;
				UI:EnableSwitch(1);
			end
		end		
	},
	
	QuitYes = function()
		Game:SendMessage("Quit-Yes");
	end,

	ShowConfirmation = function()
		UI.YesNoBox(Localize("Quit"), Localize("QuitConfirmation"), UI.PageMainScreen.QuitYes);
	end,
	
	QuickSave = function()
		Game:SendMessage("SaveGame");
		GotoPage("$Return$");
	end,
}

AddUISideMenu(UI.PageMainScreenInGame.GUI,
{
	{ "Return", Localize("ReturnToGame"), "$Return$", },
	{ "QuickSave", "Quick save", UI.PageMainScreenInGame.QuickSave, },
	{ "-", "-", "-", },	-- separator
	{ "Campaign", Localize("Campaign"), "Campaign", },
	{ "Multiplayer", Localize("Multiplayer"), "Multiplayer", },
    	--{ "ServerAdmin", "Server Admin", "ServerAdmin",},
	{ "Options", Localize("Options"), "Options", },
	{ "Profiles", Localize("Profiles"), "Profiles", },
	{ "Mods", Localize("Mods"), "Mods", },
	{ "DemoLoop", Localize("DemoLoop"), "DemoLoop", 0},
	{ "Credits", Localize("Credits"), "Credits", 0},
	{ "Quit", Localize("Quit"), UI.PageMainScreen.ShowConfirmation, },
});

UI:CreateScreenFromTable("MainScreenInGame", UI.PageMainScreenInGame.GUI);