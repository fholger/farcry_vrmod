
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

//////////////////////////////////////////////////////////////////////////
// This is the general declarations for the startup of CcgDump:
// command-line-parameter-deduced arguments, dump function declarations etc.
//
#ifndef _CCG_DUMP_
#define _CCG_DUMP_
extern bool g_bDumpKeys;
// dumps mesh details
extern bool g_bDumpMeshVerts;
extern bool g_bDumpMeshIndices;
extern bool g_bDumpMeshFaces;
extern bool g_bDumpMeshUVs; // -meshUVs
extern bool g_bDumpMeshTexFaces;
extern bool g_bDumpMeshBones; // -meshBones
extern bool g_bDumpBoneInitPos; // -boneInitPos
extern bool g_bDumpMeshVertCols;
extern bool g_bBriefInfo;
extern bool g_bDumpIndexMaps;
extern char g_szVertexSortOrder[4], g_szFaceSortOrder[4], g_szUVSortOrder[4];
extern bool g_bBriefMaterials;
extern bool g_bDumpAnims;

// print the texture set at the end?
extern bool g_bCollectTextures;
// print as the copy command?
extern bool g_bCollectTexturesForCopying;

typedef std::set<std::string> StringArray;
// used textures: collection
extern StringArray g_setTextures;


// used node names: collection
extern StringArray g_setNodeNames;
extern StringArray g_setDuplicateNodeNames;

extern std::string g_strDumpDepth;
enum
{
	MDF_IS_ERROR = 1 << 0,
	MDF_IS_FATAL_ERROR = 1 << 1,
	MDF_PUT_EOL  = 1 << 2,
	MDF_IS_WARNING = 1 <<3
};
extern void MasterDumpV (unsigned nDumpFlags, const char* szFormat, va_list args);

#define DUMP_FUNCTION(FNAME,FLAGS) \
	inline void FNAME(const char* szFormat, ...) \
	{ \
		va_list args; \
		va_start (args,szFormat); \
		MasterDumpV ((FLAGS),szFormat, args); \
		va_end(args); \
	}

DUMP_FUNCTION(dump, MDF_PUT_EOL)
DUMP_FUNCTION(dumpError, MDF_PUT_EOL|MDF_IS_ERROR)
DUMP_FUNCTION(errorAbort, MDF_PUT_EOL|MDF_IS_FATAL_ERROR)
DUMP_FUNCTION(dumpPlus, 0)
DUMP_FUNCTION(dumpWarning, MDF_PUT_EOL|MDF_IS_WARNING);


extern const char* g_pFileData;
extern unsigned g_nFileSize;

class CDumpDepthLock
{
public:
	CDumpDepthLock (const char* str) {m_nWasLength = g_strDumpDepth.size(); g_strDumpDepth += str;}
	~CDumpDepthLock () {g_strDumpDepth.resize(m_nWasLength);}
protected:
	unsigned m_nWasLength;
};

#define AUTO_DUMP_LEVEL(c) CDumpDepthLock __DumpDepthLock__(c);

const char* getChunkName (unsigned nChunkType);

class CryBoneDesc;
extern std::vector<CryBoneDesc> g_arrBones;

#endif