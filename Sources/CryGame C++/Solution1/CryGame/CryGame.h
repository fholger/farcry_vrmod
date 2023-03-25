
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: CryGame.h
//  Description: Defines the entry point for the DLL application.
//
//  History:
//  - February 8, 2001: File created by Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef __crygame_h__
#define __crygame_h__
#pragma once

#ifdef WIN32
	#ifdef CRYGAME_EXPORTS
		#define CRYGAME_API __declspec(dllexport)
	#else
		#define CRYGAME_API __declspec(dllimport)
	#endif
#else
	#define CRYGAME_API
#endif

#endif // __crygame_h__