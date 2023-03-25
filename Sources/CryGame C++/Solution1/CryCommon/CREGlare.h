
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: CREGlare.h 
//	Description: Glare Renderer element.
//
//	History:
//	- File created by Khonich Andrey
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef __CREGLARE_H__
#define __CREGLARE_H__

//////////////////////////////////////////////////////////////////////
struct SByteColor
{
  byte r,g,b,a;
};

//////////////////////////////////////////////////////////////////////
struct SLongColor
{
  unsigned int r,g,b,a;
};

//////////////////////////////////////////////////////////////////////
class CREGlare : public CRendElement
{
public:
  int m_GlareWidth;
  int m_GlareHeight;
  float m_fGlareAmount;

public:
  CREGlare()
  {
    mfInit();
  }
  void mfInit();

  virtual ~CREGlare()
  {
  }

  virtual void mfPrepare();
  virtual bool mfDraw(SShader *ef, SShaderPass *sfm);
};

#endif  // __CREGLARE_H__
