
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: CREFlashBang.h
//	Description: Renderer element, simple fx.
//
//	History:
//	- File created by Tiago Sousa / Last Update: 15/04/2003
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef __CREFLASHBANG_H__
#define __CREFLASHBANG_H__

//////////////////////////////////////////////////////////////////////
class CREFlashBang : public CRendElement
{

public:

  CREFlashBang():m_fTimeScale(1.0f), m_bIsActive(0),  m_fPosX(200), m_fPosY(100), m_fSizeX(400), m_fSizeY(400), m_fFlashTimeOut(1.0f)
  {
    mfSetType(eDATA_FlashBang);
    mfUpdateFlags(FCEF_TRANSFORM);
  };

  virtual ~CREFlashBang()
  {
  };

  virtual void mfPrepare();
  virtual bool mfDraw(SShader *ef, SShaderPass *sfm);

  // set/get methods

  // activate flashbang
  void SetIsActive(bool bActive)
  {
    m_bIsActive=bActive;
    
    // reset flash time out
    if(m_bIsActive)
      m_fFlashTimeOut=1.0f;
  };

  bool GetIsActive(void)
  {
    return m_bIsActive;
  };

  // set speed of flash bang fade out
  void SetTimeScale(float fTimeScale)
  {
    m_fTimeScale=fTimeScale;
  };

  float GetTimeScale(void)
  {
    return m_fTimeScale;
  };

  // set flashbang flash properties, fPosX/fPosY - position in screen space, sizeX/sizeY flash size
  void SetProperties(float fPosX, float fPosY, float fSizeX, float fSizeY)
  {
    m_fPosX=fPosX;
    m_fPosY=fPosY;
    m_fSizeX=fSizeX;
    m_fSizeY=fSizeY;
  };

  void GetProperties(float &fPosX, float &fPosY, float &fSizeX, float &fSizeY)
  {
    fPosX=m_fPosX;
    fPosY=m_fPosY;
    fSizeX=m_fSizeX;
    fSizeY=m_fSizeY;
  };

  float GetFlashTimeOut(void)
  {
    return m_fFlashTimeOut;
  };
  
private:
  // active flag
  bool  m_bIsActive;
  // time scale
  float m_fTimeScale, m_fFlashTimeOut;
  // flashbang flash properties
  float m_fPosX, m_fPosY, m_fSizeX, m_fSizeY;
};

#endif
