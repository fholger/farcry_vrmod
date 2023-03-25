
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
#include "CcgMorphTargetSet.h"
#include "CrySkinMorph.h"
#include "StringUtils.h"

using namespace CryStringUtils;

const CCFMorphTargetSet* g_pMorphTargetSet = NULL;
const char* g_pMTSData = NULL;
unsigned g_numMorphTargets = 0;


void printChunkMorphTarget (const char* pData, unsigned nSize)
{
	if (nSize < sizeof(CCFMorphTarget))
	{
		dumpError ("Truncated chunk header");
		return;
	}

	CCFMorphTarget* pHeader = (CCFMorphTarget*)pData;

	if (pHeader->numLODs != 1)
	{
		dumpError ("Unsupported number of LODs: %d", pHeader->numLODs);
		return;
	}

	const char* pRawData = (const char*)(pHeader+1);
	const char* pDataEnd = pData + nSize;

	// read the morph skin
	CrySkinMorph MorphSkin;
	unsigned numReadBytes = MorphSkin.Serialize_PC(false, (void*)pRawData, pDataEnd-pRawData);
	if (!numReadBytes)
	{
		dumpError ("Cannot read the morph skin");
		return;
	}

	// we align the serialized data by 4 bytes
	pRawData += (numReadBytes + 3) & ~3;

	// the name follows
	std::string strName (pRawData);
	if (pDataEnd[-1] != '\0')
		dumpError ("Name string is not 0-terminated");

	pRawData += (strName.length()+4)&~3;
	if (pDataEnd > pRawData)
		dumpWarning ("Extra raw data is found, %d bytes", pDataEnd - pRawData);

	CrySkinMorph::CStatistics stat (&MorphSkin);

	dump ("\"%s\" %d LOD", strName.c_str(), pHeader->numLODs);
	dump ("  Bones [%d..%d) verts:%d (%d rigid, %d smooth), auxInts:%d", stat.numSkipBones, stat.numBones, stat.numVertices, stat.numRigid, stat.numSmooth, stat.numAuxInts);
	dump ("  Offsets [%.4f..%.4f] for destination vertices %s", stat.fMinOffset, stat.fMaxOffset, toString (stat.setDests, "%u").c_str());
}



void printChunkMTS (CCFChunkTypeEnum nType, const char* pData, unsigned nSize)
{
	dump ("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	dump ("%s (#%d), Data Size: 0x%04X(%d) bytes, Data MTS Chunk Offset: 0x%05X, Data FilePos: 0x%05X",
		getChunkName(nType), nType, nSize, nSize, pData - g_pMTSData, pData-g_pFileData);

	switch (nType)
	{
	case CCF_MORPH_TARGET:
		printChunkMorphTarget (pData, nSize);
		++g_numMorphTargets;
		break;

	default:
		dumpError ("UNEXPECTED CHUNK");
		break;
	}
}


void printChunkMorphTargetSet (const char* pData, unsigned nSize)
{
	AUTO_DUMP_LEVEL("|");
	if (nSize < sizeof(CCFMorphTargetSet))
	{
		dumpError ("MTS chunk is truncated");
		return;
	}

	g_pMorphTargetSet = (const CCFMorphTargetSet*)pData;
	g_pMTSData = pData + sizeof(CCFBoneGeometry);
	dump ("%d Morph Targets declared", g_pMorphTargetSet->numMorphTargets);

	const char* pDataEnd = pData + nSize;
	const char* pParsedDataEnd = g_pMTSData;

	g_numMorphTargets = 0;
	for (CCFMemReader Reader (g_pMTSData, pDataEnd-g_pMTSData); !Reader.IsEnd(); Reader.Skip())
	{
		assert ((const char*)Reader.GetData() + Reader.GetDataSize() <= pDataEnd);
		printChunkMTS (Reader.GetChunkType(), (const char*) Reader.GetData(), Reader.GetDataSize());
		pParsedDataEnd = (const char*)Reader.GetData() + Reader.GetDataSize();
	}

	if (pParsedDataEnd != pDataEnd)
	{
		dumpError ("Malformed MTS chunk data: cannot parse subchunks beyond data offset 0x%X (FilePos 0x%05X)",
			pParsedDataEnd - g_pMTSData, pParsedDataEnd - g_pFileData); 
	}

	if (g_numMorphTargets != g_pMorphTargetSet->numMorphTargets)
		dumpError ("%d morph target%s found instead of declared %d", g_numMorphTargets,g_numMorphTargets!=1?"s":"", g_pMorphTargetSet->numMorphTargets);

}