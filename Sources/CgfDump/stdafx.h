
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
// 
//	File: 
//
//  Description:  
//
//	History:
//
//////////////////////////////////////////////////////////////////////

// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#include <platform.h>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <set>
#include <map>
#include <string>
#include <algorithm>
#include <assert.h>
#include <math.h>
#ifndef max
#define max(a,b) (((a) > (b)) ? (a) : (b))
#endif
#include <smartptr.h>
#include "CryHeaders.h"

//#include "CryCompiledFile.h"

#define cry std
#define CRY_AS_STD

#ifndef M_PI
#define	M_PI		3.14159265358979323846	/* pi */
#endif

#define JNT_XACTIVE		(1<<0)
#define JNT_YACTIVE		(1<<1)
#define JNT_ZACTIVE		(1<<2)
#define JNT_XLIMITED	(1<<3)
#define JNT_YLIMITED	(1<<4)
#define JNT_ZLIMITED	(1<<5)
#define JNT_XEASE		(1<<6)
#define JNT_YEASE		(1<<7)
#define JNT_ZEASE		(1<<8)
#define JNT_XSPRING		(1<<9)
#define JNT_YSPRING		(1<<10)
#define JNT_ZSPRING		(1<<11)

#define JNT_PARAMS2		(1<<12) // If this bit is set, the structure is a JointParams2

#define JP_HELD			(1<<27)
#define JNT_LIMITEXACT	(1<<28)
#define JNT_ROLLOPEN	(1<<29)
#define JNT_ROT			(1<<30) 
#define JNT_POS			(1<<31)

//! Everybody should use fxopen instead of fopen
//! so it will work both on PC and XBox
inline FILE * fxopen(const char *szFile, const char *mode)
{
	return fopen (szFile, mode);
}