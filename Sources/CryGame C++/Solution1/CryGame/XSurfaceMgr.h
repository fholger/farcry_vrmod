
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XSurfaceMgr.h
//  Description: Interface for the CXSurfaceMgr class.
//		Manages the loading and mapping of physical surface ids and materials script
//		BEHAVIOUR:
//		at creation time when LoadMaterials is invoked the class traverse the "scripts/materials" 
//		directory and store all existing materials paths
//		later the game will load the terrain materials from LevelData.xml and call AddTerrainSurface() 
//		for each terrain layer, this cause the loading of the associated materials
//		from this point every time a CGF(model) is loaded the 3d engine will call EnumPhysMaterial() 
//		with as argument the name of the material specified in 3dsMax, 
//		CXSurfaceMgr will:
//			-check if the material exists.
//			-if exists will check if is already loaded
//			-if is loaded will simply return the surface idx
//			-if not will load the material,generate a new surface idx and return it.
//
//  History:
//  - Aug 2001: File created 
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_XSURFACEMGR_H__FA141F16_72C8_44B1_98D3_CEB5E61093DA__INCLUDED_)
#define AFX_XSURFACEMGR_H__FA141F16_72C8_44B1_98D3_CEB5E61093DA__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <vector>
#include <I3DEngine.h>

//////////////////////////////////////////////////////////////////////
struct SMatProps
{
	SMatProps()
	{
		bNoCollide=false;
	}
	bool bNoCollide;
};


#define TERRAIN_MATERIAL_SURFACE_ID_BASE 0
#define ENTITY_MATERIAL_SURFACE_ID_BASE 10

//////////////////////////////////////////////////////////////////////
class CXSurfaceMgr : 
public IScriptObjectDumpSink,
public IPhysMaterialEnumerator
{
	typedef std::map<int,string> PhysicalSurfecesMap;
	typedef PhysicalSurfecesMap::iterator PhysicalSurfecesMapItor;
	typedef std::map<string,int> MaterialsMap;
	typedef MaterialsMap::iterator MaterialsMapItor;

	struct MatDesc
	{
		string sScriptFilename;
		int surfaceId;
	};

	typedef std::map<string,MatDesc> MaterialsNamesMap;
	typedef MaterialsNamesMap::iterator MaterialsNamesMapItor;

	typedef std::map<int,SMatProps> PhysicalSurfacesPropsMap;
	typedef PhysicalSurfacesPropsMap::iterator PhysicalSurfacesPropsMapItor;
public:
	CXSurfaceMgr();
	virtual ~CXSurfaceMgr();

	/*!initialize the class
	*/
	void Init(IScriptSystem *pScriptSystem,I3DEngine *p3DEngine,IPhysicalWorld *pPhysicalWorld);
	/*!add anew terrain material
		NOTE:
			this function must be call before any other EnumPhysMaterial() because the terrain surface ids
			are sequential starting from 0 so the have to be created in the correct order.
		@param sMaterial the name of the material
	*/
	void SetTerrainSurface( const string &sMaterial,int nSurfaceID);
	/*!scan a directory and load all material paths
		@param sFolder the folde tha has to be scanned
		@param bReaload [legacy]
	*/
	bool LoadMaterials( const string& sFolder,bool bReload=false,bool bAddMaterials=false );

	//! Load default materials (mat_default,mat_water)
	void LoadDefaults();
	
	/*! return the material script object specifying the material name
		@param sMaterialName the material's name
		@return the material script object if succeded and null if failed
	*/
	IScriptObject * GetMaterialByName( const char *sMaterialName );
	/*! return the material script object specifying the surface id
		@param nSurfaceID the material's surface id
		@return the material script object if succeded and null if failed
	*/
	IScriptObject * GetMaterialBySurfaceID(int nSurfaceID);
	/*! return the material surface id object specifying the material name
		@param sMaterialName the material's name
		@return the material surface id or the default material surface id if the surfac id is not found
		*/
	int GetSurfaceIDByMaterialName(const char *sMaterialName);

	/*! return the burnable property from gameplay_physic table from material script
		@param nSurfaceID the material's surface id
		@return the burnable property from gameplay_physic table from material script
		*/
	bool IsMaterialBurnable(int nSurfaceID);

	/*! reloads material's physics properties into the physics engine; script file is NOT reloaded if it was loaded before
		@param sMaterialName the material's name
	*/
	void ReloadMaterialPhysics(const char *sMaterialName);
	void ReloadMaterials();

	bool GetMaterialParticlesTbl(int nSurfaceID, const char* tblName, ParticleParams &sParamOut, IGame* pGame, ISystem* pSystem);

	/*!LEGACY FUNCTION
	*/
	void InitPhisicalSurfaces();
	void Reset();

	//IScriptObjectDumpSink
	void OnElementFound(const char *sName,ScriptVarType type);
	void OnElementFound(int nIdx,ScriptVarType type){/*ignore non string indexed values*/};
	//IPhysMaterialEnumerator
	int EnumPhysMaterial(const char * szPhysMatName);
	bool IsCollidable(int nMatId);
	int	GetMaterialCount();
	const char* GetMaterialNameByIndex( int index );
	unsigned MemStat();

private:
	//! @returns Id of loaded material.
	int LoadMaterial(const string &sMaterialName,bool bLoadAlsoIfDuplicate=false,int nForceID=-1);
	//! @returns Id of added material.
	int AddMaterial( const string &sMaterial,int nForceID=-1);
	void SetMaterialGameplayPhysic( int nId, _SmartScriptObject &table );
	int GetDefaultMaterial();

	/*! returns the material of a certain position in the height fields
	@param fX the x coordinate into the height field
	@param fY the y coordinate into the height field
	@return the material script object if succeeded and null if failed
	*/
	IScriptObject * GetTerrainMaterial(const float fX,const float fY);

	/*! returns the material name of a certain position in the height fields
	NOTE: this function is for debug purposes only
	@param fX the x coordinate into the height field
	@param fY the y coordinate into the height field
	@return the material name
	*/
	string &___GetTerrainMaterialName(const float fX,const float fY);

	IScriptSystem *m_pScriptSystem;
	I3DEngine *m_p3DEngine;
	IPhysicalWorld *m_pPhysicalWorld;
	//Material table(eg, mat_stuff)
	IScriptObject *m_pMaterialScriptObject;
	//Materials table
	IScriptObject *m_pObjectMaterials;

	PhysicalSurfecesMap m_mapPhysSurfaces;
	MaterialsMap m_mapMaterials;
	MaterialsNamesMap m_mapMaterialsNames;
	PhysicalSurfacesPropsMap m_mapMaterialProps;
	int m_nLastFreeSurfaceID;

	int m_mat_default_id;
};

#endif // !defined(AFX_XSURFACEMGR_H__FA141F16_72C8_44B1_98D3_CEB5E61093DA__INCLUDED_)
