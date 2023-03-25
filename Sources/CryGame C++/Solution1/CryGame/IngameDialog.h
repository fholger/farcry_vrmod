
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: IngameDialog.h 
//  Description: Interface for the CIngameDialog class.
//
//  History:
//  - February 8, 2001: File created by Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_INGAMEDIALOG_H__F50111D1_2478_41B5_8AC5_5DD6A104BDEA__INCLUDED_)
#define AFX_INGAMEDIALOG_H__F50111D1_2478_41B5_8AC5_5DD6A104BDEA__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <string>

struct ISystem;
struct IFFont;
class CIngameDialogMgr;

//////////////////////////////////////////////////////////////////////
class CIngameDialog  
{
private:
	CIngameDialog();
	virtual ~CIngameDialog();
	bool Init(CIngameDialogMgr *pMgr, int nId, ISystem *pSystem, int nFillId, const char *pszFontName, const char *pszEffectName, int nSize, string sText,wstring swText, float fTimeout);
	void SetPos(float x, float y);
	float GetHeight() { return m_fH; }
	bool Update();
	friend class CIngameDialogMgr;

private:
	CIngameDialogMgr *m_pMgr;
	int m_nId;
	float m_fX;
	float m_fY;
	float m_fW;
	float m_fH;
	int m_nSize;
	string		m_sText;
	wstring	m_swText;
	IRenderer *m_pRenderer;
	IFFont *m_pFont;
	string m_sEffect;
	int m_nFillId;
	float m_fTimeout;
	bool m_bInited;
};

//////////////////////////////////////////////////////////////////////
struct SIGDId
{
	int nId;
	CIngameDialog *pDialog;
};

//////////////////////////////////////////////////////////////////////
class CIngameDialogMgr
{
private:
	int m_nDefaultFillId;
	int m_nNextId;
	IRenderer *m_pRenderer;
	ITimer *m_pTimer;
	std::list<SIGDId*> m_lstDialogs;

public:
	CIngameDialogMgr();
	~CIngameDialogMgr(); 
	int AddDialog(ISystem *pSystem, int nFillId, const char *pszFontName, const char *pszEffectName, int nSize, string sText, wstring swText, float fTimeout=0.0f);  // return id to dialog
	void RemoveDialog(int nId);
	void Update();
};

#endif // !defined(AFX_INGAMEDIALOG_H__F50111D1_2478_41B5_8AC5_5DD6A104BDEA__INCLUDED_)
