
////////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: ILipSynch.h
//  Description: Lip synch Interface.
//
//  History:
//  - Created by Lennert Schneider
//	- February 2005: Modified by Marco Corbetta for SDK release
//
////////////////////////////////////////////////////////////////////////////

#ifndef ILIPSYNC_H
#define ILIPSYNC_H

struct CryCharMorphParams;

////////////////////////////////////////////////////////////////////////////
// callback interfaces
struct IDialogLoadSink
{
	virtual void OnDialogLoaded(struct ILipSync *pLipSync)=0;
	virtual void OnDialogFailed(struct ILipSync *pLipSync)=0;
};

////////////////////////////////////////////////////////////////////////////
struct ILipSync
{
	// initializes and prepares the character for lip-synching
	virtual bool Init(ISystem *pSystem, IEntity *pEntity)=0;											
	// releases all resources and deletes itself
	virtual void Release()=0;																											
	// load expressions from script
	virtual bool LoadRandomExpressions(const char *pszExprScript, bool bRaiseError=true)=0;	
	// release expressions
	virtual bool UnloadRandomExpressions()=0;																			

	// loads a dialog for later playback
	virtual bool LoadDialog(const char *pszFilename, int nSoundVolume, float fMinSoundRadius, float fMaxSoundRadius, float fClipDist, int nSoundFlags=0,IScriptObject *pAITable=NULL)=0;														
	// releases all resources
	virtual bool UnloadDialog()=0;																								
	// plays a loaded dialog
	virtual bool PlayDialog(bool bUnloadWhenDone=true)=0;													
	// stops (aborts) a dialog
	virtual bool StopDialog()=0;																									
	// do a specific expression
	virtual bool DoExpression(const char *pszMorphTarget, CryCharMorphParams &MorphParams, bool bAnim=true)=0;	
	// stop animating the specified expression
	virtual bool StopExpression(const char *pszMorphTarget)=0;										
	// updates animation & stuff
	virtual bool Update(bool bAnimate=true)=0;																		
	// set callback sink (see above)
	virtual void SetCallbackSink(IDialogLoadSink *pSink)=0;												
};

#endif // ILIPSYNC_H