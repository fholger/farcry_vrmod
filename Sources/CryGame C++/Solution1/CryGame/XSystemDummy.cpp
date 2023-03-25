
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XSystemDummy.cpp
//  Description: Dummy implementation of the IXSystem interface.
//
//  History:
//  - August 8, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "XPlayer.h"
#include "XSystemDummy.h"

//////////////////////////////////////////////////////////////////////
CXSystemDummy::CXSystemDummy(CXGame *pGame,ILog *pLog):CXSystemBase(pGame,pLog)
{
	m_pEntitySystem->EnableClient(true);
}

//////////////////////////////////////////////////////////////////////
CXSystemDummy::~CXSystemDummy()
{
	DeleteAllEntities();
}

//////////////////////////////////////////////////////////////////////
void CXSystemDummy::Release()
{
	delete this;
}

//////////////////////////////////////////////////////////////////////
bool CXSystemDummy::LoadLevel(const char *szLevelDir,const char *szMissionName, bool bEditor)
{
	IInput *pInput=m_pGame->m_pSystem->GetIInput();

	if(pInput)						// might be 0, e.g. dedicated server
	{
		pInput->Update(true);
		pInput->Update(true);
	}

	IActionMapManager *pActionManager=m_pGame->m_pIActionMapManager;
	
	if(pActionManager)		// might be 0, e.g. dedicated server
		pActionManager->Reset();

	m_pGame->m_bMapLoadedFromCheckpoint=false;

	return true;
}

//////////////////////////////////////////////////////////////////////
IEntity*	CXSystemDummy::SpawnEntity(CEntityDesc &ed)
{
	return m_pEntitySystem->GetEntity((EntityId)ed.id);
}

//////////////////////////////////////////////////////////////////////
void CXSystemDummy::RemoveEntity(EntityId wID, bool bRemoveNow)
{
}

//////////////////////////////////////////////////////////////////////
void CXSystemDummy::DeleteAllEntities()
{
}

//////////////////////////////////////////////////////////////////////
void CXSystemDummy::Disconnected(const char *szCause)
{
	if(!szCause) szCause = "NULL ERROR";
	TRACE("Client Disconnected");
	TRACE(szCause);	
}

//////////////////////////////////////////////////////////////////////
void	CXSystemDummy::SetMyPlayer(EntityId wID)
{	
}