
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
#include <LeafBuffer.h>
#include <StringUtils.h>
#include "CcgDump.h"
#include "CcgPrintChunk.h"

#include "StencilShadowConnectivity.h"
#include "CrySkinFull.h"
#include "CryBoneDesc.h"
#include "CrySkinRigidBasis.h"
#include "CgfUtils.h"
#include "CcgUtils.h"
#include "CcgGeometryInfo.h"
#include "CcgBoneGeometry.h"
#include "CcgBoneDescArray.h"
#include "CcgMorphTargetSet.h"
#include "BoneLightBindInfo.h"
#include "CcgAnimScript.h"

void printTexture (const char* szName, const TextureMap3& tex)
{
	if (!tex.name[0])
		return;

	g_setTextures.insert (tex.name);

	dumpPlus (" %s \"%s\"", szName, tex.name);

	if (g_bBriefMaterials)
		return;

	dumpPlus (", Amount %d, Type %s (0x%02X) Flags 0x%02X",
		(int)tex.Amount,
		getTexType (tex.type),
		(int)tex.type,
		(int)tex.flags
		);

	if (tex.flags & TEXMAP_NOMIPMAP)
		dumpPlus (" (TEXMAP_NOMIPMAP)");

	dump("");

	AUTO_DUMP_LEVEL("   ");

	if (tex.utile || tex.vtile)
	{
		dumpPlus ("Tiling:");
		if (tex.utile)
			dumpPlus (" U");
		if (tex.vtile)
			dumpPlus (" V");
		dump ("");
	}

	if (tex.umirror || tex.vmirror)
	{
		dumpPlus ("Mirror:");
		if (tex.umirror)
			dumpPlus (" U");
		if (tex.vmirror)
			dumpPlus (" V");
		dump ("\n");
	}

	if (tex.nthFrame)
		dump ("Update reflection every %d frame", tex.nthFrame);

	if (tex.refBlur || tex.refSize)
		dump ("Reflection size %g, blur %g", tex.refSize, tex.refBlur);



	dump ("UV Scale (%g,%g), UV Offset (%g,%g), UVW Rotate (%g,%g,%g)",
		tex.uscl_val, tex.vscl_val,
		tex.uoff_val, tex.voff_val,
		tex.urot_val, tex.vrot_val, tex.wrot_val);

	dump ("UV Scale Controller IDs (0x%08X,0x%08X), UV Offset Controller IDs (0x%08X,0x%08X), UVW Rotate Controller IDs (0x%08X,0x%08X,0x%08X)",
		tex.uscl_ctrlID, tex.vscl_ctrlID,
		tex.uoff_ctrlID, tex.voff_ctrlID,
		tex.urot_ctrlID, tex.vrot_ctrlID, tex.wrot_ctrlID);
}



void printChunkVertices (const char* pData, unsigned nSize)
{
	dumpWarning("Unsupported chunk?");
}




std::vector<CryBoneDesc> g_arrBones;

const char* getBoneName (unsigned int i)
{
	if (i < g_arrBones.size())
		return g_arrBones[i].getNameCStr();
	return "?";
}

void printChunkBoneDescArray (const char* pData, unsigned nSize)
{
	if (nSize < sizeof (CCFBoneDescArrayHeader))
	{
		dumpError ("Truncated chunk");
		return;
	}

	const CCFBoneDescArrayHeader* pDesc = (const CCFBoneDescArrayHeader*)pData;
	g_pBoneDescArrayHeader = pDesc;
	if (pDesc->numBones > 1000)
	{
		dumpError ("Unexpectedly many bones (%u)", pDesc->numBones);
		return;
	}

	dump ("%u bones", pDesc->numBones);

	const char* pDataEnd = pData + nSize;
	const char* pBoneData = (const char*)(pDesc+1);

	g_arrBones.clear();
	g_arrBones.reserve (pDesc->numBones);
	unsigned nBone;
	for (nBone = 0; nBone < pDesc->numBones; ++nBone)
	{
		if (pBoneData >= pDataEnd)
		{
			dumpError ("Bone array truncated on the bone %d for unknown reason", nBone);
			break;
		}

		g_arrBones.resize (nBone+1);
		CryBoneDesc& rBone = g_arrBones.back();
		unsigned nReadBytes = rBone.Serialize(false, (void*)pBoneData, pDataEnd - pBoneData);

		if (!nReadBytes)
		{
			dumpError ("Cannot Read bone %d", nBone);
			break;
		}

		pBoneData += nReadBytes;

		if (pBoneData > pDataEnd)
		{
			dumpError ("Bone %d (\"%s\") deserialized more data than available in the stream", nBone, rBone.getNameCStr());
			break;
		}
	}

	if (pBoneData != pDataEnd)
		dumpWarning ("Only %d bytes of %d available is used for the bone array", pBoneData-pData, nSize);

	// validate the bone tree
	bool bValid = true;
	std::set<unsigned> setMissedBones;
	for (unsigned nBone = 0; nBone < g_arrBones.size(); ++nBone)
	{
		CryBoneDesc* pBone = &g_arrBones[nBone];
		int nPIO = pBone->getParentIndexOffset();
		if (nPIO > 0 || (nPIO==0 && nBone!=0))
		{
			bValid = false;
			dumpError ("Bone %d \"%s\" has bad parent offset %d", nPIO, pBone->getNameCStr());
		}

		if (nPIO != 0 && nBone == 0)
		{
			bValid = false;
      dumpError("Root Bone \"%s\" has a parent (offset %d)", nPIO, pBone->getNameCStr());
		}

		int nChildIdx = pBone->getFirstChildIndexOffset();
		int numChildren = pBone->numChildren();

		if (numChildren < 0 || nChildIdx < 0 || (numChildren>0 && (nBone+nChildIdx+numChildren >g_arrBones.size() || nChildIdx <= 0)))
		{
			bValid = false;
			dumpError("Bone %d \"%s\" has invalid children: offset %d, number %d, [%d..%d]",
				nBone, pBone->getNameCStr(), nChildIdx, numChildren, nBone+nChildIdx, nBone+nChildIdx+numChildren);
		}

		if (nBone != 0)
		{
			int nParent = nBone + pBone->getParentIndexOffset();
			if (nParent < 0 || nParent >= (int)nBone)
			{
				bValid = false;
				dumpError("Bone %d \"%s\" Parent out of bone array range (%d)", nBone, pBone->getNameCStr(), nParent);
			}
			else
			{
				CryBoneDesc* pParent = &g_arrBones[nParent];
				if (pBone >= pParent + pParent->getFirstChildIndexOffset() + pParent->numChildren()
					|| pBone < pParent + pParent->getFirstChildIndexOffset())
				{
					bValid = false;
					dumpError("Bone %d \"%s\" has inconsistent child-parent relationship (not within the parent's)", nBone, pBone->getNameCStr());
				}
			}
		}
	}

	CBoneDescArray Bones;
	Bones.init (&g_arrBones[0], g_arrBones.size());
	if (bValid)
	{
		// full version of the bone tree
		Bones.print();
	}
	else
	{
		dump ("##.%-45s    ctrlId  numChild child@ parent@", "  bone name");
		// cut version of the bone tree - not all bones have been read
		for (unsigned nBone = 0; nBone < g_arrBones.size(); ++nBone)
		{
			CryBoneDesc& rBone = g_arrBones[nBone];
			dump ("%2d.%-45s 0x%08X %8d %8d %8d", nBone,
				(Bones.boneDepthStr(&rBone) + "\"" + rBone.getName() + "\"").c_str(),
				rBone.getControllerId(),
				rBone.numChildren(),
				rBone.getFirstChildIndexOffset(),
				rBone.getParentIndexOffset());
		}												
	}
}


void printChunkHeaderCCG (const char* pData, unsigned nSize)
{
	if (nSize != sizeof(CCFCCGHeader))
	{
		dumpError ("Unexpected data size: must be %d bytes (sizeof(CCFCCGHeader))", sizeof(CCFCCGHeader));
		return;
	}

	const CCFCCGHeader* pHeader  = (const CCFCCGHeader*)pData;
	dump ("%d LODs declared", pHeader->numLODs);
}


void printChunkCharLightDesc (const char* pData, unsigned nSize)
{
	const CCFCharLightDesc* pDesc = (const CCFCharLightDesc*)pData;
	if (nSize < sizeof(const CCFCharLightDesc*))
	{
		dumpError ("CharLightDesc chunk header is truncated");
		return;
	}

	dump ("%d lights, %d local", pDesc->numLights, pDesc->numLocalLights);
	const char* pRawData = (const char*)(pDesc+1);
	const char* pDataEnd = pData + nSize;

	for (unsigned nLight = 0; nLight < pDesc->numLights; ++ nLight)
	{
		dumpPlus("%2d.", nLight);
		AUTO_DUMP_LEVEL("  ");
		CBoneLightBindInfo Light;
		unsigned numReadBytes = Light.Serialize (false, (void*)pRawData, pDataEnd-pRawData);
		if (!numReadBytes)
		{
			dumpError ("Cannot Read light %d", nLight);
			return;
		}
		pRawData += (numReadBytes+3)&~3;
		assert (pRawData <= pDataEnd);

		AngleAxis aa (Light.m_qRot);

		char szColor[64] = "{";
		if (Light.m_rgbColor.r == 1 && Light.m_rgbColor.g == 1 && Light.m_rgbColor.b == 1)
			strcat (szColor, "White");
		else
			sprintf (szColor+strlen(szColor), "r=%.2f,g=%.2f,b=%.2f", Light.m_rgbColor.r,Light.m_rgbColor.g,Light.m_rgbColor.b);

		if (Light.m_rgbColor.a != 1)
			sprintf (szColor+strlen(szColor), ",%.2f", Light.m_rgbColor.a);

		strcat (szColor, "}");

		if (Light.m_fIntensity != 1)
			sprintf (szColor+strlen(szColor), "*%.2f", Light.m_fIntensity);

		dump("%s Light %s %s Shadow %s in Bone %d \"%s\"",
			getLightType(Light.m_nType).c_str(),
			Light.m_bOn?"ON":"OFF",
			szColor,
			Light.m_bShadow?"ON":"OFF",
			Light.m_nBone, getBoneName (Light.m_nBone));
			

		dump ("@ Offset {%g,%g,%g} Rotation {%.1f° around %.3f,%.3f,%.3f}",
			Light.m_vPos.x, Light.m_vPos.y, Light.m_vPos.z,
			aa.angle*180/M_PI, aa.axis.x, aa.axis.y, aa.axis.z);

		if (Light.m_nDLightFlags)
		{
			dumpPlus("DLightFlags =");
			if (Light.m_nDLightFlags & DLF_LIGHTSOURCE)
				dumpPlus(" DLF_LIGHTSOURCE");
			if (Light.m_nDLightFlags & DLF_HEATSOURCE)
				dumpPlus(" DLF_HEATSOURCE");
			if (Light.m_nDLightFlags & DLF_LOCAL)
				dumpPlus(" DLF_LOCAL");
			if (Light.m_nDLightFlags & DLF_PROJECT)
				dumpPlus(" DLF_PROJECT");
			if (Light.m_nDLightFlags & DLF_POINT)
				dumpPlus(" DLF_POINT");
			dump(" = 0x%X", Light.m_nDLightFlags);
		}

		if (*Light.getLightImageCStr())
			dump("Light Image: \"%s\"", Light.getLightImageCStr());

		if (Light.m_bUseNearAtten)
			dumpPlus ("Near Attenuation: %g..%g", Light.m_fNearAttenStart, Light.m_fNearAttenEnd);
		else
			dumpPlus ("Near Attenuation is OFF ");

		if (Light.m_bUseFarAtten)
			dumpPlus ("Far Attenuation: %g..%g", Light.m_fFarAttenStart, Light.m_fFarAttenEnd);
		else
			dumpPlus ("Far Attenuation is OFF");
		dump("");
	}
}


void printChunkMaterials (const char* pData, unsigned nSize)
{
	if (!intArrSize<MAT_ENTITY>(nSize))
		return;

	const MAT_ENTITY* pMtl = (const MAT_ENTITY*)pData;
	unsigned numMtls = nSize / sizeof(MAT_ENTITY);
	for (unsigned nMtl = 0; nMtl < numMtls; ++nMtl)
	{
		const MAT_ENTITY& rMtl = pMtl[nMtl];
		dumpPlus ("%2u. \"%s\"", nMtl, rMtl.name);
		AUTO_DUMP_LEVEL("   ");

		if (!g_bBriefMaterials)
		{
			dump("");
			dumpPlus ("Colors: diffuse "); dumpPlus (rMtl.col_d);
			dumpPlus(", specular "); dumpPlus(rMtl.col_s);
			dumpPlus(", ambient "); dumpPlus(rMtl.col_a);
			dump ("");

			dump ("SpecLevel %.2f, SpecShininess %.2f, SelfIllumination %.2f, Opacity %.2f",
				rMtl.specLevel, rMtl.specShininess, rMtl.selfIllum, rMtl.opacity);
		}

		printTexture ("Ambient", rMtl.map_a);
		printTexture ("Diffuse", rMtl.map_d);
		printTexture ("Opacity", rMtl.map_o);
		printTexture ("Bump", rMtl.map_b);
		printTexture ("Specular", rMtl.map_s);
		printTexture ("Gloss", rMtl.map_g);
		printTexture ("Detail", rMtl.map_detail);
		printTexture ("Environment", rMtl.map_e);
		printTexture ("Subsurface", rMtl.map_subsurf);
		printTexture ("Refraction", rMtl.map_displ);

		if (!g_bBriefMaterials)
		{
			dumpPlus ("Flags %08X %s ", rMtl.flags, getMtlFlags(rMtl.flags).c_str());
			dumpPlus ("Dyn: Bounce %.3f, StaticFriction %.3f, SlidingFriction %.3f", rMtl.Dyn_Bounce, rMtl.Dyn_StaticFriction, rMtl.Dyn_SlidingFriction);
		}
		dump("");
	}
}

void printChunkUserProperties (const char* pData, unsigned nSize)
{
	for (const char* pEnd = pData + nSize; pData < pEnd; pData += 1 + strlen(pData))
	{
		const char* pValue = pData + 1 + strlen(pData);
		if (pValue > pEnd || (!*pData && !*pValue)) // the pairs "name" "value" end with \0\0 or with one of the pair members not fitting into the chunk
			break;
		dump("%32s = \"%s\"", pData, pValue);
		pData = pValue;
	}
}

void printChunk (CCFChunkTypeEnum nType, const char* pData, unsigned nSize)
{
	dump ("-------------------------------------------------------------------");
	dump ("%s (#%d), Data Size: 0x%04X(%d) bytes, Data FilePos: 0x%05X",
		getChunkName(nType), nType, nSize, nSize, pData-g_pFileData);
	switch (nType)
	{
	case CCF_HEADER_CCG:
		printChunkHeaderCCG (pData, nSize);
		break;

	case CCF_GEOMETRY_INFO:
		printChunkGeometryInfo (pData, nSize);
		break;
	
	case CCF_BONE_GEOMETRY:
		printChunkBoneGeometry(pData, nSize);
		break;

	case CCF_BONE_DESC_ARRAY:
		printChunkBoneDescArray (pData, nSize);
		break;

	case CCF_MATERIALS:
		printChunkMaterials (pData, nSize);
		break;

	case CCF_VERTICES:
		printChunkVertices (pData, nSize);
		break;

	case CCF_MORPH_TARGET_SET:
		printChunkMorphTargetSet (pData, nSize);
		break;

	case CCF_CHAR_LIGHT_DESC:
		printChunkCharLightDesc (pData, nSize);
		break;

	case CCF_ANIM_SCRIPT:
		printChunkAnimScript (pData, nSize);
		break;

	case CCF_USER_PROPERTIES:
		printChunkUserProperties(pData, nSize); 
		break;

	default:
		dumpError ("UNEXPECTED CHUNK");
		break;
	}
}