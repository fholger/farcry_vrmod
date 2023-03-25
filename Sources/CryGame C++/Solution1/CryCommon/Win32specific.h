
//////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//	
//	File: Win32specific.h
//  Description: Specific to Win32 declarations, inline functions etc.
//
//	History:
//	- 31/03/2003:Created by Sergiy Migdalsky
//	- February 2005: Modified by Marco Corbetta for SDK release	
//
//////////////////////////////////////////////////////////////////////////

#ifndef _CRY_COMMON_WIN32_SPECIFIC_HDR_
#define _CRY_COMMON_WIN32_SPECIFIC_HDR_

#ifdef __cplusplus
#ifdef _DEBUG
#include <crtdbg.h>
#endif

//////////////////////////////////////////////////////////////////////////
// checks if the heap is valid in debug; in release, this function shouldn't be called
// returns non-0 if it's valid and 0 if not valid
inline int IsHeapValid ()
{
#if defined(_DEBUG) && !defined(RELEASE_RUNTIME)
	return _CrtCheckMemory();
#else
	return true;
#endif
}
#endif

typedef signed char         int8;
typedef signed short        int16;
typedef signed int					int32;
typedef signed __int64			int64;
typedef unsigned char				uint8;
typedef unsigned short			uint16;
typedef unsigned int				uint32;
typedef unsigned __int64		uint64;

typedef float               f32;
typedef double              f64;

// old-style (will be removed soon)
typedef signed char         s8;
typedef signed short        s16;
typedef signed int         s32;
typedef signed __int64			s64;
typedef unsigned char				u8;
typedef unsigned short			u16;
typedef unsigned int				u32;
typedef unsigned __int64		u64;

#endif //_CRY_COMMON_WIN32_SPECIFIC_HDR_