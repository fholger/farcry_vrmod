
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

// CcgDump.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "CcgPrintChunk.h"
#include "CcgDump.h"

// OPTIONS
// dumps animation keys as they are in the file (in the controller chunks)
bool g_bDumpKeys = false;
// dumps mesh details
bool g_bDumpMeshVerts    = false;
bool g_bDumpMeshFaces    = false;
bool g_bDumpMeshIndices  = false;
bool g_bDumpMeshUVs      = false; // -meshUVs
bool g_bDumpMeshTexFaces = false;
bool g_bDumpMeshBones    = false; // -meshBones
bool g_bDumpBoneInitPos  = false; // -boneInitPos
bool g_bDumpMeshVertCols = false;
bool g_bBriefInfo        = false;
bool g_bBriefMaterials   = false;
bool g_bDumpAnims        = false;

bool g_bDumpIndexMaps    = false;

char g_szVertexSortOrder[4] = "", g_szFaceSortOrder[4] = "", g_szUVSortOrder[4] = "";

// print the texture set at the end?
bool g_bCollectTextures  = false;
// print as the copy command?
bool g_bCollectTexturesForCopying = false;

// used textures: collection
StringArray g_setTextures;


// used node names: collection
StringArray g_setNodeNames;
StringArray g_setDuplicateNodeNames;

void printOptionHelp (const char*szOption, const char* szDescription)
{
	printf ("  % 30s   %s\n", szOption, szDescription);
}

struct ChunkDesc
{
	std::string strName;
	void (*fnDump)(unsigned nChunkId, void* pData, unsigned nDataSize);
};

typedef std::map<unsigned, std::string>ChunkTypeNameMap;
ChunkTypeNameMap g_mapChunkTypeName;

void InitChunkTypeNameMap()
{
#define ADD_CHUNK(NAME) g_mapChunkTypeName[CCF_##NAME] = "CCF_"	#NAME;
	ADD_CHUNK(EMPTY_CHUNK);
	ADD_CHUNK(HEADER_CCG);
	ADD_CHUNK(GEOMETRY_INFO);
	ADD_CHUNK(GI_PRIMITIVE_GROUPS);
	ADD_CHUNK(GI_INDEX_BUFFER);
	ADD_CHUNK(GI_EXT_TO_INT_MAP);
	ADD_CHUNK(GI_EXT_UVS);
	ADD_CHUNK(GI_EXT_TANGENTS);
	ADD_CHUNK(GI_INT_COLORS);
	ADD_CHUNK(BONE_DESC_ARRAY);
	ADD_CHUNK(VERTICES);
	ADD_CHUNK(NORMALS);
	ADD_CHUNK(STENCIL_SHADOW_CONNECTIVITY);
	ADD_CHUNK(SKIN_VERTICES);
	ADD_CHUNK(SKIN_NORMALS);
	ADD_CHUNK(SKIN_TANGENTS);
	ADD_CHUNK(MATERIALS);
	ADD_CHUNK(GI_INT_FACES);
	ADD_CHUNK(BONE_GEOMETRY);
	ADD_CHUNK(BG_BONE);
	ADD_CHUNK(MORPH_TARGET_SET);
	ADD_CHUNK(MORPH_TARGET);
	ADD_CHUNK(CHAR_LIGHT_DESC);
	ADD_CHUNK(ANIM_SCRIPT);
	ADD_CHUNK(ANIM_SCRIPT_DUMMYANIM);
	ADD_CHUNK(ANIM_SCRIPT_ANIMINFO);
	ADD_CHUNK(ANIM_SCRIPT_ANIMDIR);
	ADD_CHUNK(ANIM_SCRIPT_MODELOFFSET);
	ADD_CHUNK(USER_PROPERTIES);
#undef ADD_CHUNK
}

const char* getChunkName (unsigned nChunkType)
{
	if (g_mapChunkTypeName.find (nChunkType) != g_mapChunkTypeName.end())
		return g_mapChunkTypeName[nChunkType].c_str();
	else
		return "Unknown chunk";
}

std::string g_strDumpDepth;

const char* g_pFileData = NULL;
unsigned g_nFileSize = 0;

std::vector<std::string> g_arrErrors, g_arrWarnings;

unsigned g_nLastDumpFlags = MDF_PUT_EOL;

void MasterDumpV (unsigned nDumpFlags, const char* szFormat, va_list args)
{
	if (g_nLastDumpFlags&MDF_PUT_EOL)
		printf ("%s",g_strDumpDepth.c_str());
	g_nLastDumpFlags = nDumpFlags;

	if (nDumpFlags & MDF_IS_ERROR)
		printf ("ERROR: ");
	if (nDumpFlags & MDF_IS_WARNING)
		printf ("WARNING: ");

	vprintf (szFormat, args);
	if (nDumpFlags & MDF_PUT_EOL)
		printf ("\n");

	if (nDumpFlags & (MDF_IS_ERROR|MDF_IS_WARNING))
	{
		char szError[0x400];
		_vsnprintf (szError, sizeof(szError), szFormat, args);
		if (nDumpFlags&MDF_IS_ERROR)
			g_arrErrors.push_back(szError);
		if (nDumpFlags&MDF_IS_WARNING)
			g_arrWarnings.push_back(szError);

		if (nDumpFlags&MDF_IS_ERROR)
			vfprintf (stderr, szFormat, args);

		if (nDumpFlags & MDF_PUT_EOL)
			fprintf (stderr, "\n", args);
	}
}


void main(int argc, char* argv[])
{
	const char* szFileName = NULL;
	if (argc < 2)
	{
		printf ("Usage: %s -option1 -option2 ... file-name.cgf(caf) > Output-file-name.txt\n", argv[0]);
		printf ("Options:\n");
		printOptionHelp ("-briefInfo", "prints only the summary information about the file and the timing very essential chunks (timing)");
		printOptionHelp ("-indexMaps", "prints the ExtToInt etc. maps");
		return;
	}

	// Detect the flags
	//
	for (int i = 1; i < argc; ++i)
	{
		if (argv[i][0] != '/' && argv[i][0] != '-')
		{
			if (szFileName)
			{
				printf ("Only one file name is allowed\n");
				return;
			}
			szFileName = argv[i];
		}
		else
		{
			const char* szOption = argv[i]+1;
			if (!strcmpi(szOption, "keys"))
				g_bDumpKeys = true;
			else
			if (!strcmpi(szOption, "mesh"))
			{
				g_bDumpMeshVerts    = true;
				g_bDumpMeshFaces    = true;
				g_bDumpMeshIndices  = true;
				g_bDumpMeshUVs      = true;
				g_bDumpMeshTexFaces = true;
				g_bDumpMeshBones    = true;
				g_bDumpMeshVertCols = true;
				g_bDumpIndexMaps    = true;
			}
			else
			if (!strcmpi(szOption, "boneInitPos"))
			{
				g_bDumpBoneInitPos  = true;
			}
			else
			if (!strcmpi (szOption, "meshVerts"))
			{
				g_bDumpMeshVerts = true;
				if (i <argc-1 && argv[i+1][0] >= 'X' && argv[i+1][0] <= 'Z')
					strcpy (g_szVertexSortOrder, argv[++i]);
			}
			else
			if (!strcmpi (szOption, "meshFaces"))
			{
				g_bDumpMeshFaces = true;
				if (i <argc-1 && argv[i+1][0] >= '0' && argv[i+1][0] <= '2')
					strcpy (g_szFaceSortOrder, argv[++i]);
			}
			else
			if (!strcmpi(szOption, "meshIndices"))
			{
				g_bDumpMeshIndices = true;
			}
			else
			if (!strcmpi (szOption, "meshUVs"))
			{
				g_bDumpMeshUVs = true;
				if (i <argc-1 && argv[i+1][0] >= 'U' && argv[i+1][0] <= 'V')
					strcpy (g_szUVSortOrder, argv[++i]);
			}
			else
			if (!strcmpi (szOption, "meshTexFaces"))
			{
				g_bDumpMeshTexFaces = true;
			}
			else
			if (!strcmpi (szOption, "meshBones"))
			{
				g_bDumpMeshBones = true;
			}
			else
			if (!strcmpi (szOption, "meshVertCols"))
			{
				g_bDumpMeshVertCols = true;
			}
			else
			if (!strcmpi(szOption, "indexMaps"))
			{
				g_bDumpIndexMaps = true;
			}
			else
			if (!strcmpi(szOption, "collectTextures"))
			{
				g_bCollectTextures = true;
			}
			else
			if (!strcmpi(szOption, "collectTexturesForCopying"))
			{
				g_bCollectTextures = true;
				g_bCollectTexturesForCopying = true;
			}
			else
			if (!strcmpi(szOption, "anims") || !strcmpi(szOption, "anim"))
			{
				g_bDumpAnims = true;
			}
			else
			if (!strcmpi(szOption, "briefMaterials") || !strcmpi(szOption, "briefMtls") || !strcmpi(szOption, "briefMtl"))
			{
				g_bBriefMaterials = true;
			}
			else
			if (!strcmpi(szOption, "briefInfo"))
			{
				g_bBriefInfo = true;
			}
		}
	}

	if (!szFileName)
	{
		printf ("You must give me at least one file name, not only options\n");
		return;
	}

	// create the object that reads the file
	FILE* fIn = fopen (szFileName, "rb");
	if (!fIn)
	{													
		printf ("Cannot open %s: unrecognized file format or corrupted file\n", szFileName);
		return;
	}

	InitChunkTypeNameMap();

	fseek (fIn, 0, SEEK_END);
	g_nFileSize = ftell (fIn);
	fseek (fIn, 0, SEEK_SET);
	dump ("File: %s, size: 0x%05X (%u) bytes", szFileName, g_nFileSize, g_nFileSize);
	if (g_nFileSize & 3)
		dump("WARNING: file size not aligned on DWORD boundary");
	std::vector<char> arrFileData;
	arrFileData.resize (g_nFileSize);
	g_pFileData = &arrFileData[0];
	unsigned nReadBytes = fread (&arrFileData[0], 1, g_nFileSize, fIn);
	fclose (fIn);
	if (g_nFileSize != nReadBytes)
	{
		printf ("Error reading file!\n");
		return;
	}

	const char* pParsedDataEnd = g_pFileData;
	for (CCFMemReader Reader (g_pFileData, g_nFileSize); !Reader.IsEnd(); Reader.Skip())
	{
		printChunk (Reader.GetChunkType(), (const char*) Reader.GetData(), Reader.GetDataSize());
		pParsedDataEnd = (const char*)Reader.GetData() + Reader.GetDataSize();
	}
	if (pParsedDataEnd != g_pFileData+g_nFileSize)
	{
		dumpError ("Malformed data: cannot parse chunks beyond file offset 0x%05X",
			pParsedDataEnd - g_pFileData); 
	}
	if (!g_arrErrors.empty()||!g_arrWarnings.empty())
	{
		dump ("-TOTAL----------------------");
		if (!g_arrErrors.empty())
			dump ("ERROR%s:   %u", g_arrErrors.size()>1?"S":"", g_arrErrors.size());
		if (!g_arrWarnings.empty())
			dump ("Warning%s: %u", g_arrWarnings.size()>1?"s":"", g_arrWarnings.size());
	}
}
