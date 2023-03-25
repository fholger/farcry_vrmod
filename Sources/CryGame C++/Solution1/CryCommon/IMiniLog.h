
////////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File:   IMiniLog.h
//  Description: This is the smallest possible interface to the Log - 
//               it's independent and small, so that it can be easily moved
//               across the engine and test applications, to test engine
//               parts that need logging (e.g. Streaming Engine) separately
//
//  History:
//	- 03/6/2003: Created by Sergiy Migdalsky
//	- February 2005: Modified by Marco Corbetta for SDK release
//									
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
#ifndef _CRY_ENGINE_MINI_LOG_HDR_
#define _CRY_ENGINE_MINI_LOG_HDR_

#include <stdarg.h>

////////////////////////////////////////////////////////////////////////////
struct IMiniLog
{
	enum ELogType
	{
		eMessage,
		eWarning,
		eError,
		eAlways,
		eWarningAlways,
		eErrorAlways,
		eInput,
	};

	//! you only have to implement this function
	virtual void LogV (const ELogType nType, const char* szFormat, va_list args) = 0;
	
	//! destructor
	virtual ~IMiniLog() {}

	//! this is the simplest log function for messages
	//! with the default implementation
	virtual void Log(const char * szFormat,...)
	{
		va_list args;
		va_start(args,szFormat);
		LogV (eMessage, szFormat, args);
		va_end(args);
	}

	//! this is the simplest log function for warnings
	//! with the default implementation
	virtual void LogWarning(const char * szFormat,...)
	{
		va_list args;
		va_start(args,szFormat);
		LogV (eWarning, szFormat, args);
		va_end(args);
	}

	//! this is the simplest log function for errors
	//! with the default implementation
	virtual void LogError(const char * szFormat,...)
	{
		va_list args;
		va_start(args,szFormat);
		LogV (eError, szFormat, args);
		va_end(args);
	}
};

////////////////////////////////////////////////////////////////////////////
// By default, to make it possible not to implement the log at the beginning at all,
// empty implementations of the two functions are given
struct CNullMiniLog: public IMiniLog
{
	// the default implementation just won't do anything
	void LogV(const char* szFormat, va_list args) {}
};

#endif //_CRY_ENGINE_MINI_LOG_HDR_
