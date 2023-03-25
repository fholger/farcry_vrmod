
//////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: IStreamPersist.h
//  Description: IStreamPersist interface.
//
//  History:
//  - August 6, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release	
//
//////////////////////////////////////////////////////////////////////////

#ifndef GAME_ISTREAMPERSIST_H
#define GAME_ISTREAMPERSIST_H
#if _MSC_VER > 1000
# pragma once
#endif

struct IScriptObject;
class CStream;

//////////////////////////////////////////////////////////////////////////
enum DirtyFlags 
{
		DIRTY_NAME		= 0x1,
		DIRTY_POS			= 0x2,
		DIRTY_ANGLES	= 0x4,
};

//////////////////////////////////////////////////////////////////////////
/*! This interface must be implemented by all objects that must be serialized
	through the network or file.
	
	REMARKS: The main purpose of the serialization is reproduce the game remotely
		or saving and restoring.This mean that the object must not save everything
		but only what really need to be restored correctly.
*/
struct IStreamPersist
{
	/*!	serialize the object to a bitstream(network)
		@param stm the stream class that will store the bitstream
		@return true if succeded,false failed
		@see CStream
	*/
	virtual bool Write(CStream&) = 0;
	/*!	read the object from a stream(network)
		@param stm the stream class that store the bitstream
		@return true if succeded,false failed
		@see CStream
	*/
	virtual bool Read(CStream&) = 0;
	/*! check if the object must be syncronized since the last serialization
		@return true must be serialized, false the object didn't change
	*/
	virtual bool IsDirty() = 0;

	/*!	serialize the object to a bitstream(file persistence)
		@param stm the stream class that will store the bitstream
		@param pStream script wrapper for the stream(optional)
		@return true if succeded,false failed
		@see CStream
	*/
	virtual bool Save(CStream &stm) = 0;
	/*!	read the object from a stream(file persistence)
		@param stm the stream class that store the bitstream
		@param pStream script wrapper for the stream(optional)
		@return true if succeded,false failed
		@see CStream
	*/
	virtual bool Load(CStream &stm,IScriptObject *pStream=NULL) = 0;
};

#endif // GAME_ISTREAMPERSIST_H
