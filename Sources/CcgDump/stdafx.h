
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

#define WIN32_LEAN_AND_MEAN		// Exclude rarely-used stuff from Windows headers
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <set>
#include <map>
#include <string>
#include <algorithm>
#include <assert.h>
#include <math.h>

#include <smartptr.h>

#include <Cry_Math.h>
#include <Cry_Matrix.h>
#include <CryHeaders.h>
#include <CryCompiledFile.h>
#include <IRenderer.h>
#include <LeafBuffer.h>
#include <IMiniLog.h>

// stencil shadow connectivity requires:
#include "Tarrays.h"
#include "CrySizer.h"

#include <primitives.h>
#include <physinterface.h>
#ifndef SIZEOF_ARRAY
#define SIZEOF_ARRAY(arr) (sizeof(arr)/sizeof((arr)[0]))
#endif
#include "CcgDump.h"
// TODO: reference additional headers your program requires here
