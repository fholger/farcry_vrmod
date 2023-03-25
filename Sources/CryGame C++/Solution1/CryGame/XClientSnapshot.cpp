
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XClientSnapshot.cpp
//  Description: Snapshot manager class.
//
//  History:
//  - August 14, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "XClientSnapshot.h"
#include "Stream.h"

//////////////////////////////////////////////////////////////////////
CXClientSnapshot::CXClientSnapshot()
{
	sv_maxcmdrate = GetISystem()->GetIConsole()->GetCVar("sv_maxcmdrate");

	Reset();
	SetSendPerSecond(0);
}

//////////////////////////////////////////////////////////////////////
CXClientSnapshot::~CXClientSnapshot()
{
}

//////////////////////////////////////////////////////////////////////
bool CXClientSnapshot::IsTimeToSend(float fFrameTimeInSec)
{
	int iServerMax = sv_maxcmdrate->GetIVal();
	int iSendPerSecond = min(iServerMax,(int)m_cSendPerSecond);

	unsigned int	nTimeToUpdate = 1000/iSendPerSecond;

	m_nTimer += (unsigned int)(fFrameTimeInSec*1000.0f);
	
	if(m_nTimer >= nTimeToUpdate)
		return true;

	return false;
}

//////////////////////////////////////////////////////////////////////
void CXClientSnapshot::Reset()
{
	m_ReliableStream.Reset();
	m_UnreliableStream.Reset();
	m_nTimer = 0;
}

//////////////////////////////////////////////////////////////////////
void CXClientSnapshot::SetSendPerSecond(BYTE cSendPerSecond)
{
	m_cSendPerSecond = cSendPerSecond?cSendPerSecond:25;
}

