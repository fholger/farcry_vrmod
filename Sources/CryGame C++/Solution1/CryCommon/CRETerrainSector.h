
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: CRETerrainSector.h 
//	Description: Misc Renderer element interface.
//
//	History:
//	- File created by Khonich Andrey
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef __CRECommon_H__
#define __CRECommon_H__

//////////////////////////////////////////////////////////////////////
class CRECommon : public CRendElement
{
  friend class CRender3D;

public:

  CRECommon()
  {
    mfSetType(eDATA_TerrainSector);
    mfUpdateFlags(FCEF_TRANSFORM);
  }

  virtual ~CRECommon()
  {
  }

  virtual void mfPrepare();
	virtual bool mfDraw(SShader *ef, SShaderPass *sfm) { return true; }
};

//////////////////////////////////////////////////////////////////////
class CREFarTreeSprites : public CRECommon
{
public:
  CREFarTreeSprites()
  {
    mfSetType(eDATA_FarTreeSprites);
    mfUpdateFlags(FCEF_TRANSFORM);
  }
  virtual bool mfDraw(SShader *ef, SShaderPass *sfm);
};

//////////////////////////////////////////////////////////////////////
class CRETerrainDetailTextureLayers: public CRECommon
{
public:
  CRETerrainDetailTextureLayers()
  {
    mfSetType(eDATA_TerrainDetailTextureLayers);
    mfUpdateFlags(FCEF_TRANSFORM);
  }
  virtual bool mfDraw(SShader *ef, SShaderPass *sfm);
};

//////////////////////////////////////////////////////////////////////
class CRETerrainParticles: public CRECommon
{
public:
  CRETerrainParticles()
  {
    mfSetType(eDATA_TerrainParticles);
    mfUpdateFlags(FCEF_TRANSFORM);
  }
  virtual bool mfDraw(SShader *ef, SShaderPass *sfm);
};

//////////////////////////////////////////////////////////////////////
class CREClearStencil : public CRECommon
{
public:
  CREClearStencil()
  {
    mfSetType(eDATA_ClearStencil);
    mfUpdateFlags(FCEF_TRANSFORM);
  }
  virtual bool mfDraw(SShader *ef, SShaderPass *sfm);
};

//////////////////////////////////////////////////////////////////////
class CREShadowMapGen: public CRECommon
{
public:

  CREShadowMapGen()
  {
    mfSetType(eDATA_ShadowMapGen);
    mfUpdateFlags(FCEF_TRANSFORM);
  }

	virtual bool mfDraw(SShader *ef, SShaderPass *sfm) { return true; }
};


#endif  // __CRECommon_H__
