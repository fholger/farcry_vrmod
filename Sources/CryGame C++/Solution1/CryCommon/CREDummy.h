
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: CREDummy.h 
//	Description: Dummy Renderer element.
//
//	History:
//	- File created by Khonich Andrey
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef __CREDUMMY_H__
#define __CREDUMMY_H__

//////////////////////////////////////////////////////////////////////
class CREDummy : public CRendElement
{
  friend class CRender3D;

public:

  CREDummy()
  {
    mfSetType(eDATA_Dummy);
    mfUpdateFlags(FCEF_TRANSFORM);
  }

  virtual ~CREDummy()
  {
  }

  virtual void mfPrepare();
  virtual bool mfDraw(SShader *ef, SShaderPass *sfm);
};

#endif  
