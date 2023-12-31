
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: UIVideoPanel.h
//  Description: UI Video Panel Manager
//
//  History:
//  - [9/7/2003]: File created by M�rcio Martins
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef UIVIDEOPANEL_H
#define UIVIDEOPANEL_H 

#define UICLASSNAME_VIDEOPANEL			"UIVideoPanel"

#include "UIWidget.h"
#include "UISystem.h"
#include <dsound.h>

extern "C" {
	#include <libavcodec/packet.h>
}

#if !defined(WIN64) && !defined(LINUX) && !defined(NOT_USE_BINK_SDK)
#	include "../binksdk/bink.h"
#endif

class CUISystem;

struct AVFormatContext;
struct AVCodec;
struct AVCodecParameters;
struct AVCodecContext;
struct AVFrame;
struct SwsContext;
struct SwrContext;

//////////////////////////////////////////////////////////////////////
class CUIVideoPanel : public CUIWidget, public _ScriptableEx<CUIVideoPanel>
{
public:

	UI_WIDGET(CUIVideoPanel)

	CUIVideoPanel();
	~CUIVideoPanel();

	CUISystem* GetUISystem() { return m_pUISystem; }

	string GetClassName();

	int OnInit() override;

	LRESULT Update(unsigned int iMessage, WPARAM wParam, LPARAM lParam);	//AMD Port
	int Draw(int iPass);

	bool ReadVideo();
	bool DecodeAudio();
	bool DecodeVideo();
	void StreamAudio();

	int InitAudio();
	void ShutdownAudio();

	int LoadVideo(const string &szFileName, bool bSound);	

	int ReleaseVideo();
	int Play();
	int Stop();
	int Pause(bool bPause = 1);
	int IsPlaying();
	int IsPaused();

	int SetVolume(int iTrackID, float fVolume);
	int SetPan(int iTrackID, float fPan);

	int SetFrameRate(int iFrameRate);

	int EnableVideo(bool bEnable = 1);
	int EnableAudio(bool bEnable = 1);

	int OnError(const char *szError);
	int OnFinished();

	static void InitializeTemplate(IScriptSystem *pScriptSystem);

	//////////////////////////////////////////////////////////////////////
	// Script Functions
	//////////////////////////////////////////////////////////////////////
	int LoadVideo(IFunctionHandler *pH);
	int ReleaseVideo(IFunctionHandler *pH);

	int Play(IFunctionHandler *pH);
	int Stop(IFunctionHandler *pH);
	int Pause(IFunctionHandler *pH);
	
	int IsPlaying(IFunctionHandler *pH);
	int IsPaused(IFunctionHandler *pH);

	int SetVolume(IFunctionHandler *pH);
	int SetPan(IFunctionHandler *pH);

	int SetFrameRate(IFunctionHandler *pH);

	int EnableVideo(IFunctionHandler *pH);
	int EnableAudio(IFunctionHandler *pH);

	bool					m_DivX_Active;

	string				m_szVideoFile;
	bool					m_bPaused;
	bool					m_bPlaying;
	bool					m_bLooping;
	bool					m_bKeepAspect;
	int						m_iTextureID;
	UISkinTexture m_pOverlay;
	uint8_t					*m_pSwapBuffer;

	AVFormatContext* m_formatCtx;
	const AVCodec* m_videoCodec;
	AVCodecParameters* m_videoParams;
	AVCodecContext* m_videoCodecCtx;
	AVFrame* m_rawFrame;
	AVFrame* m_frame;
	SwsContext* m_swsCtx;
	int m_videoStreamIdx;
	bool m_frameReady;
	float m_frameDisplayTime;
	float m_videoStartTime;

	LPDIRECTSOUND8 m_soundDevice;
	LPDIRECTSOUNDBUFFER m_primaryBuffer;
	LPDIRECTSOUNDBUFFER m_streamingBuffer;
	DWORD m_streamingWriteOffset;

	int m_audioStreamIdx;
	const AVCodec* m_audioCodec;
	AVCodecParameters* m_audioParams;
	AVCodecContext* m_audioCodecCtx;

	std::queue<AVPacket> m_queuedVideoPackets;
	int m_queuedVideoBytes;
	std::queue<AVPacket> m_queuedAudioPackets;
	int m_queuedAudioBytes;
	SwrContext* m_swrCtx;
	std::vector<uint8_t> m_pcmBuffer;
	int m_availableAudioBytes;
	DWORD m_lastPlayPosition;
	float m_audioTime;

	float GetAudioTime();

	ICVar* vr_video_disable;
};

#endif