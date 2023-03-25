
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: UICheckBox.h  
//  Description: UI CheckBox control
//
//  History:
//  - [9/7/2003]: File created by Márcio Martins
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#pragma once

#define UICLASSNAME_CHECKBOX			"UICheckBox"
#include "UIWidget.h"
#include "UISystem.h"

class CUISystem;

//////////////////////////////////////////////////////////////////////////
class CUICheckBox : public CUIWidget,
	public _ScriptableEx<CUICheckBox>
{
	UI_WIDGET(CUICheckBox)

public:
	CUICheckBox();
	~CUICheckBox();

	string GetClassName();

	LRESULT Update(unsigned int iMessage, WPARAM wParam, LPARAM lParam);	//AMD Port
	int Draw(int iPass);

	static void InitializeTemplate(IScriptSystem *pScriptSystem);

	int SetText(const wstring &szwString);

	////////////////////////////////////////////////////////////////////// 
	// Script Functions
	//////////////////////////////////////////////////////////////////////

	int SetText(IFunctionHandler *pH);
	int GetText(IFunctionHandler *pH);

	int SetTexture(IFunctionHandler *pH);
	int GetTexture(IFunctionHandler *pH);

	int SetChecked(IFunctionHandler *pH);
	int GetChecked(IFunctionHandler *pH);

private:

	UIRect GetBorderedRect();

	float						m_fLeftSpacing;
	float						m_fRightSpacing;
	int							m_iVAlignment;
	int							m_iHAlignment;

	color4f		m_cCheckColor;

	UISkinTexture		m_pTexture;
	wstring		m_szText;
	int							m_iState;
};