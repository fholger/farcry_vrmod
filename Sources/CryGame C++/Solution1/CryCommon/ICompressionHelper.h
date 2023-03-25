
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: ICompressionHelper.h
//	Description:
//		Interface for bit stream compression helper. See IBitStream.h
//
//	History:
//	-	September 2002: File created
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef __ICompressionHelper_h__
#define __ICompressionHelper_h__

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CStream;

//////////////////////////////////////////////////////////////////////
struct ICompressionHelper
{
	//!
	virtual bool Write( CStream &outStream, const unsigned char inChar )=0;
	//!
	virtual bool Read( CStream &inStream, unsigned char &outChar )=0;
	//!
	virtual bool Write( CStream &outStream, const char *inszString )=0;
	//!
	virtual bool Read( CStream &inStream, char *outszString, const DWORD indwStringSize )=0;
};

#endif // __ICompressionHelper_h__
