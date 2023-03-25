
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//	
//	File: GameMovieUser.cpp
//  Description:	Give access to movie functions from within the game. 
//	Interface for movie-system implemented by user for advanced function-support.
// 
//	History:
//	- October 1 2003: Created by Timur Davidenko and Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////
 
#include "stdafx.h" 

#include "Game.h"
#include "XNetwork.h"
#include "XServer.h"
#include "XClient.h"
#include "UIHud.h"
#include "XPlayer.h"
#include "PlayerSystem.h"
#include "XServer.h"
#include "WeaponSystemEx.h"
#include "ScriptObjectGame.h"
#include "ScriptObjectInput.h"
#include <IEntitySystem.h>
#include "UISystem.h"
#include "ScriptObjectUI.h"
#include <IMovieSystem.h>
#include "CMovieUser.h"
#include "UISystem.h"

//////////////////////////////////////////////////////////////////////////
void CMovieUser::SetActiveCamera( const SCameraParams &Params )
{
	if (!m_pGame)
		return;
	CXClient *pClient=m_pGame->GetClient();
	if (!pClient)
		return;
	pClient->SetEntityCamera(Params);
}

//////////////////////////////////////////////////////////////////////////
void CMovieUser::ResetCutSceneParams()
{
	// Suppress all currently playing sounds.

	IConsole *pCon = m_pGame->m_pSystem->GetIConsole();

	m_pGame->cl_display_hud->Set(1);
	ICVar *pPanoramic=pCon->GetCVar("hud_panoramic");
	if(pPanoramic)
		pPanoramic->Set(0);
	ICVar *pAIUpdate=pCon->GetCVar("ai_systemupdate");
	if(pAIUpdate)
		pAIUpdate->Set(1);
	ICVar *pAIIgnorePlayer=pCon->GetCVar("ai_ignoreplayer");
	if(pAIIgnorePlayer)
		pAIIgnorePlayer->Set(0);
	ICVar *pPhys=pCon->GetCVar("es_UpdatePhysics");
	if(pPhys)
		pPhys->Set(1);
}

//////////////////////////////////////////////////////////////////////////
void CMovieUser::BeginCutScene(unsigned long dwFlags,bool bResetFx)
{
	if (m_InCutSceneCounter > 0)
	{
		ResetCutSceneParams();
	}
	m_InCutSceneCounter++;

	IConsole *pCon=m_pGame->m_pSystem->GetIConsole();
	if(IAnimSequence::IS_16TO9&dwFlags)
	{
		ICVar *pPanoramic=pCon->GetCVar("hud_panoramic");
		if(pPanoramic)
			pPanoramic->Set(1);
	}
	if(IAnimSequence::NO_HUD&dwFlags)
	{
		m_pGame->cl_display_hud->Set(0);
	}
	if (IAnimSequence::NO_PLAYER&dwFlags)
	{
		m_pGame->HideLocalPlayer(true,false);
		ICVar *pAIIgnorePlayer=pCon->GetCVar("ai_ignoreplayer");
		if(pAIIgnorePlayer)
			pAIIgnorePlayer->Set(1);
	}
	if(IAnimSequence::NO_PHYSICS&dwFlags)
	{
		ICVar *pPhys=pCon->GetCVar("es_UpdatePhysics");
		if(pPhys)
			pPhys->Set(0);
	}
	if(IAnimSequence::NO_AI&dwFlags)
	{
		ICVar *pAIUpdate=pCon->GetCVar("ai_systemupdate");
		if(pAIUpdate)
			pAIUpdate->Set(0);
	}
	IScriptSystem *pSS=m_pGame->GetScriptSystem();
	_SmartScriptObject pClientStuff(pSS,true);
	if(pSS->GetGlobalValue("ClientStuff",pClientStuff)){
		pSS->BeginCall("ClientStuff","OnPauseGame");
		pSS->PushFuncParam(pClientStuff);
		pSS->EndCall();
	}

	// do not allow the player to mess around with player's keys
	// during a cutscene	
	GetISystem()->GetIInput()->GetIKeyboard()->ClearKeyState();
	m_pGame->m_pIActionMapManager->SetActionMap("player_dead");
	m_pGame->AllowQuicksave(false);

	// player's weapon might be playing a looping sound ... disable it:

	// Resume playing sounds.
	if(IAnimSequence::NO_GAMESOUNDS & dwFlags)
	{
		// lower all other sounds volume when playing cutscene
		GetISystem()->GetISoundSystem()->SetGroupScale(SOUNDSCALE_MISSIONHINT,0.5f);
		m_bSoundsPaused = true;
	}

	if (bResetFx)
	{
		m_pGame->m_p3DEngine->ResetScreenFx();
	}
}

//////////////////////////////////////////////////////////////////////////
void CMovieUser::EndCutScene()
{
	m_InCutSceneCounter--;
	if (m_InCutSceneCounter > 0)
		return;
	m_InCutSceneCounter = 0;
	ResetCutSceneParams();
	m_pGame->HideLocalPlayer(false,false);
	m_pGame->AllowQuicksave(true);

	if (!m_pGame->IsServer())
	{
		IScriptSystem *pSS=m_pGame->GetScriptSystem();
		_SmartScriptObject pClientStuff(pSS,true);
		if(pSS->GetGlobalValue("ClientStuff",pClientStuff)){
			pSS->BeginCall("ClientStuff","OnResumeGame");
			pSS->PushFuncParam(pClientStuff);
			pSS->EndCall();
		}
	}
	if (m_bSoundsPaused)
	{
		GetISystem()->GetISoundSystem()->SetGroupScale(SOUNDSCALE_MISSIONHINT,1.0f);
	}
  
	m_pGame->m_pIActionMapManager->SetActionMap("default");
	GetISystem()->GetIInput()->GetIKeyboard()->ClearKeyState();	

	// we regenerate stamina fpr the local payer on cutsceen end - supposendly he was idle long enough to get it restored
	if (m_pGame->GetMyPlayer())
	{
		CPlayer *pPlayer;
		if (m_pGame->GetMyPlayer()->GetContainer()->QueryContainerInterface(CIT_IPLAYER,(void**)&pPlayer))
		{
			pPlayer->m_stats.stamina = 100;
		}
	}

  // reset subtitles
  m_pGame->m_pClient->ResetSubtitles();
}

//////////////////////////////////////////////////////////////////////////
void CMovieUser::SendGlobalEvent(const char *pszEvent)
{
	HSCRIPTFUNCTION pEventFunc=NULL;
	IScriptSystem *pScriptSystem=m_pGame->GetSystem()->GetIScriptSystem();
	if (!pScriptSystem)
		return;
	_SmartScriptObject pMission(pScriptSystem, true);
	if (!pScriptSystem->GetGlobalValue("Mission", *pMission))
		return;
	if (pMission->GetValue(pszEvent, pEventFunc))
	{
		pScriptSystem->BeginCall(pEventFunc);
		// Pass itself as a sender.
		pScriptSystem->PushFuncParam(pMission);
		pScriptSystem->EndCall();
	}
}

//////////////////////////////////////////////////////////////////////////
void CMovieUser::PlaySubtitles( ISound *pSound )
{
	assert(pSound);
	
  bool bAlwaysDisplay=0;
  if(m_pGame->g_language)
  {
    char *pLanguage=m_pGame->g_language->GetString();

    if(pLanguage)
    {
      if(!stricmp(pLanguage, "japanese"))
      {
        bAlwaysDisplay=1;
      }
    }
  }
 
  // always show subtitles if japanese language set (requested), or subtitles console var on
  if(bAlwaysDisplay || (m_pGame->cv_game_subtitles && m_pGame->cv_game_subtitles->GetIVal()))      
	{
		char szLabel[2048];
		if (m_pGame->m_StringTableMgr.GetSubtitleLabel(pSound->GetName(),szLabel))
		{
			//	CryLogAlways("PLAYSUBTITLE: Subtitle found: %s",szLabel);
			// Wait for on play event for this sound, to prevent sound GetLengthMs function to stall execution.
			if (pSound->IsLoaded())
			{
				// If sound loaded do it directly.
				OnSoundEvent( SOUND_EVENT_ON_PLAY,pSound );
			}
			else
			{
				// Else wait for sound to call us.
				pSound->AddEventListener( this );
			}
		}
		//else
		//CryLogAlways("PLAYSUBTITLE: Subtitle NOT found: %s",pSound->GetName());
	}
	if (!pSound->IsPlaying())
		pSound->Play();
}

//////////////////////////////////////////////////////////////////////////
void CMovieUser::OnSoundEvent( ESoundCallbackEvent event,ISound *pSound )
{
	switch (event)
	{
	case SOUND_EVENT_ON_PLAY:
		{
			char szLabel[2048];
			if (m_pGame->m_StringTableMgr.GetSubtitleLabel(pSound->GetName(),szLabel))
			{
				//CryLogAlways("SOUNDEVENT: Subtitle found: %s",szLabel);   
				//m_pGame->GetSystem()->GetILog()->
				//m_pGame->m_pClient->AddHudMessage(szLabel,(float)(pSound->GetLengthMs())/1000.0f);
        m_pGame->m_pClient->AddHudSubtitle(szLabel, (float)(pSound->GetLengthMs())/1000.0f);
			}
			//else
			//CryLogAlways("SOUNDEVENT:Subtitle NOT found: %s",szLabel);
		}
		break;
	}
}

//////////////////////////////////////////////////////////////////////////
void CXGame::PlaySequence(const char *pszName,bool bResetFX)
{		
	m_pSystem->GetIMovieSystem()->PlaySequence(pszName,bResetFX);
}

//////////////////////////////////////////////////////////////////////////
void CXGame::StopCurrentCutscene()
{
	m_pSystem->GetIMovieSystem()->StopAllCutScenes();  
}
