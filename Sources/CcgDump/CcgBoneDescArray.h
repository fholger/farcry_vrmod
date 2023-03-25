
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

#include "CryBoneDesc.h"
class CBoneDescArray
{
	const CryBoneDesc* m_pBegin;
	const CryBoneDesc* m_pEnd;
public:
	void init (const CryBoneDesc* pBegin, unsigned numBones)
	{
		m_pBegin = (pBegin); m_pEnd = (pBegin + numBones);
	}
	void print ()
	{
		print (m_pBegin);
	}
	std::string boneDepthStr (const CryBoneDesc* pBone)
	{
		if (pBone<m_pBegin||pBone>=m_pEnd)
			return "?";
		std::string strDepth;
		while (pBone->hasParent())
		{
			strDepth += " ";
			pBone = pBone + pBone->getParentIndexOffset();
		}
		return strDepth;
	}
protected:
	// full version of the bone tree
	void print (const CryBoneDesc* pBone)
	{								
		dumpPlus ("%2d.%-45s 0x%08X phys:",
			pBone-m_pBegin, (boneDepthStr(pBone) + "\"" + pBone->getName() + "\"").c_str(),
			pBone->getControllerId());

		if (int(pBone->getPhysics(0).pPhysGeom)==-1)
			dumpPlus("NO");
		else
			dumpPlus("%d",pBone->getPhysics(0).pPhysGeom);
		
		dumpPlus(",");
		
		if (int(pBone->getPhysics(1).pPhysGeom)==-1)
			dumpPlus("NO");
		else
			dumpPlus("%d",pBone->getPhysics(1).pPhysGeom);

		dump("");
		if (g_bDumpBoneInitPos)
		{
			AUTO_DUMP_LEVEL("        ");
			Matrix44 matBone = GetInverted44(pBone->getInvDefGlobal());
			for (int i = 0; i < 4; ++i)
				dump ("%11.4f%11.4f%11.4f", matBone[i][0],matBone[i][1],matBone[i][2]);
		}
		const CryBoneDesc* pChildren = pBone+pBone->getFirstChildIndexOffset();
		for (unsigned i = 0; i < pBone->numChildren(); ++i)
			print (pChildren + i);
	}
};

