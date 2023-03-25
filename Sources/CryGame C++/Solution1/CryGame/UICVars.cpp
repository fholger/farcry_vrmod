
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: UICVars.cpp  
//  Description: UI CVars
//
//  History:
//  - [4/7/2003]: File created by Márcio Martins
//	- February 2005: Modified by Marco Corbetta for SDK release
//	- October 2006: Modified by Marco Corbetta for SDK 1.4 release
//
//////////////////////////////////////////////////////////////////////

#include "StdAfx.h"
#include "UISystem.h"
#include "UICVars.h"


//////////////////////////////////////////////////////////////////////////
// CVar definition
//////////////////////////////////////////////////////////////////////////

ICVar *ui_BackGroundVideo = 0;
ICVar *ui_TriggerUIEvents = 0;
ICVar *ui_TriggerWidgetEvents = 0;
ICVar *ui_RepeatDelay = 0;
ICVar *ui_RepeatSpeed = 0;
ICVar *ui_ToolTipDelay = 0;
ICVar *ui_EasyToolTip = 0;
ICVar *ui_ToolTips = 0;


////////////////////////////////////////////////////////////////////////// 
int CUISystem::CreateCVars()
{
	IConsole *pConsole = m_pSystem->GetIConsole();

	ui_BackGroundVideo = pConsole->CreateVariable("ui_BackGroundVideo", "1", VF_DUMPTODISK, "Enable/Disable Background video playback. [1 = on / 0 = off]");
	ui_TriggerUIEvents = pConsole->CreateVariable("ui_TriggerUIEvents", "1", VF_DUMPTODISK, "Enable/Disable UI event triggers! [1 = on / 2 = off]\nDefault is 1!");
	ui_TriggerWidgetEvents = pConsole->CreateVariable("ui_TriggerWidgetEvents", "1", VF_DUMPTODISK, "Enable/Disable Widget event triggers! [1 = on / 2 = off]\nDefault is 1!");
	ui_RepeatDelay = pConsole->CreateVariable("ui_RepeatDelay", "200", VF_DUMPTODISK|VF_CHEAT, "Set the timer to trigger the key repeat, in miliseconds!");
	ui_RepeatSpeed = pConsole->CreateVariable("ui_RepeatSpeed", "40", VF_DUMPTODISK|VF_CHEAT, "Set the key repeat speed, in key/second!");
	ui_ToolTipDelay = pConsole->CreateVariable("ui_ToolTipDelay", "1500", VF_DUMPTODISK, "Set the delay before a tooltip appears, in miliseconds!");
	ui_EasyToolTip = pConsole->CreateVariable("ui_EasyToolTip", "0", VF_DUMPTODISK, "Enable/Disable easy tooltips. [1 = on / 2 = off]\nEasy tooltips, don't require the mouse to be still.");
	ui_ToolTips = pConsole->CreateVariable("ui_ToolTips", "1", VF_DUMPTODISK, "Enable/Disable tooltips. [1 = on / 2 = off]");	

	return 1;
}

////////////////////////////////////////////////////////////////////////// 
int CUISystem::ReleaseCVars()
{
	ui_TriggerUIEvents->Release();
	ui_TriggerWidgetEvents->Release();
	ui_RepeatDelay->Release();
	ui_RepeatSpeed->Release();
	ui_ToolTipDelay->Release();
	ui_EasyToolTip->Release();
	ui_ToolTips->Release();

	return 1;
}
