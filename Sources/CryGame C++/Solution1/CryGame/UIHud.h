
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//	
//  File: UIHUD.h  
//  Description: Player Hud.
//
//	History:
//	- June 03,2001: Created by Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef CRYTEK_UIHUD_H
#define CRYTEK_UIHUD_H

#include "IFont.h"
struct IScriptSystem;
struct IScriptObject;

//////////////////////////////////////////////////////////////////////
class CUIHud 
{
public:	
	CUIHud(CXGame *pGame,ISystem *pISystem);
	~CUIHud();

	bool Reset();
	bool Init(IScriptSystem *pScriptSystem);	
	bool Update();
	void ShutDown();	

	void SetFont(const char *pszFontName, const char *pszEffectName);
	void WriteNumber(int px,int py,int number,float r,float g,float b,float a,float xsize/*=1*/,float ysize/*=1*/);
	void WriteString(int px, int py, const wchar_t *swStr, float r, float g, float b, float a,float xsize/* =1 */, float ysize/* =1 */, float fWrapWidth);
	void WriteStringFixed(int px, int py, const wchar_t *swStr, float r, float g, float b, float a,float xsize/* =1 */, float ysize/* =1 */, float fWidthScale);
	IScriptObject *GetScript() { return(m_pHudScriptObj); } 
	IFFont *Getfont() { return(m_pFont); }

private:
	int GetHudTable() const;
	IScriptSystem *m_pScriptSystem;
	IScriptObject *m_pHudScriptObj;
	ISystem *m_pISystem;
	CXGame *m_pGame;
	bool m_init;
	IFFont *m_pFont;
};

#endif // CRYTEK_UIHUD_H
