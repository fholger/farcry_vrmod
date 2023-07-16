
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: UIVideoPanel.cpp
//  Description: UI Video Panel Manager
//
//  History:
//  - [9/7/2003]: File created by Márcio Martins
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#include "StdAfx.h"
#include "UIVideoPanel.h"
#include "UISystem.h"

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
}

_DECLARE_SCRIPTABLEEX(CUIVideoPanel)

//////////////////////////////////////////////////////////////////////
static bool g_ffmpegInit = false;

////////////////////////////////////////////////////////////////////// 
CUIVideoPanel::CUIVideoPanel()
:
#if !defined(WIN64) && !defined(LINUX) && !defined(NOT_USE_BINK_SDK)
	m_hBink(0),
#endif
	m_bLooping(1), m_bPlaying(0), m_bPaused(0), m_iTextureID(-1), m_pSwapBuffer(0), m_szVideoFile(""), m_bKeepAspect(1),
	m_formatCtx(0), m_codec(0), m_videoParams(0), m_codecCtx(0), m_rawFrame(0), m_frame(0), m_frameReady(false), m_swsCtx(0)
{
	m_DivX_Active=0;
}

////////////////////////////////////////////////////////////////////// 
CUIVideoPanel::~CUIVideoPanel()
{
	ReleaseVideo();
}

////////////////////////////////////////////////////////////////////// 
string CUIVideoPanel::GetClassName()
{
	return UICLASSNAME_VIDEOPANEL;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::InitFfmpeg()
{
	if (g_ffmpegInit)
	{
		return 1;
	}

	g_ffmpegInit = true;
	return 1;
}


////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::LoadVideo(const string &szFileName, bool bSound)
{
	CryLogAlways("Attempting to play video %s", szFileName.c_str());

	ReleaseVideo();

	if (szFileName.empty())
	{
		return 0;
	}

	// load file
	// check for a MOD first
	const char *szPrefix=NULL;
	IGameMods *pMods=m_pUISystem->GetISystem()->GetIGame()->GetModsInterface();
	if (pMods)		
		szPrefix=pMods->GetModPath(szFileName.c_str());
			
	if(szPrefix)
	{
		if (avformat_open_input(&m_formatCtx, szPrefix, nullptr, nullptr) != 0)
			m_formatCtx = nullptr;
	}

	// try in the original folder
	if(!m_formatCtx)
	{
		if (avformat_open_input(&m_formatCtx, szFileName.c_str(), nullptr, nullptr) != 0)
		{
			CryLogAlways("Failed to open video file");
			return 0;
		}
	}

	if (avformat_find_stream_info(m_formatCtx, nullptr) < 0)
	{
		ReleaseVideo();
		CryLogAlways("Failed to find stream info");
		return 0;
	}

	for (int i = 0; i < m_formatCtx->nb_streams; ++i)
	{
		AVCodecParameters* params = m_formatCtx->streams[i]->codecpar;
		if (params->codec_type == AVMEDIA_TYPE_VIDEO)
		{
			m_streamIndex = i;
			m_videoParams = params;
			m_codec = avcodec_find_decoder(params->codec_id);
			CryLogAlways("Found video codec %s: resolution %d x %d", m_codec->long_name, params->width, params->height);
			break;
		}
	}

	if (!m_codec)
	{
		ReleaseVideo();
		CryLogAlways("Failed to find video stream");
		return 0;
	}

	m_codecCtx = avcodec_alloc_context3(m_codec);
	avcodec_parameters_to_context(m_codecCtx, m_videoParams);
	if (avcodec_open2(m_codecCtx, m_codec, nullptr) < 0)
	{
		ReleaseVideo();
		CryLogAlways("Failed to open codec");
		return 0;
	}

	m_rawFrame = av_frame_alloc();
	m_frame = av_frame_alloc();

	m_swsCtx = sws_getContext(m_codecCtx->width, m_codecCtx->height, m_codecCtx->pix_fmt, m_codecCtx->width, m_codecCtx->height, AV_PIX_FMT_BGRA, SWS_BILINEAR, nullptr, nullptr, nullptr);

	int numBytes = av_image_get_buffer_size(AV_PIX_FMT_BGRA, m_codecCtx->width, m_codecCtx->height, 1);
	m_pSwapBuffer = (uint8_t*)av_malloc(numBytes);
	av_image_fill_arrays(m_frame->data, m_frame->linesize, m_pSwapBuffer, AV_PIX_FMT_BGRA, m_codecCtx->width, m_codecCtx->height, 1);

    m_iTextureID = 	m_pUISystem->GetIRenderer()->DownLoadToVideoMemory(m_pSwapBuffer, m_codecCtx->width, m_codecCtx->height, eTF_8888, eTF_8888, 0, 0, FILTER_LINEAR, 0, NULL, FT_DYNAMIC);

	m_videoStartTime = m_pUISystem->GetISystem()->GetITimer()->GetAsyncCurTime();
	m_frameReady = false;

	CryLogAlways("Ready to play video");

	return 1;
}

////////////////////////////////////////////////////////////////////// 
LRESULT CUIVideoPanel::Update(unsigned int iMessage, WPARAM wParam, LPARAM lParam)	//AMD Port
{
	FUNCTION_PROFILER( m_pUISystem->GetISystem(), PROFILE_GAME );

	if ((iMessage == UIM_DRAW) && (wParam == 0))
	{
		// stream the frame here
		if (m_bPlaying && m_formatCtx && m_pSwapBuffer)
		{
			AVPacket packet;
			while (!m_frameReady && av_read_frame(m_formatCtx, &packet) >= 0)
			{
				if (packet.stream_index == m_streamIndex)
				{
					avcodec_send_packet(m_codecCtx, &packet);
					int result = avcodec_receive_frame(m_codecCtx, m_rawFrame);
					av_packet_unref(&packet);
					if (result == 0)
					{
						sws_scale(m_swsCtx, m_rawFrame->data, m_rawFrame->linesize, 0, m_codecCtx->height, m_frame->data, m_frame->linesize);
						m_frameReady = true;
						m_frameDisplayTime = m_videoStartTime + m_rawFrame->best_effort_timestamp * av_q2d(m_formatCtx->streams[m_streamIndex]->time_base);
						break;
					}
					else if (result == AVERROR(EAGAIN))
					{
						// need more data for the frame
						continue;
					}
					else
					{
						// error occurred during decoding
						break;
					}
				}
				else
				{
					av_packet_unref(&packet);
				}
			}

			if (!m_frameReady)
			{
				CryLogAlways("No frame ready, might have run into problems or end of file");
				Stop();
				OnFinished();
			}

			float curTime = m_pUISystem->GetISystem()->GetITimer()->GetAsyncCurTime();
			if (m_frameReady && curTime >= m_frameDisplayTime)
			{
				if (m_iTextureID > -1)
				{
					CryLogAlways("Uploading new frame contents to texture");
					m_pUISystem->GetIRenderer()->UpdateTextureInVideoMemory(m_iTextureID, m_pSwapBuffer, 0, 0, m_codecCtx->width, m_codecCtx->height, eTF_8888);
					m_frameReady = false;
				}
				
			}
		}

		return CUISystem::DefaultUpdate(this, iMessage, wParam, lParam);
	}


	return CUISystem::DefaultUpdate(this, iMessage, wParam, lParam);
}


////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::Play()
{
	if (!m_formatCtx)
	{
		if (m_szVideoFile.empty())
		{
			return 0;
		}

		if (!LoadVideo(m_szVideoFile, 1))
		{
			return 0;
		}
	}

 	m_bPlaying = 1;
	m_bPaused = 0;
	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::Stop()
{
	if (!m_formatCtx)
	{
		return 0;
	}
	m_bPaused = 0;
	m_bPlaying = 0;
	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::ReleaseVideo()
{
	if (m_swsCtx)
	{
		sws_freeContext(m_swsCtx);
		m_swsCtx = nullptr;
	}
	if (m_rawFrame)
	{
		av_frame_free(&m_rawFrame);
	}
	if (m_frame)
	{
		av_frame_free(&m_frame);
	}
	if (m_codecCtx)
	{
		avcodec_free_context(&m_codecCtx);
	}
	if (m_formatCtx)
	{
		avformat_close_input(&m_formatCtx);
	}
	m_codec = nullptr;
	m_videoParams = nullptr;

	if (m_iTextureID > -1)
	{
		m_pUISystem->GetIRenderer()->RemoveTexture(m_iTextureID);
		m_iTextureID = -1;
	}

	m_szVideoFile = "";

	if (m_pSwapBuffer)
	{
		av_free(m_pSwapBuffer);
		m_pSwapBuffer = 0;
	}

	m_frameReady = false;
	m_frameDisplayTime = 0;
	m_videoStartTime = 0;

	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::Pause(bool bPause)
{
	if (!m_formatCtx)
	{
		return 0;
	}

	m_bPaused = bPause;
	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::IsPlaying()
{
	if (!m_formatCtx)
	{
		return 0;
	}
	return (m_bPlaying ? 1 : 0);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::IsPaused()
{
	if (!m_formatCtx)
	{
		return 0;
	}
	return (m_bPaused ? 1 : 0);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::SetVolume(int iTrackID, float fVolume)
{

	if (m_DivX_Active){
		return 1;
	}

#if !defined(WIN64) && !defined(LINUX) && !defined(NOT_USE_BINK_SDK)
	if (!m_hBink)
	{
		return 0;
	}

	if (fVolume < 0.0f)
	{
		fVolume = 0.0f;
	}

	BinkSetVolume(m_hBink, iTrackID, (int)(fVolume * 32768));

	return 1;
#else
	return 0;
#endif

	return 1;
}

//////////////////////////////////////////////////////////////////////
int CUIVideoPanel::SetPan(int iTrackID, float fPan)
{
	if (m_DivX_Active){
		return 1;
	}

#if !defined(WIN64) && !defined(LINUX) && !defined(NOT_USE_BINK_SDK)
	if (!m_hBink)
	{
		return 0;
	}

	if (fPan > 1.0f)
	{
		fPan = 1.0f;
	}
	else if (fPan < -1.0f)
	{
		fPan = -1.0f;
	}

	BinkSetPan(m_hBink, 1, 32768 + (int)(fPan * 32767));
	return 1;
#else
	return 0;
#endif

	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::SetFrameRate(int iFrameRate)
{
	if (m_DivX_Active){
		return 1;
	}

#if !defined(WIN64) && !defined(LINUX) && !defined(NOT_USE_BINK_SDK)
	if (!m_hBink)	{
		return 0;
	}

	BinkSetFrameRate(iFrameRate, 1);

	return 1;
#else
	return 0;
#endif

	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::Draw(int iPass)
{
	if (iPass != 0)
	{
		return 1;
	}

	m_pUISystem->BeginDraw(this);

	// get the absolute widget rect
	UIRect pAbsoluteRect(m_pRect);

	m_pUISystem->GetAbsoluteXY(&pAbsoluteRect.fLeft, &pAbsoluteRect.fTop, m_pRect.fLeft, m_pRect.fTop, m_pParent);

	// if transparent, draw only the clipped text
	if ((GetStyle() & UISTYLE_TRANSPARENT) == 0)
	{
		// if shadowed, draw the shadow
		if (GetStyle() & UISTYLE_SHADOWED)
		{
			m_pUISystem->DrawShadow(pAbsoluteRect, UI_DEFAULT_SHADOW_COLOR, UI_DEFAULT_SHADOW_BORDER_SIZE, this);
		}
	}

	// if border is large enough to be visible, draw it
	if (m_pBorder.fSize > 0.125f)
	{
		m_pUISystem->DrawBorder(pAbsoluteRect, m_pBorder);
		m_pUISystem->AdjustRect(&pAbsoluteRect, pAbsoluteRect, m_pBorder.fSize);
	}

	// save the client area without the border,
	// to draw a greyed quad later, if disabled
	UIRect pGreyedRect = pAbsoluteRect;

	// video
	if (m_iTextureID > -1)
	{
		float fWidth = pAbsoluteRect.fWidth;
		float fHeight = pAbsoluteRect.fHeight;

		if (m_bKeepAspect && m_codecCtx)
		{
			float fAspect = m_codecCtx->width / (float)m_codecCtx->height;

			if (fAspect < 1.0f)
			{
				fWidth = fHeight * fAspect;
			}
			else
			{
				fHeight = fWidth / fAspect;
			}
		}

		if (fWidth > pAbsoluteRect.fWidth)
		{
			float fRatio = pAbsoluteRect.fWidth / fWidth;

			fWidth *= fRatio;
			fHeight *= fRatio;
		}
		if (fHeight > pAbsoluteRect.fHeight)
		{
			float fRatio = pAbsoluteRect.fHeight / fHeight;

			fWidth *= fRatio;
			fHeight *= fRatio;
		}

		UIRect pRect;

		pRect.fLeft = pAbsoluteRect.fLeft + (pAbsoluteRect.fWidth - fWidth) * 0.5f;
		pRect.fTop = pAbsoluteRect.fTop + (pAbsoluteRect.fHeight - fHeight) * 0.5f;
		pRect.fWidth = fWidth;
		pRect.fHeight = fHeight;

		if (m_bKeepAspect)
		{
			m_pUISystem->DrawQuad(pAbsoluteRect, m_cColor);
		}

		m_pUISystem->DrawImage(pRect, m_iTextureID, 0, color4f(1.0f, 1.0f, 1.0f, 1.0f));
	}

	// draw overlay
	if (m_pOverlay.iTextureID > -1)
	{
		m_pUISystem->DrawSkin(pAbsoluteRect, m_pOverlay, color4f(1.0f, 1.0f, 1.0f, 1.0f), UISTATE_UP);
	}

	// draw a greyed quad ontop, if disabled
	if ((m_iFlags & UIFLAG_ENABLED) == 0)
	{
		m_pUISystem->ResetDraw();
		m_pUISystem->DrawGreyedQuad(pGreyedRect, m_cGreyedColor, m_iGreyedBlend);
	}

	m_pUISystem->EndDraw();

	// draw the children
	if (m_pUISystem->ShouldSortByZ())
	{
		SortChildrenByZ();
	}

	DrawChildren();

	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::EnableVideo(bool bEnable)
{
	if (!m_formatCtx)
	{
		return 0;
	}

	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::EnableAudio(bool bEnable)
{
#if !defined(WIN64) && !defined(LINUX) && !defined(NOT_USE_BINK_SDK)

	if (!m_hBink)
	{
		return 0;
	}

	return BinkSetSoundOnOff(m_hBink, bEnable ? 1 : 0);
#else
	return 0;
#endif

	return 0;
}

////////////////////////////////////////////////////////////////////// 
void CUIVideoPanel::InitializeTemplate(IScriptSystem *pScriptSystem)
{
	_ScriptableEx<CUIVideoPanel>::InitializeTemplate(pScriptSystem);

	REGISTER_COMMON_MEMBERS(pScriptSystem, CUIVideoPanel);

	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, LoadVideo);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, ReleaseVideo);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, Play);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, Stop);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, Pause);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, IsPlaying);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, IsPaused);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, SetVolume);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, SetPan);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, SetFrameRate);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, EnableVideo);
	REGISTER_SCRIPTOBJECT_MEMBER(pScriptSystem, CUIVideoPanel, EnableAudio);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::OnError(const char *szError)
{
	IScriptSystem *pScriptSystem = m_pUISystem->GetIScriptSystem();
	IScriptObject *pScriptObject = m_pUISystem->GetWidgetScriptObject(this);

	if (!pScriptObject)
	{
		return 1;
	}

	HSCRIPTFUNCTION pScriptFunction = pScriptSystem->GetFunctionPtr(GetName().c_str(), "OnError");

	if (!pScriptFunction)
	{
		if (!pScriptObject->GetValue("OnError", pScriptFunction))
		{
			return 1;
		}
	}

	int iResult = 1;

	pScriptSystem->BeginCall(pScriptFunction);
	pScriptSystem->PushFuncParam(pScriptObject);
	pScriptSystem->PushFuncParam(szError);
	pScriptSystem->EndCall(iResult);

	pScriptSystem->ReleaseFunc(pScriptFunction);

	return iResult;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::OnFinished()
{
	IScriptSystem *pScriptSystem = m_pUISystem->GetIScriptSystem();
	IScriptObject *pScriptObject = m_pUISystem->GetWidgetScriptObject(this);

	if (!pScriptObject)
	{
		return 1;
	}

	HSCRIPTFUNCTION pScriptFunction = pScriptSystem->GetFunctionPtr(GetName().c_str(), "OnFinished");

	if (!pScriptFunction)
	{
		if (!pScriptObject->GetValue("OnFinished", pScriptFunction))
		{
			return 1;
		}
	}

	int iResult = 1;

	pScriptSystem->BeginCall(pScriptFunction);
	pScriptSystem->PushFuncParam(pScriptObject);
	pScriptSystem->EndCall(iResult);

	pScriptSystem->ReleaseFunc(pScriptFunction);

	return iResult;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::LoadVideo(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT2(m_pScriptSystem, GetName().c_str(), LoadVideo, 1, 2);
	CHECK_SCRIPT_FUNCTION_PARAMTYPE(m_pScriptSystem, GetName().c_str(), LoadVideo, 1, svtString);

	if (pH->GetParamCount() == 2)
	{
		CHECK_SCRIPT_FUNCTION_PARAMTYPE(m_pScriptSystem, GetName().c_str(), LoadVideo, 2, svtNumber);
	}
	
	char *pszFileName;
	int iSound = 0;

	pH->GetParam(1, pszFileName);

	if (pH->GetParamCount() == 2)
	{
		pH->GetParam(2, iSound);
	}

	if (!LoadVideo(pszFileName, iSound != 0))
	{
		return pH->EndFunctionNull();
	}

	return pH->EndFunction(1);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::ReleaseVideo(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), ReleaseVideo, 0);

	ReleaseVideo();

	return pH->EndFunction(1);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::Play(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), Play, 0);

	Play();

	return pH->EndFunction(1);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::Stop(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), Stop, 0);

	Stop();

	return pH->EndFunction(1);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::Pause(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), Pause, 1);
	CHECK_SCRIPT_FUNCTION_PARAMTYPE(m_pScriptSystem, GetName().c_str(), Pause, 1, svtNumber);

	int iPause;

	pH->GetParam(1, iPause);

	Pause(iPause != 0);

	return pH->EndFunction(1);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::IsPlaying(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), IsPlaying, 0);

	if (m_bPlaying)
	{
		return pH->EndFunction(1);
	}
	else
	{
		return pH->EndFunctionNull();
	}
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::IsPaused(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), IsPaused, 0);

	if (m_bPaused)
	{
		return pH->EndFunction(1);
	}
	else
	{
		return pH->EndFunctionNull();
	}
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::SetVolume(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), SetVolume, 1);
	CHECK_SCRIPT_FUNCTION_PARAMTYPE(m_pScriptSystem, GetName().c_str(), SetVolume, 1, svtNumber);

	float fVolume;

	pH->GetParam(1, fVolume);

	for (int i = 0; i < 16; i++)
	{
		SetVolume(i, fVolume);
	}

	return pH->EndFunction(1);
}

//////////////////////////////////////////////////////////////////////
int CUIVideoPanel::SetPan(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), SetPan, 1);
	CHECK_SCRIPT_FUNCTION_PARAMTYPE(m_pScriptSystem, GetName().c_str(), SetPan, 1, svtNumber);

	float fPan;

	pH->GetParam(1, fPan);

	for (int i = 0; i < 16; i++)
	{
		SetPan(i, fPan);
	}

	return pH->EndFunction(1);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::SetFrameRate(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), SetFrameRate, 1);
	CHECK_SCRIPT_FUNCTION_PARAMTYPE(m_pScriptSystem, GetName().c_str(), SetFrameRate, 1, svtNumber);

	int iFrameRate;

	pH->GetParam(1, iFrameRate);

	SetFrameRate(iFrameRate);

	return pH->EndFunction(1);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::EnableVideo(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), EnableVideo, 1);
	CHECK_SCRIPT_FUNCTION_PARAMTYPE(m_pScriptSystem, GetName().c_str(), EnableVideo, 1, svtNumber);

	int iEnable;

	pH->GetParam(1, iEnable);

	EnableVideo(iEnable != 0);

	return pH->EndFunction(1);
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::EnableAudio(IFunctionHandler *pH)
{
	CHECK_SCRIPT_FUNCTION_PARAMCOUNT(m_pScriptSystem, GetName().c_str(), EnableAudio, 1);
	CHECK_SCRIPT_FUNCTION_PARAMTYPE(m_pScriptSystem, GetName().c_str(), EnableAudio, 1, svtNumber);

	int iEnable;

	pH->GetParam(1, iEnable);

	EnableAudio(iEnable != 0);
	
	return pH->EndFunction(1);
}