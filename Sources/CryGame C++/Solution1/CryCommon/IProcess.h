
//////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: IProcess.h
//	Description: Process common interface
//
//	History:
//	- September 03,2001:Created by Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release	
//
//////////////////////////////////////////////////////////////////////

#ifndef IPROCESS_H
#define IPROCESS_H

#if _MSC_VER > 1000
# pragma once
#endif

//////////////////////////////////////////////////////////////////////
struct IProcess
{
	virtual	bool	Init() = 0;	
	virtual void	Update() = 0;
	virtual void	Draw() = 0;
	virtual	void	ShutDown(bool bEditorMode=false) = 0;		
	virtual	void	SetFlags(int flags) = 0;
	virtual	int		GetFlags(void) = 0;
};

#endif