
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XSystemDummy.h
//  Description: Dummy IXSystem interface.
//
//  History:
//  - August 8, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef GAME_XSYSTEMDUMMY_H
#define GAME_XSYSTEMDUMMY_H
#if _MSC_VER > 1000
# pragma once
#endif

#include "XSystemBase.h"

//////////////////////////////////////////////////////////////////////
/*!Implements a dummy XSystem for a local client.
*/
class CXSystemDummy : public CXSystemBase
{
public:
	CXSystemDummy(CXGame *pGame,ILog *pLog);
	virtual ~CXSystemDummy();

	//// IXSystem ///////////////////////////////
	void		Release();
	bool		LoadLevel(const char *szLevelDir,const char *szMissionName, bool bEditor=false);
	IEntity*	SpawnEntity(class CEntityDesc &ed);
	void		RemoveEntity(EntityId wID, bool bRemoveNow = false);
	void		DeleteAllEntities();
	void		Disconnected(const char *szCause);
	void		SetMyPlayer(EntityId wID);
	virtual int	AddTeam(string sTeamName, int nTeamId) { return -1; }
	void		RemoveTeam(int nTeamId) {}
	void		SetTeamScore(int nTeamId, short nScore) {}
	void		OnSpawn(IEntity *ent, CEntityDesc & ed){};
	void		OnSpawnContainer( CEntityDesc &ed,IEntity *pEntity ){};
	bool		WriteTeams(CStream &stm){return true;}

};

#endif // GAME_XSYSTEMDUMMY_H
