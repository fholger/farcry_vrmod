
//////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: CryPhysics.h
//  Description: Physics interface.
//
//	History:
//	- September 2001: File created by Anton Knyazyev
//	- February 2005: Modified by Marco Corbetta for SDK release	
//
//////////////////////////////////////////////////////////////////////

#ifndef cryphysics_h
#define cryphysics_h
#pragma once

#ifndef _XBOX
	#ifdef PHYSICS_EXPORTS
		#define CRYPHYSICS_API __declspec(dllexport)
	#else
		#define CRYPHYSICS_API __declspec(dllimport)
		#define vector_class Vec3d
	#endif
#else
	#define CRYPHYSICS_API
#endif

#include "utils.h"
#include "primitives.h"
#include "physinterface.h"

extern "C" CRYPHYSICS_API IPhysicalWorld *CreatePhysicalWorld();

#endif