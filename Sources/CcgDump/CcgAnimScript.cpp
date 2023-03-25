
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

#include "stdafx.h"
#include "StringUtils.h"
#include "CcgAnimScript.h"
#include "CcgUtils.h"
#include "Controller.h"
extern unsigned g_nFrameID;
#include "ICryAnimation.h"
#include "CryAnimationInfo.h"



void printChunkDummyAnim (const void* pData, unsigned nSize)
{
	std::string strName ((const char*)pData, nSize);
	if (g_bDumpAnims)
		dump ("%s = ? (dummy)", strName.c_str());
	if (strName.length() >= nSize)
		dumpError ("Invalid name: no terminator");
}


void printChunkModelOffset (const void* pData, unsigned nSize)
{
	if (nSize != sizeof(Vec3d))
		dumpError ("Invalid chunk size %d", nSize);
	else
	{
		const Vec3d& v = *(const Vec3d*)pData;
		dump ("$ModelOffset = {%g,%g,%g}", v.x, v.y, v.z);
	}
}

void printChunkAnimDir (const void* pData, unsigned nSize)
{
	dump ("$AnimDir %s", pData);
}

static unsigned nMaxNameLen, nMaxPathLen, numAnims;

void preChunkAnimInfo(const void* pData, unsigned nSize)
{
	const CCFAnimInfo* pAnim = (const CCFAnimInfo*)pData;
	const char* pName = (const char*)(pAnim+1);
	const char* pFile = pName + strlen(pName) + 1;
	nMaxNameLen = max((unsigned)strlen(pName), nMaxNameLen);
	nMaxPathLen = max((unsigned)strlen(pFile), nMaxNameLen);
}

void printChunkAnimInfo (const void* pData, unsigned nSize)
{
	if (nSize < sizeof(CCFAnimInfo) + 2)
	{
		dumpError ("Truncated chunk (size %d)", nSize);
		return;
	}

	if (!g_bDumpAnims)
		return;

	const CCFAnimInfo* pAnim = (const CCFAnimInfo*)pData;

	// the name/path

	const char* pName = (const char*)(pAnim+1);
	const char* pFile = pName + strlen(pName) + 1;
	dumpPlus ("%-*s = %-*s", nMaxNameLen + 1, pName, nMaxPathLen+1,pFile);

	dumpPlus (" [%5.3f..%5.3f] secs; ", pAnim->fSecsPerTick*pAnim->nRangeStart, pAnim->fSecsPerTick*pAnim->nRangeEnd);

	if (pAnim->nAnimFlags & GlobalAnimation::FLAGS_DISABLE_AUTO_UNLOAD)
		dumpPlus("Dont Unload. ");

	if (pAnim->nAnimFlags & GlobalAnimation::FLAGS_DISABLE_DELAY_LOAD)
		dumpPlus("Load immediately. ");

	if (pAnim->nAnimFlags & GlobalAnimation::FLAGS_DISABLE_LOAD_ERROR_LOG)
		dumpPlus("NoError. ");
	if (pAnim->nAnimFlags & GlobalAnimation::FLAGS_INFO_LOADED)
		dumpPlus("FLAGS_INFO_LOADED ");
	if (pAnim->nAnimFlags & GlobalAnimation::FLAGS_LOAD_PENDING)
		dumpPlus("FLAGS_LOAD_PENDING ");
	if (pAnim->nAnimFlags & ~GlobalAnimation::FLAGS_ALL_FLAGS)
		dumpPlus("Unknown: 0x%08X. ", pAnim->nAnimFlags);

	if (fabs(pAnim->fSecsPerTick - 0.000208f) < 1e-6 && pAnim->nTicksPerFrame == 160)
		dumpPlus ("Std ");
	else
		dumpPlus ("%.3f ms/tick, %d ticks/frame", pAnim->fSecsPerTick*1000, pAnim->nTicksPerFrame);
	
	dump("");
}


void printChunkAnimScript (const void* pData, unsigned nSize)
{
	nMaxNameLen = nMaxPathLen = numAnims = 0;

	{
		for (CCFMemReader Reader (pData, nSize); !Reader.IsEnd(); Reader.Skip())
			switch (Reader.GetChunkType())
		{
			case CCF_ANIM_SCRIPT_ANIMINFO:
				preChunkAnimInfo(Reader.GetData(), Reader.GetDataSize());
				break;
		}
	}

	for (CCFMemReader Reader (pData, nSize); !Reader.IsEnd(); Reader.Skip())
		switch (Reader.GetChunkType())
		{
		case CCF_ANIM_SCRIPT_DUMMYANIM:
			printChunkDummyAnim(Reader.GetData(), Reader.GetDataSize());
			break;

		case CCF_ANIM_SCRIPT_MODELOFFSET:
			printChunkModelOffset (Reader.GetData(), Reader.GetDataSize());
			break;
			
		case CCF_ANIM_SCRIPT_ANIMINFO:
			printChunkAnimInfo (Reader.GetData(), Reader.GetDataSize());
			break;

		case CCF_ANIM_SCRIPT_ANIMDIR:
			printChunkAnimDir (Reader.GetData(), Reader.GetDataSize());
			break;

		default:
			dumpError ("Unknown chunk");
			break;
		}
}