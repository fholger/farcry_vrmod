
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
#include "CcgGeometryInfo.h"
#include "CcgUtils.h"
#include "CgfUtils.h"
#include "StringUtils.h"

#include "StencilShadowConnectivity.h"
#include "CrySkinFull.h"
#include "CryBoneDesc.h"
#include "CrySkinRigidBasis.h"
#include "CgfUtils.h"
#include "CcgUtils.h"
#include "CcgGeometryInfo.h"

CCFAnimGeomInfo g_GI;

bool isGIFullVertexRange (const std::set<unsigned>& setVerts)
{
	return isFullRange (setVerts, g_GI.numVertices);
}

bool isGIFullExtTangRange (const std::set<unsigned>& setTangs)
{
	return isFullRange(setTangs, g_GI.numExtTangents);
}


const char* g_pGIData = NULL;

// the faces inside this GI
const CCFIntFace* g_pGIFaces;
// the indices
const unsigned short* g_pGIIndices;
const unsigned short* g_pGIExtToInt;

extern void printChunkStencilShadowConnectivity (const char* pData, unsigned nSize);
extern void printChunkVertices (const char* pData, unsigned nSize);
extern void printChunkSkinVertices(const char* pData, unsigned nSize);
extern void printChunkSkinNormals (const char* pData, unsigned nSize);
extern void printChunkSkinTangents (const char* pData, unsigned nSize);
extern void printChunkGIIntFaces (const char* pData, unsigned nSize);

extern void printGIFaceSummary();

using namespace CryStringUtils;




void printChunkGIIntColors (const char* pData, unsigned nSize)
{
	if (!validArrSize<DWORD>(nSize, g_GI.numVertices))
		return ;

	if (g_bDumpMeshVertCols)
	{
		for (unsigned i = 0; i < g_GI.numVertices; ++i)
			dump("\t% 4d  (% 3u,% 3u,% 3u; % 3u)", i, (unsigned)pData[i*4], (unsigned)pData[i*4+1], (unsigned)pData[i*4+2], (unsigned)pData[i*4+3]);
	}
}

void printChunkGIExtTangents (const char* pData, unsigned nSize)
{
	if (!validArrSize<TangData> (nSize, g_GI.numExtTangents))
		return;

	const TangData* pTang = (const TangData*)pData;

	unsigned numLeftHanded = 0, numDegraded = 0, numNonUnit = 0, numNonOrthogonal = 0;

	for (unsigned i = 0; i < g_GI.numExtTangents; ++i)
	{
		SBasisProperties Prop (pTang[i]);
		if (Prop.bMatrixDegraded)
			++numDegraded;
		else
		{
			if (Prop.bLeftHanded)
				++numLeftHanded;
			if (!Prop.isOrthogonal())
				++numNonOrthogonal;
			if (!isUnit(pTang[i],1e-3f))
				++numNonUnit;
		}
	}

	if (numDegraded)
		dumpWarning ("%u Degraded tangent bases found", numDegraded);

	if (numNonOrthogonal)
		dumpWarning("%u non-orthogonal tangent bases found", numNonOrthogonal);

	if (numNonUnit)
		dumpWarning("%u non-unit tangent bases found", numNonUnit);

	if (numLeftHanded)
	{
		if (numLeftHanded == g_GI.numExtTangents)
			dump ("ALL Left-Handed");
		else
			dump ("%u Left-Handed", numLeftHanded);
	}

	if (numLeftHanded == 0 && numDegraded == 0 && numNonUnit == 0 && numNonOrthogonal == 0)
		dump ("ALL are right-handed, orthounitary");
}


void printChunkGIExtToIntMap (const char* pData, unsigned nSize)
{
	if (!validArrSize<unsigned short>(nSize, g_GI.numExtTangents))
		return;

	if (!g_GI.numExtTangents)
	{
		dumpWarning("No External tangents");
		return;
	}

	const unsigned short* pExtToInt = (const unsigned short*)pData;
	g_pGIExtToInt = pExtToInt;

	if (g_bDumpIndexMaps)
	{
		const int nStep = 100;
		unsigned i, j;
		for (j = 0; j < g_GI.numExtTangents; j += nStep)
		{
			if (j)
				dump("");

			for (i = j; i < g_GI.numExtTangents && i < j+nStep; ++i)
				dumpPlus ("%5d", i);
			dump("");
			for (i = j; i < g_GI.numExtTangents && i < j+nStep; ++i)
				dumpPlus("  -v-");
			dump("");
			for (i = j; i < g_GI.numExtTangents && i < j+nStep; ++i)
				dumpPlus("%5d", pExtToInt[i]);
			dump("");
		}
	}

	// check which internal vertices are referred
	std::vector<unsigned> arrIntRef;
	arrIntRef.resize (g_GI.numVertices, 0);
	// the invalid internal vertices referred
	std::set<unsigned> setIntInvalid;

	unsigned i;
	for (i = 0; i < g_GI.numExtTangents; ++i)
	{
		// internal vertex index
		unsigned short nInt = pExtToInt[i];
		if (nInt > g_GI.numVertices)
			setIntInvalid.insert (nInt);
		else
			++arrIntRef[nInt];
	}

	unsigned nMinRef = arrIntRef[0], nMaxRef = arrIntRef[0];
	for (i = 1; i < g_GI.numVertices; ++i)
		if (arrIntRef[i] < nMinRef)
			nMinRef = arrIntRef[i];
		else
			if (arrIntRef[i] > nMaxRef)
				nMaxRef = arrIntRef[i];

	// calculate how many of each there are
	std::vector<unsigned> arrIntRefHysto;
	arrIntRefHysto.resize (nMaxRef+1, 0);
	for (i = 0; i < g_GI.numVertices; ++i)
		++arrIntRefHysto[arrIntRef[i]];

	if (arrIntRefHysto[0])
		dumpWarning ("%d internal vertices are not referred", arrIntRefHysto[0]);

	if (!setIntInvalid.empty())
	{
		dumpError("Referred indices out of range: %s", toString (setIntInvalid, "%u").c_str());
	}

	dumpPlus ("Internal vertex reference count hystogram: ");
	for (i = nMinRef; i <= nMaxRef; ++i)
	{
		if (i != nMinRef)
			dumpPlus(", ");
		dumpPlus ("%d:%3d", i, arrIntRefHysto[i]);
	}
	dump("");

	const int nUnusualBigRefCount = 7;
	if (nMaxRef > nUnusualBigRefCount)
	{
		dumpPlus ("Internal Vertices referred to > %d times:", nUnusualBigRefCount);
		for (unsigned i = 0; i < arrIntRef.size(); ++i)
		{
			if (arrIntRef[i] > nUnusualBigRefCount)
			{
				dumpPlus (" %d (ext%d:", arrIntRef[i],i);
				unsigned n = 0;
				for (unsigned j = 0; j < g_GI.numExtTangents; ++j)
					if (pExtToInt[j] == i)
					{
						if (n)
							dumpPlus(",");
						dumpPlus("%d", j);
						++n;
					}
					dumpPlus (")");
			}
		}
		dump("");
	}

/*	if (g_bDumpMeshIndices)
	{
		unsigned short* pVertices=(unsigned short*)pData;
		for (int x=0; x<1710; x++) {
			dump("vert: %04d %04d",x,pVertices[x]);
		}
	}*/

}



void printChunkGIExtUVs (const char* pData, unsigned nSize)
{
	if (!validArrSize<CryUV>(nSize, g_GI.numExtTangents))
		return;

	const CryUV* pUVs = (const CryUV*)pData;
	unsigned i;
	CryUV uvMin, uvMax;
	for (i = 0; i < g_GI.numExtTangents; ++i)
	{
		if (!i)
			uvMin = pUVs[0], uvMax = pUVs[0];

		if (g_bDumpMeshUVs)
			dump ("\t% 4d\t(%.4f, %.4f)", i, pUVs[i].u, pUVs[i].v);

		uvMin.u = min(uvMin.u, pUVs[i].u);
		uvMin.v = min(uvMin.v, pUVs[i].v);
		uvMax.u = max(uvMax.u, pUVs[i].u);
		uvMax.v = max(uvMax.v, pUVs[i].v);
	}
	dump ("UV BBox:(%.3f,%.3f)..(%.3f,%.3f)", uvMin.u, uvMin.v, uvMax.u, uvMax.v);
}

void printChunkGIIndexBuffer (const char* pData, unsigned nSize)
{
	if (!validArrSize<unsigned short>(nSize, g_GI.numIndices))
		return;

	const unsigned short* pIndices = (const unsigned short*)pData;
	g_pGIIndices = pIndices;
	unsigned numOutOfRange = 0;
	for (unsigned i = 0; i < g_GI.numIndices; ++i)
	{
		if (pIndices[i] >= g_GI.numExtTangents)
			++numOutOfRange;
		if (g_bDumpMeshIndices)
		{
			if (0==(i%3))
				dumpPlus ("%4d. ", i);
			dumpPlus ("%8d", pIndices[i]);
			if (2==(i%3))
				dump("");
		}
	}

	if (numOutOfRange)
		dumpError ("%d indices out of range [0,%u)", numOutOfRange, g_GI.numExtTangents);
}

void printChunkGIPrimitiveGroups (const char* pData, unsigned nSize)
{
	if (!validArrSize<CCFMaterialGroup>(nSize, g_GI.numPrimGroups))
		return;

	const CCFMaterialGroup* pPrimGroup = (const CCFMaterialGroup*)pData;
	unsigned i, nNextIndex = 0;
	for (i = 0; i < g_GI.numPrimGroups; ++i)
	{
		const CCFMaterialGroup& pg = pPrimGroup[i];
		dump ("%d. mtl%3d. [%4d, %4d) size %4d", i, pg.nMaterial, pg.nIndexBase, pg.nIndexBase + pg.numIndices, pg.numIndices);
		if (unsigned(pg.nIndexBase + pg.numIndices) > g_GI.numIndices)
			dumpWarning ("Indices out of range: [%4d, %4d)", pg.nIndexBase, pg.nIndexBase + pg.numIndices);
	}
}

void printGIFaceSummary()
{
	if (!g_pGIFaces || !g_pGIIndices)
	{
		dumpWarning ("The GeometryInfo chunk misses Faces and/or Indices");
		return;
	}

	typedef std::map<CCFIntFace, unsigned, CCFIntFaceSort>FaceMap;
	FaceMap setFaces, setIndices;
	for (unsigned i = 0; i < g_GI.numFaces; ++i)
	{
		setFaces.insert (FaceMap::value_type(g_pGIFaces[i], i));
		setIndices.insert (FaceMap::value_type(CCFIntFace (g_pGIIndices+i*3), i*3));
	}

	FaceMap::iterator it, itEnd;
	bool bHeader = true;
	for (it = setFaces.begin(), itEnd = setFaces.end(); it != itEnd; ++it)
	{
		CCFIntFace Face = it->first;
		if (setIndices.find (Face) == setIndices.end())
		{
			if (bHeader)
			{
				bHeader = false;
				dump ("Faces missing from the indices:");
			}
			dump ("\t% 4d\tv=(% 4d,% 4d,% 4d)", it->second, Face.v[0], Face.v[1], Face.v[2]);
		}
	}
}

void printChunkStencilShadowConnectivity (const char* pData, unsigned nSize)
{
	CStencilShadowConnectivity* pSSConn = new CStencilShadowConnectivity();
	unsigned nReadBytes = pSSConn->Serialize(false, (void*)pData, nSize);

	if (!validSerialize (nReadBytes, nSize))
		return;

	if (pSSConn->numOrphanEdges())
		dumpWarning ("%d orphan edges",pSSConn->numOrphanEdges());

	dump("%d faces, %d vertices, %d edges",
		pSSConn->numFaces(), pSSConn->numVertices(), pSSConn->numEdges(), pSSConn);

	pSSConn->Release();
}

void printChunkGIIntFaces (const char* pData, unsigned nSize)
{
	if (!validSize(nSize, g_GI.numFaces * (sizeof(CCFIntFace)+sizeof(CCFIntFaceMtlID))))
		return;

	// when we meet an unused vertex that has not been marked as used,
	// mark it and decrease the number of used vertices
	unsigned numUnusedVerts = g_GI.numVertices;
	std::vector<bool> arrUnusedVerts;
	arrUnusedVerts.resize (g_GI.numVertices, true);
	const CCFIntFace* pFaces = (const CCFIntFace*)pData;
	g_pGIFaces = pFaces;
	const CCFIntFaceMtlID* pFaceMtl = (const CCFIntFaceMtlID*)(pFaces+g_GI.numFaces);

	std::set<unsigned> setOutOfRange, setMaterials;

	unsigned nFace;
	for (nFace = 0; nFace < g_GI.numFaces; ++nFace)
	{
		const CCFIntFace Face = pFaces[nFace];
		for (int v = 0; v < 3; ++v)
		{
			unsigned short nVertex = Face.v[v];
			if (nVertex > g_GI.numVertices)
			{
				setOutOfRange.insert (nVertex);
			}
			else
			{
				if (arrUnusedVerts[nVertex])
				{
					arrUnusedVerts[nVertex] = false;
					--numUnusedVerts;
				}
			}
		}
		setMaterials.insert(pFaceMtl[nFace]);

		if (g_bDumpMeshFaces)
			dump ("\t% 4d\tv=(% 4d,% 4d,% 4d) MatID=%d", nFace, Face.v[0], Face.v[1], Face.v[2], pFaceMtl[nFace]);
	}

	if (!setOutOfRange.empty())
	{
		dumpError ("Out-Of-Range vertices: %s", toString (setOutOfRange, "%u").c_str());
	}

	if (numUnusedVerts)
	{
		std::set<unsigned> setUnused;
		for (unsigned nVertex = 0; nVertex < g_GI.numVertices; ++nVertex)
		{
			if (arrUnusedVerts[nVertex])
				setUnused.insert (nVertex);
		}
		dumpWarning ("Unused vertices: %s", toString (setUnused, "%u").c_str());
	}

	dump ("Used materials: %s", toString(setMaterials, "%u").c_str());
}

void printChunkSkinTangents (const char* pData, unsigned nSize)
{
	CrySkinRigidBasis TangSkin;
	unsigned nReadBytes = TangSkin.Serialize(false, (void*)pData, nSize);
	if (!validSerialize(nReadBytes, nSize))
		return;

	CrySkinRigidBasis::CStatistics Stat (&TangSkin);
	dump ("Bones [%d..%d]; %d links, %d AuxInts; Destination Vertices: %s",
		Stat.numSkipBones, Stat.numBones, Stat.numVertices, Stat.numAuxInts, isGIFullExtTangRange (Stat.setDests)?"ALL":toString (Stat.setDests, "%u").c_str());
}

void printChunkSkinVertices(const char* pData, unsigned nSize)
{
	CrySkinFull VertexSkin;
	unsigned nReadBytes = VertexSkin.Serialize_PC(false, (void*)pData, nSize);
	if (!validSerialize(nReadBytes, nSize))
		return;

	//VertexSkin.skin(pBones, pbuf)

	CrySkinFull::CStatistics Stat (&VertexSkin);
	dump ("Bones [%d..%d]; %d links, %d AuxInts; Destination Vertices: %s",
		Stat.numSkipBones, Stat.numBones, Stat.numVertices, Stat.numAuxInts,
		isGIFullVertexRange (Stat.setDests)?"ALL":toString (Stat.setDests, "%u").c_str());

/*unsigned long* pVertices=(unsigned long*)pData;
	for (int x=0; x<1500; x++) {
		dump("vert: %08x %08x",x,pVertices[x]);
	}*/

/*	float*         pfVertices=(float*)pData;
	unsigned long* plVertices=(unsigned long*)pData;
	for (int x=0; x<966*3; x++) {
		dump("vert: %04d %08x %f",x,plVertices[x],pfVertices[x]);
	}*/

	if (g_bDumpMeshVerts)
	{
		float ScaleVal=0.01f;
		float*         pfVertices=(float*)pData;
		for (int x=0; x<996*4; x=x+4) {
			dump("vert: %04d: (%14.10f,%14.10f,%14.10f,%14.10f)",x/4,pfVertices[x+0]*ScaleVal,pfVertices[x+1]*ScaleVal,pfVertices[x+2]*ScaleVal, pfVertices[x+3]);
		}
	}

//-------------------------------------------------------------------------------

	// get the initial pose
	std::vector<Matrix44> arrInitPose;
	arrInitPose.resize (g_arrBones.size());

	for (unsigned nBone = 0; nBone < g_arrBones.size(); ++nBone)
		arrInitPose[nBone] = Matrix44::GetInverted44(g_arrBones[nBone].getInvDefGlobal());

	// calculate the default pose skin (vertex coordinates)
	std::vector<Vec3d>arrIntVerts, arrExtVerts;
	arrIntVerts.resize (g_GI.numVertices);
	VertexSkin.skin (&arrInitPose[0],&arrIntVerts[0]);

	// renumerate them into external indexation (for renderer)
	arrExtVerts.resize(g_GI.numExtTangents);
	for (unsigned nExtVert = 0; nExtVert < g_GI.numExtTangents; ++nExtVert)
		arrExtVerts[nExtVert] = arrIntVerts[g_pGIExtToInt[nExtVert]];

	//-------------------------------------------------------------------------------

	/*float		ScaleVal		=	0.01f;
	float*	pfVertices	=	(float*)pData;
	for (int x=0; x<1710; x++) {
		dump("vertices: %04d: (%14.10f,%14.10f,%14.10f )",x, arrExtVerts[x].x, arrExtVerts[x].y, arrExtVerts[x].z );
	}*/


}

void printChunkSkinNormals (const char* pData, unsigned nSize)
{
	CrySkinFull NormalSkin;
	unsigned nReadBytes = NormalSkin.Serialize_PC(false, (void*)pData, nSize);
	if (!validSerialize(nReadBytes, nSize))
		return;

	CrySkinFull::CStatistics Stat (&NormalSkin);
	dump ("Bones [%d..%d]; %d links, %d AuxInts; Destination Vertices: %s",
		Stat.numSkipBones, Stat.numBones, Stat.numVertices, Stat.numAuxInts, isGIFullVertexRange (Stat.setDests)?"ALL":toString (Stat.setDests, "%u").c_str());
}


void printGIFaceSummary2()
{
	if (!g_pGIFaces || !g_pGIIndices || !g_pGIExtToInt)
	{
		dumpWarning ("The GeometryInfo chunk misses Faces and/or Indices");
		return;
	}

	enum FaceEqualEnum{nNotFound, nFound, nFoundReverse};

	unsigned numNotFound = 0;
	unsigned numReversed = 0;

	for (unsigned nFace = 0; nFace < g_GI.numFaces; ++nFace)
	{
		CCFIntFace Face = g_pGIFaces[nFace], FaceInd;
		FaceEqualEnum nFaceEqual = nNotFound;
		unsigned nIndFace;
		const unsigned short* pInd = NULL;
		for (nIndFace = 0; nIndFace < g_GI.numFaces*3-2 && nFaceEqual == nNotFound; nIndFace += 3)
		{
			pInd = g_pGIIndices + nIndFace;
			for (int v = 0; v < 3; ++v)
				FaceInd.v[v] = g_pGIExtToInt[pInd[v]];

			if (isFaceEqual (Face.v, FaceInd.v))
				nFaceEqual = nFound;
			else
				if (isFaceReverse(Face.v, FaceInd.v))
					nFaceEqual = nFoundReverse;
		}

		switch (nFaceEqual)
		{
		case nNotFound:
			dump ("\t% 4d\tv=(% 4d,% 4d,% 4d)  -  Not found", nFace, Face.v[0], Face.v[1], Face.v[2]);
			++numNotFound;
			break;
		case nFoundReverse:
			dump ("\t% 4d\tv=(% 4d,% 4d,% 4d)  -  reverse@% 4d (% 4d,% 4d,% 4d)", nFace, Face.v[0], Face.v[1], Face.v[2], nIndFace, FaceInd.v[0], FaceInd.v[1], FaceInd.v[2]);
			++numReversed;
			break;
		case nFound:
			break;
		}
	}

	if (numNotFound)
		dumpPlus ("%u Faces Not Found. ", numNotFound);
	if (numReversed)
		dumpPlus ("%u Reversed.", numReversed);
	if (numNotFound || numReversed)
		dump("");
}


void printChunkGI (CCFChunkTypeEnum nType, const char* pData, unsigned nSize)
{
	dump ("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	dump ("%s (#%d), Data Size: 0x%04X(%d) bytes, Data GI Chunk Offset: 0x%05X, Data FilePos: 0x%05X",
		getChunkName(nType), nType, nSize, nSize, pData - g_pGIData, pData-g_pFileData);

	switch (nType)
	{
	case CCF_GI_INT_COLORS:
		printChunkGIIntColors (pData, nSize);
		break;

	case CCF_GI_EXT_TANGENTS:
		printChunkGIExtTangents (pData, nSize);
		break;

	case CCF_GI_EXT_TO_INT_MAP:
		printChunkGIExtToIntMap (pData, nSize);
		break;

	case CCF_GI_EXT_UVS:
		printChunkGIExtUVs (pData, nSize);
		break;

	case CCF_GI_INDEX_BUFFER:
		printChunkGIIndexBuffer (pData, nSize);
		break;

	case CCF_GI_PRIMITIVE_GROUPS:
		printChunkGIPrimitiveGroups (pData, nSize);
		break;

	case CCF_STENCIL_SHADOW_CONNECTIVITY:
		printChunkStencilShadowConnectivity(pData, nSize);
		break;

	case CCF_SKIN_VERTICES:
		printChunkSkinVertices (pData, nSize);
		break;

	case CCF_SKIN_NORMALS:
		printChunkSkinNormals (pData, nSize);
		break;

	case CCF_SKIN_TANGENTS:
		printChunkSkinTangents (pData, nSize);
		break;

	case CCF_GI_INT_FACES:
		printChunkGIIntFaces (pData, nSize);
		break;

	default:
		dumpError ("UNEXPECTED CHUNK");
		break;
	}
}

void printChunkGeometryInfo (const char* pData, unsigned nSize)
{
	AUTO_DUMP_LEVEL("|");

	if (nSize < sizeof(CCFAnimGeomInfo))
	{
		dumpError ("GI Chunk is truncated");
		return;
	}

	g_GI = *(const CCFAnimGeomInfo*)pData;
	dump ("%u Faces, %u Vertices, %u Indices, %u External Tangents, %u PrimGroups",
		g_GI.numFaces, g_GI.numVertices, g_GI.numIndices, g_GI.numExtTangents, g_GI.numPrimGroups);

	if (g_GI.numIndices != g_GI.numFaces*3)
		dump ("%u Indices %s 3 * %u Faces", g_GI.numIndices,g_GI.numIndices < g_GI.numFaces*3?"<":">", g_GI.numFaces);

	g_pGIIndices = NULL;
	g_pGIFaces   = NULL;
	g_pGIData = pData + sizeof(CCFAnimGeomInfo);
	const char* pDataEnd = pData + nSize;
	const char* pParsedDataEnd = g_pGIData;
	for (CCFMemReader Reader (g_pGIData, nSize-sizeof(CCFAnimGeomInfo)); !Reader.IsEnd(); Reader.Skip())
	{
		assert ((const char*)Reader.GetData() + Reader.GetDataSize() <= pDataEnd);
		printChunkGI (Reader.GetChunkType(), (const char*) Reader.GetData(), Reader.GetDataSize());
		pParsedDataEnd = (const char*)Reader.GetData() + Reader.GetDataSize();
	}

	{
		//dump (" + FaceSummary:");
		{
			AUTO_DUMP_LEVEL(" !");
			printGIFaceSummary2();
		}
		//dump (" + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -");
	}

	assert (pParsedDataEnd <= pDataEnd);
	if (pParsedDataEnd != pDataEnd)
	{
		dumpError ("Malformed GI chunk data: cannot parse subchunks beyond data offset 0x%X (FilePos 0x%05X)",
			pParsedDataEnd - g_pGIData, pParsedDataEnd - g_pFileData); 
	}
	g_pGIData = NULL;
}
