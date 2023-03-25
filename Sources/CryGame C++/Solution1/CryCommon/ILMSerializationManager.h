
////////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File:   ILMSerializationManager.h
//  Description: LightMap Serialization interface
//
//  History:
//	- 02/07/2003: Sergiy Migdlasky extracted declaration from I3dEngine.h 
//									to be able to easy modify it
//	- February 2005: Modified by Marco Corbetta for SDK release
//
////////////////////////////////////////////////////////////////////////////

#ifndef _CRY_COMMON_LM_SERIALIZATION_MANAGER_HDR_
#define _CRY_COMMON_LM_SERIALIZATION_MANAGER_HDR_

#include <IEntitySystem.h>

////////////////////////////////////////////////////////////////////////////
//! \short Interface for lightmap serialization
struct ILMSerializationManager
{
	virtual void Release() = 0;

	//!
	virtual bool ApplyLightmapfile( const char *pszFileName, std::vector<struct IEntityRender *>& vIGLMs ) = 0;
	//!

	virtual bool Load( const char *pszFileName, const bool cbNoTextures ) = 0;

	//!
	virtual unsigned int Save( const char *pszFileName, struct LMGenParam sParams, const bool cbAppend = false ) = 0;
	//!
	//! /param _pColorLerp4 if !=0 this memory is copied
	//! /param _pDomDirection3 if !=0 this memory is copied
	virtual void AddRawLMData( 
		const DWORD indwWidth, const DWORD indwHeight, const std::vector<int>& _cGLM_IDs_UsingPatch,
		BYTE *_pColorLerp4, BYTE *_pHDRColorLerp4, BYTE *_pDomDirection3, BYTE *_pOccl2) = 0;
	//!
	virtual void AddTexCoordData( const std::vector<struct TexCoord2Comp>& vTexCoords, int iGLM_ID_UsingTexCoord, const DWORD indwHashValue, const std::vector<std::pair<EntityId, EntityId> >& rOcclIDs) = 0;

	//! for rebuild changes feature
	//! /return 0x12341234 if this object wasn't in the list
	virtual DWORD GetHashValue( const int iniGLM_ID_UsingTexCoord ) const=0;

	//! Create a dot3 lightmap ColorLerp / DomDirection tetxure pair
	virtual RenderLMData * CreateLightmap(const char *pszFileName, int nItem, UINT iWidth, UINT iHeight, BYTE *pColorLerp4, BYTE *pHDRColorLerp4, BYTE *pDomDirection3, BYTE *pOccl2 = 0)=0;

	virtual bool ExportDLights(const char *pszFileName, const CDLight **ppLights, UINT iNumLights, bool bNewZip = true) const = 0;
};

#endif