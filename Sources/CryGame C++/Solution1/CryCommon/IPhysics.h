
//////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: IPhysics.h
//  Description: Physics interface - duplicate. To be removed.
//
//	History:
//	- September 2001: File created by Anton Knyazyev
//	- February 2005: Modified by Marco Corbetta for SDK release	
//
//////////////////////////////////////////////////////////////////////

#ifndef cryphysics_h
#define cryphysics_h
#pragma once

#ifdef WIN32
	#ifdef PHYSICS_EXPORTS
		#define CRYPHYSICS_API __declspec(dllexport)
	#else
		#define CRYPHYSICS_API __declspec(dllimport)
	#endif
#else
	#define CRYPHYSICS_API
#endif
#define vector_class Vec3_tpl


#ifndef GAMECUBE
#include <CrySizer.h>
#endif

#include "Cry_Math.h"
#include "primitives.h"
#include "physinterface.h"

extern "C" CRYPHYSICS_API IPhysicalWorld *CreatePhysicalWorld(struct ISystem *pLog);

#endif