
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XObjectProxy.h
//  Description: Class handeling AI signals, changing behaviors
//
//  History:
//  - Dec, 12, 2002: Created by Kirill Bulatsev
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#pragma once
#include <iagent.h>

//////////////////////////////////////////////////////////////////////
class CXObjectProxy :	public IUnknownProxy
{

	IEntity *m_pEntity;
	IScriptSystem *m_pScriptSystem;
	IPhysicalEntity* GetPhysics() { return NULL; }
	CPlayer *m_pPlayer;


public:
	CXObjectProxy(IEntity *pEntity, IScriptSystem *pSystem);
	~CXObjectProxy(void);
	
	// Sets the name of the function that will be called when an incoming signal is intercepted
	void SetSignalFuncName(const char * szName);
	int Update(SOBJECTSTATE * state);
	void SendSignal(SOBJECTSTATE * pState);
	void Release() {delete this;	}
	bool CustomUpdate(Vec3d& pos, Vec3d& angle);
	void ApplyHealth(float fHealth) {};

	bool QueryProxy(unsigned char type, void ** pProxy) {return false;}
	void DebugDraw(struct IRenderer * pRenderer);

	bool CheckStatus(unsigned char status) { return false; }
	void Save(CStream &str){}
	void Load(CStream &str){}
	void Load_PATCH_1(CStream &str){ }
};
