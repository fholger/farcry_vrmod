
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
// 
//	File: ScriptObjectClient.h
//  Description:	Interface of the CScriptObjectClient class,
//								for multiplayer game session.			
//		This class implements script-functions for exposing the local client functionalities
//
//		REMARKS:
//		After initialization of the script-object it will be globally accessable through scripts using the namespace "Client".
//		This object isn't instantiated on a dedicated server
//
//		Example:
//		Client.SpawnEntity("Rocket");
//
//		IMPLEMENTATIONS NOTES:
//		These function will never be called from C-Code. They're script-exclusive.
//
//	History: 
//	- June 2001: File created by Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef _SCRIPTOBJECTCLIENT_H_
#define _SCRIPTOBJECTCLIENT_H_

#include <IScriptSystem.h>
#include <_ScriptableEx.h>
class CXClient;
class CXGame;

//////////////////////////////////////////////////////////////////////
class CScriptObjectClient :
public _ScriptableEx<CScriptObjectClient> 
{
public:
	CScriptObjectClient();
	virtual ~CScriptObjectClient();
	void Create(IScriptSystem *pScriptSystem,CXGame *pGame,CXClient *pClient);
	static void InitializeTemplate(IScriptSystem *pSS);

	int GetGameStartTime(IFunctionHandler *pH);
	int GetGameState(IFunctionHandler *pH);
	int GetGameStateString(IFunctionHandler *pH);
	int CallVote(IFunctionHandler *pH);
	int Vote(IFunctionHandler *pH);
	int Kill(IFunctionHandler *pH);
	int JoinTeamRequest(IFunctionHandler *pH);
	int SendCommand(IFunctionHandler *pH);
	int GetPing(IFunctionHandler *pH);
	int Say(IFunctionHandler *pH);
	int SayTeam(IFunctionHandler *pH);
	int SayOne(IFunctionHandler *pH);
	int SetName(IFunctionHandler *pH);
	int GetSoundsEventsPos(IFunctionHandler *pH);
	int SetBitsPerSecond(IFunctionHandler *pH);
	int SetUpdateRate(IFunctionHandler *pH);
	int GetServerCPUTargetName(IFunctionHandler *pH);
	int GetServerOSTargetName(IFunctionHandler *pH);
	// to sync AI state for co-op
	int AIState(IFunctionHandler *pH);

private: 

	CXClient *								m_pClient;					//!<
	CXGame *									m_pGame;						//!<
	IScriptObject *						m_pSoundEventPos;		//!<
};

#endif //_SCRIPTOBJECTCLIENT_H_