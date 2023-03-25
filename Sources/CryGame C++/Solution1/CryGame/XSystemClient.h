
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XSystemClient.h
//  Description: IXSystem interface for the client.
//
//  History:
//  - August 8, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef GAME_XSYSTEMCLIENT_H
#define GAME_XSYSTEMCLIENT_H
#if _MSC_VER > 1000
# pragma once
#endif

#include "XSystemBase.h"

//////////////////////////////////////////////////////////////////////
/*!Implements the XSystem for a remote client
*/
class CXSystemClient : public CXSystemBase
{
public:
	CXSystemClient(CXGame *pGame,ILog *pLog);
	virtual ~CXSystemClient();
		
	void		Release();
	bool		LoadLevel(const char *szLevelDir,const char *szMissionName, bool bEditor=false);
	IEntity*	SpawnEntity(class CEntityDesc &ed);
	void		RemoveEntity(EntityId wID, bool bRemoveNow=false);
	void		DeleteAllEntities();
	void		Disconnected(const char *szCause);
	void		SetVariable(const char *sName,const char *sValue);	
	bool		WriteTeams(CStream &stm){return true;}
	
};

#endif // GAME_XSYSTEMCLIENT_H
