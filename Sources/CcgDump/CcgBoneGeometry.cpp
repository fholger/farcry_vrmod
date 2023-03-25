
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
#include "CcgBoneGeometry.h"
#include "CcgUtils.h"
#include "CcgBoneDescArray.h"

CCFBoneGeometry g_BG;
const char* g_pBGData = NULL;
extern CCFAnimGeomInfo g_GI;

const CCFBoneDescArrayHeader*g_pBoneDescArrayHeader = NULL;

using namespace CryStringUtils;

void printChunkBGBone (const char* pData, unsigned nSize)
{
	if (nSize < sizeof (CCFBGBone))
	{
		dumpError ("Truncated chunk");
		return;
	}

	const char* pDataEnd = pData + nSize;
	const CCFBGBone* pDesc = (const CCFBGBone*)pData;

	unsigned long i0 = pDesc->nBone;
	unsigned long i1 = g_arrBones.size();
	unsigned long i2 = pDesc->numVertices;
	unsigned long i3 = pDesc->numFaces;

	dump ("Bone %d \"%s\", %d verts, %d faces", pDesc->nBone, pDesc->nBone >= g_arrBones.size()?"#OUT OF RANGE#":g_arrBones[pDesc->nBone].getNameCStr(), pDesc->numVertices, pDesc->numFaces);



	if (pDesc->nBone > g_pBoneDescArrayHeader->numBones)
		dumpError ("Target Bone Out Of Range");

	if (pDesc->numVertices > 100000)
	{
		dumpError ("Number of vertices is too big. Malformed chunk.");
		return;
	}

	if (pDesc->numFaces > 100000)
	{
		dumpError("Number of faces is too big. Malformed chunk");
		return;
	}

	const Vec3d* pVertices = (const Vec3d*)(pDesc+1);
	const CCFIntFace* pFaces = (const CCFIntFace*)(pVertices+pDesc->numVertices);
	const unsigned char* pMaterials = (const unsigned char*)(pFaces+pDesc->numFaces);

	const char* pRequiredDataEnd = (const char*)(pMaterials + pDesc->numFaces);

	if (!validSize(nSize, pRequiredDataEnd-pData))
		return;

	std::set<unsigned> setUsedVerts;
	unsigned nFace, nVertex;
	for (nFace = 0; nFace < pDesc->numFaces; ++nFace)
		for (int j = 0; j < 3; ++j)
			setUsedVerts.insert (pFaces[nFace].v[j]);

	//if (!isFullRange(setUsedVerts, pDesc->numVertices))
		dumpPlus ("Used Vertices: %s", toString (setUsedVerts, "%u").c_str());

	std::set<unsigned> setUsedMtls;
	for (nFace = 0; nFace < pDesc->numFaces; ++nFace)
		setUsedMtls.insert (pMaterials[nFace]);
	dumpPlus (" Used Materials: %s", toString (setUsedMtls, "%u").c_str());

	Vec3d vMin, vMax;
	for (nVertex = 0; nVertex < pDesc->numVertices; ++nVertex)
	{
		if (!nVertex)
			vMin = vMax = pVertices[nVertex];
		else
		{
			vMin.CheckMin(pVertices[nVertex]);
			vMax.CheckMax(pVertices[nVertex]);
		}
	}
	dump (" BBox: {%g .. %g, %g .. %g, %g .. %g}", vMin.x, vMax.x, vMin.y, vMax.y, vMin.z, vMax.z);
}


void printChunkBG (CCFChunkTypeEnum nType, const char* pData, unsigned nSize)
{
	dump ("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	dump ("%s (#%d), Data Size: 0x%04X(%d) bytes, Data BG Chunk Offset: 0x%05X, Data FilePos: 0x%05X",
		getChunkName(nType), nType, nSize, nSize, pData - g_pBGData, pData-g_pFileData);


	switch (nType)
	{
	case CCF_BG_BONE:
    printChunkBGBone (pData, nSize);
		break;

	default:
		dumpError ("UNEXPECTED CHUNK");
		break;
	}
}

void printChunkBoneGeometry (const char* pData, unsigned nSize)
{
	AUTO_DUMP_LEVEL("|");
	if (nSize < sizeof(CCFBoneGeometry))
	{
		dumpError ("BG chunk is truncated");
		return;
	}

	g_BG = *(const CCFBoneGeometry*)pData;
	g_pBGData = pData + sizeof(CCFBoneGeometry);
	dump ("%d bones reported", g_BG.numBGBones);

	const char* pDataEnd = pData + nSize;
	const char* pParsedDataEnd = g_pBGData;

	for (CCFMemReader Reader (g_pBGData, pDataEnd-g_pBGData); !Reader.IsEnd(); Reader.Skip())
	{
		assert ((const char*)Reader.GetData() + Reader.GetDataSize() <= pDataEnd);

		printChunkBG (Reader.GetChunkType(), (const char*) Reader.GetData(), Reader.GetDataSize());
		pParsedDataEnd = (const char*)Reader.GetData() + Reader.GetDataSize();
	}


	if (pParsedDataEnd != pDataEnd)
	{
		dumpError ("Malformed BG chunk data: cannot parse subchunks beyond data offset 0x%X (FilePos 0x%05X)",
			pParsedDataEnd - g_pBGData, pParsedDataEnd - g_pFileData); 
	}
}