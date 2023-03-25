
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XSystemServer.h
//  Description: IXSystem interface for the server.
//
//  History:
//  - August 8, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef GAME_XSYSTEMSERVER_H
#define GAME_XSYSTEMSERVER_H
#if _MSC_VER > 1000
# pragma once
#endif

#include "XSystemBase.h"
#include "IXMLDOM.h"

class CXGame;
class CXServer;
struct ILog;

//////////////////////////////////////////////////////////////////////
/*!Implements a the XSystem for a server.
can be coupled with a CXSystemDummy if a local client exists
*/
class CXSystemServer : public CXSystemBase
{
public:
	CXSystemServer(CXServer *pXServer,CXGame *pGame,ILog *pLog);
	virtual ~CXSystemServer();
	
	//// IXSystem ///////////////////////////////
	void		Release();
	bool		LoadLevel(const char *szLevelDir,const char *szMissionName, bool bEditor);
	
	IEntity*	SpawnEntity(class CEntityDesc &ed);
	void		RemoveEntity(EntityId wID, bool bRemoveNow=false);
	void		DeleteAllEntities();
	void		Disconnected(const char *szCause);
	bool		LoadCharacter(IEntity* pEntity, const char *szModel);
	void		BindEntity(EntityId idParent,EntityId idChild);
	void		UnbindEntity(EntityId idParent,EntityId idChild);
	bool		WriteTeams(CStream &stm);
	bool		ReadTeams(CStream &stm){return true;}
	void AddRespawnPoint(ITagPoint *pt);
	virtual void OnSetVar(ICVar *pVar);
	/////////////////////////////////////////////

	CXServer *m_pXServer;

protected:
	virtual void OnReadyToLoadLevel( SMissionInfo &missionInfo );	
};

#endif // GAME_XSYSTEMSERVER_H
