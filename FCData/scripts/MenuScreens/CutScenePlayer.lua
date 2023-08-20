UI.PageCutScenePlayer=
{	
	GUI=
	{
		CutScene =
		{
			classname = "videopanel",
			
			left = 0, top = 0,
			width = 800, height = 600,
			
			color = "0 0 0 255",

			zorder = 1000,
			
			bordersize = 0,
			tabstop = 1,
			
			looping = 0,
			keepaspect = 1,			
		
			OnFinished = function(Sender)
				UI.PageCutScenePlayer:Finished();
			end
		},

		OnUpdate = function(Sender)
			
			local bPlaying = UI.PageCutScenePlayer.GUI.CutScene:IsPlaying();
			
			if ((not bPlaying) or (tonumber(bPlaying) == 0)) then
				UI:StopCutScene();
				
				return;
			end

			if (UI.PageCutScenePlayer.bCanSkip and tonumber(UI.PageCutScenePlayer.bCanSkip) ~= 0) then
				if ((_time - UI.PageCutScenePlayer.fStartTime) >= UI.fCanSkipTime) then
					local szKeyName = Input:GetXKeyPressedName();
					local stopVideoRequested = Game:IsStopVideoRequested();
			
					if ((szKeyName == "esc") or (szKeyName == "spacebar") or (szKeyName == "f7") or stopVideoRequested) then
						UI:StopCutScene();
					end
				end
			end
					
			if (UI.PageCutScenePlayer.bFinished) then
				UI:DeactivateScreen("CutScenePlayer");
			end
		end,

		OnActivate= function(Sender)
			UI.PageCutScenePlayer.bFinished = nil;
			
			if (UI.PageCutScenePlayer.szCutSceneName) then
				local szLocalizedCutSceneFolder = gsub(UI.szLocalizedCutSceneFolder, "&language&", getglobal("g_language"));
							
				UI:HideMouseCursor();
				UI:HideBackground();

				local szCutScene = UI:GetCutSceneDrive()..szLocalizedCutSceneFolder..UI.PageCutScenePlayer.szCutSceneName;
				
				-- check the localized version
				if (not UI.PageCutScenePlayer.GUI.CutScene:LoadVideo(szCutScene, 1)) then
					-- did not load, check the non localized version
					szCutScene = UI:GetCutSceneDrive()..UI.szCutSceneFolder..UI.PageCutScenePlayer.szCutSceneName;
					
					if (not UI.PageCutScenePlayer.GUI.CutScene:LoadVideo(szCutScene, 1)) then
					-- non-localized version not found on disk, try cd
						if (UI:GetCutSceneDrive() == "./") then
						
							local szCDPath = Game:GetCDPath();
							
							if (szCDPath) then
								szCutScene = strsub(szCDPath, 1, 2).."/"..UI.szCutSceneFolder..UI.PageCutScenePlayer.szCutSceneName;
								
								if (not UI.PageCutScenePlayer.GUI.CutScene:LoadVideo(szCutScene, 1)) then
									-- there is no way to find this cutscene
									UI.PageCutScenePlayer:Finished();
								end
							else
								-- there is no way to find this cutscene
								UI.PageCutScenePlayer:Finished();
							end
						else
							-- there is no way to find this cutscene
							UI.PageCutScenePlayer:Finished();
						end
					end
				end
				
				UI.PageCutScenePlayer.GUI.CutScene:SetVolume(tonumber(getglobal("s_SFXVolume")));
				
				if (getglobal("s_SoundEnable") and tonumber(getglobal("s_SoundEnable")) ~= 0) then
					UI.PageCutScenePlayer.GUI.CutScene:EnableAudio(1);
				else
					UI.PageCutScenePlayer.GUI.CutScene:SetVolume(0);
				end

				UI.PageCutScenePlayer.GUI.CutScene:Play();
				UI.PageCutScenePlayer.fStartTime = _time;
			end

			UI.PageCutScenePlayer.szCutSceneName = nil;
			UI:StopMusic();
		end,
		
		OnDeactivate = function(Sender)		
			local bPlaying = UI.PageCutScenePlayer.GUI.CutScene:IsPlaying();
						
			UI.PageCutScenePlayer.GUI.CutScene:ReleaseVideo();
			
			if (bPlaying) then
				UI.PageCutScenePlayer:Finished();
			end

			UI.bInGameOverride = nil;
			
			if (UI.PageCutScenePlayer.szGotoPage) then
				GotoPage(UI.PageCutScenePlayer.szGotoPage, UI.PageCutScenePlayer.bGotoPageShowBack);
			end
			UI:SetFocus(Sender.CutScene);
			UI:PlayMusic();
		end
	},	
};

function UI.PageCutScenePlayer:Finished()

	UI.PageCutScenePlayer.bFinished = 1;
	
	Game:HideMenu();
	
	UI.bInGameOverride = nil;
	UI.PageCutScenePlayer.szCutSceneName = nil;
	
	UI:DeactivateScreen("CutScenePlayer");

	if (UI.PageCutScenePlayer.szMessage and strlen(UI.PageCutScenePlayer.szMessage)) then
		Game:SendMessage(UI.PageCutScenePlayer.szMessage);
	elseif (UI.PageCutScenePlayer.pfnFunction) then
		UI.PageCutScenePlayer.pfnFunction();
	end
end

UI:CreateScreenFromTable("CutScenePlayer", UI.PageCutScenePlayer.GUI);

function UI:PlayCutScene(szCutSceneName, szMessage, szGotoPage, bGotoPageShowBack)
	UI:PlayCutSceneEx(szCutSceneName, szMessage, szGotoPage, bGotoPageShowBack, 1);
end

function UI:PlayCutSceneEx(szCutSceneName, szMessage, szGotoPage, bGotoPageShowBack, bCanSkip)

	if (UI.MusicId ~= nil) then
		Sound:StopSound(UI.MusicId);
	end

	UI.bInGameOverride = 1; -- don't use the current ingame menu

	Game:ShowMenu();

	UI.PageCutScenePlayer.szCutSceneName = szCutSceneName;
	UI.PageCutScenePlayer.szGotoPage = szGotoPage;
	UI.PageCutScenePlayer.bGotoPageShowBack = bGotoPageShowBack;
	UI.PageCutScenePlayer.bCanSkip = bCanSkip;

	if (type(szMessage) == "function") then
		UI.PageCutScenePlayer.pfnFunction = szMessage;
		UI.PageCutScenePlayer.szMessage = nil;
	else
		UI.PageCutScenePlayer.szMessage = szMessage;
		UI.PageCutScenePlayer.pfnFunction = nil;
	end

	UI:DeactivateAllScreens();
	UI:ActivateScreen("CutScenePlayer");
end

function UI:StopCutScene()
	Input:ResetKeyState();
	UI:DeactivateScreen("CutScenePlayer");
end

