
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: AIHAndler.h
//  Description: handeling AI signals, changing behaviors
//
//  History:
//  - Dec, 12, 2002: Created by Kirill Bulatsev
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#pragma once

#include <IAgent.h>
#include <ILipSync.h>

struct IScriptSystem;

//////////////////////////////////////////////////////////////////////
class CAIHandler : public IDialogLoadSink
{
public:
	CAIHandler(void);
	~CAIHandler(void);

	void	Init(CXGame *pGame, IEntity *pEntity, ILog *pLog);

	void	AIMind( SOBJECTSTATE *state );
	void	AISignal( int signalID, const char * signalText, IEntity *pSender );

	void	Release();
	void	DoReadibilityPack( const char* text );

protected:

	IScriptSystem*			m_pScriptSystem;
	IScriptObject*			m_pScriptObject;

	IEntity					*m_pEntity;
	CXGame					*m_pGame;
	ILog						*m_pLog;


	IScriptObject *m_pSoundPackTable;
	IScriptObject *m_pAnimationPackTable;

	
	string					m_NextBehaviorName;
	string					m_CurrentBehaviorName;
	string					m_DefaultBehaviorName;
	
	char m_szSignalName[1024];

	int		m_DamageGrenadeType;

	void	Release( IScriptObject **obj );
	bool	CheckCharacter( const char* signalText );
	void	DoChangeBehavior(  );
	bool	CallScript( IScriptObject *scriptTable, const char* funcName, float *value=NULL, IEntity *pSender=NULL );
	void	CallBehaviorOrDefault( const char* signalText, float *value=NULL,bool bJob = true );
	IScriptObject *GetMostLikelyTable( IScriptObject* table);
	IScriptObject *FindOrLoadTable( IScriptObject * table, const char* nameToGet );

public:
	void SetCurrentBehaviourVariable(const char * szVariableName, float fValue);
	void OnDialogLoaded(struct ILipSync *pLipSync);
	void OnDialogFailed(struct ILipSync *pLipSync);
	IScriptObject *m_pCharacter;
	IScriptObject *m_pDefaultCharacter;
	IScriptObject *m_pBehavior;
	IScriptObject *m_pPreviousBehavior;
	IScriptObject *m_pDefaultBehavior;
	IScriptObject *m_pDEFAULTDefaultBehavior;
	IScriptObject *m_pBehaviorTable;
	IScriptObject *m_pBehaviorTableAVAILABLE;
	IScriptObject *m_pBehaviorTableINTERNAL;

	string					m_FirstBehaviorName;
	
	void SetBehaviour( char *szBehaviourName) { m_NextBehaviorName = szBehaviourName; DoChangeBehavior();}
};
