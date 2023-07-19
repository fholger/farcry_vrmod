
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
#include <libswresample/swresample.h>
#include <libavutil/opt.h>
}

_DECLARE_SCRIPTABLEEX(CUIVideoPanel)

//////////////////////////////////////////////////////////////////////
static bool g_ffmpegInit = false;

constexpr int MAX_QUEUED_VIDEO_BYTES = 1024 * 1024;
constexpr int MAX_QUEUED_AUDIO_BYTES = 64 * 1024;

////////////////////////////////////////////////////////////////////// 
CUIVideoPanel::CUIVideoPanel()
:
#if !defined(WIN64) && !defined(LINUX) && !defined(NOT_USE_BINK_SDK)
	m_hBink(0),
#endif
	m_bLooping(1), m_bPlaying(0), m_bPaused(0), m_iTextureID(-1), m_pSwapBuffer(0), m_szVideoFile(""), m_bKeepAspect(1),
	m_formatCtx(0), m_videoCodec(0), m_videoParams(0), m_videoCodecCtx(0), m_rawFrame(0), m_frame(0), m_frameReady(false), m_swsCtx(0),
	m_soundDevice(0), m_primaryBuffer(0), m_streamingBuffer(0), m_audioCodec(0), m_audioCodecCtx(0), m_audioParams(0), m_swrCtx(0)
{
	m_DivX_Active=0;
}

////////////////////////////////////////////////////////////////////// 
CUIVideoPanel::~CUIVideoPanel()
{
	ReleaseVideo();
	ShutdownAudio();
}

////////////////////////////////////////////////////////////////////// 
string CUIVideoPanel::GetClassName()
{
	return UICLASSNAME_VIDEOPANEL;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::InitAudio()
{
	if (m_soundDevice)
	{
		return 1;
	}

	CryLogAlways("Initializing audio playback system for video panel");

	if (FAILED(DirectSoundCreate8(nullptr, &m_soundDevice, nullptr)))
	{
		CryLogAlways("Failed to create DirectSound device");
		return 0;
	}

	HWND hWnd = (HWND)m_pUISystem->GetIRenderer()->GetHWND();
	if (FAILED(m_soundDevice->SetCooperativeLevel(hWnd, DSSCL_PRIORITY)))
	{
		CryLogAlways("Failed to set cooperative level for DirectSound device");
		ShutdownAudio();
		return 0;
	}

	// create primary buffer
	DSBUFFERDESC desc = {};
	desc.dwSize = sizeof(DSBUFFERDESC);
	desc.dwFlags = DSBCAPS_PRIMARYBUFFER; // | DSBCAPS_CTRLVOLUME;
	if (FAILED(m_soundDevice->CreateSoundBuffer(&desc, &m_primaryBuffer, nullptr)))
	{
		CryLogAlways("Failed to create primary sound buffer");
		ShutdownAudio();
		return 0;
	}

	// set primary buffer format
	WAVEFORMATEX format = {};
	format.wFormatTag = WAVE_FORMAT_PCM;
	format.nChannels = 2;
	format.nSamplesPerSec = 44100;
	format.wBitsPerSample = 16;
	format.nBlockAlign = (format.nChannels * format.wBitsPerSample) / 8;
	format.nAvgBytesPerSec = format.nSamplesPerSec * format.nBlockAlign;
	if (FAILED(m_primaryBuffer->SetFormat(&format)))
	{
		CryLogAlways("Failed to set primary buffer format");
		ShutdownAudio();
		return 0;
	}

	// create streaming buffer
	DWORD bufferBytes = MAX_QUEUED_AUDIO_BYTES;
	desc.dwFlags = DSBCAPS_GLOBALFOCUS | DSBCAPS_GETCURRENTPOSITION2; // | DSBCAPS_CTRLVOLUME;
	desc.dwBufferBytes = bufferBytes;
	desc.lpwfxFormat = &format;
	if (FAILED(m_soundDevice->CreateSoundBuffer(&desc, &m_streamingBuffer, nullptr)))
	{
		CryLogAlways("Failed to create streaming buffer");
		ShutdownAudio();
		return 0;
	}

	return 1;
}

void CUIVideoPanel::ShutdownAudio()
{
	if (m_streamingBuffer)
	{
		m_streamingBuffer->Stop();
		m_streamingBuffer->Release();
		m_streamingBuffer = nullptr;
	}
	if (m_primaryBuffer)
	{
		m_primaryBuffer->Stop();
		m_primaryBuffer->Release();
		m_primaryBuffer = nullptr;
	}
	if (m_soundDevice)
	{
		m_soundDevice->Release();
		m_soundDevice = nullptr;
	}
}


////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::LoadVideo(const string &szFileName, bool bSound)
{
	CryLogAlways("Attempting to play video %s", szFileName.c_str());

	ReleaseVideo();
	InitAudio();

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

	m_videoStreamIdx = -1;
	m_audioStreamIdx = -1;
	for (int i = 0; i < m_formatCtx->nb_streams; ++i)
	{
		AVCodecParameters* params = m_formatCtx->streams[i]->codecpar;
		if (params->codec_type == AVMEDIA_TYPE_VIDEO && m_videoStreamIdx == -1)
		{
			m_videoStreamIdx = i;
			m_videoParams = params;
			m_videoCodec = avcodec_find_decoder(params->codec_id);
			CryLogAlways("Found video codec %s: resolution %d x %d", m_videoCodec->long_name, params->width, params->height);
		}
		if (params->codec_type == AVMEDIA_TYPE_AUDIO && m_audioStreamIdx == -1)
		{
			m_audioStreamIdx = i;
			m_audioParams = params;
			m_audioCodec = avcodec_find_decoder(params->codec_id);
			CryLogAlways("Found audio codec %s", m_audioCodec->long_name);
		}
	}

	if (!m_videoCodec)
	{
		ReleaseVideo();
		CryLogAlways("Failed to find video stream");
		return 0;
	}

	m_videoCodecCtx = avcodec_alloc_context3(m_videoCodec);
	avcodec_parameters_to_context(m_videoCodecCtx, m_videoParams);
	if (avcodec_open2(m_videoCodecCtx, m_videoCodec, nullptr) < 0)
	{
		ReleaseVideo();
		CryLogAlways("Failed to open video codec");
		return 0;
	}

	m_rawFrame = av_frame_alloc();
	m_frame = av_frame_alloc();

	m_swsCtx = sws_getContext(m_videoCodecCtx->width, m_videoCodecCtx->height, m_videoCodecCtx->pix_fmt, m_videoCodecCtx->width, m_videoCodecCtx->height, AV_PIX_FMT_BGRA, SWS_BILINEAR, nullptr, nullptr, nullptr);

	int numBytes = av_image_get_buffer_size(AV_PIX_FMT_BGRA, m_videoCodecCtx->width, m_videoCodecCtx->height, 1);
	m_pSwapBuffer = (uint8_t*)av_malloc(numBytes);
	av_image_fill_arrays(m_frame->data, m_frame->linesize, m_pSwapBuffer, AV_PIX_FMT_BGRA, m_videoCodecCtx->width, m_videoCodecCtx->height, 1);

    m_iTextureID = 	m_pUISystem->GetIRenderer()->DownLoadToVideoMemory(m_pSwapBuffer, m_videoCodecCtx->width, m_videoCodecCtx->height, eTF_8888, eTF_8888, 0, 0, FILTER_LINEAR, 0, NULL, FT_DYNAMIC);

	m_videoStartTime = m_pUISystem->GetISystem()->GetITimer()->GetAsyncCurTime();
	m_audioTime = m_videoStartTime;
	m_frameReady = false;

	CryLogAlways("Ready to play video");

	if (!m_audioCodec)
	{
		CryLogAlways("Did not find suitable audio codec for video file");
		return 1;
	}

	m_audioCodecCtx = avcodec_alloc_context3(m_audioCodec);
	avcodec_parameters_to_context(m_audioCodecCtx, m_audioParams);
	if (avcodec_open2(m_audioCodecCtx, m_audioCodec, nullptr) < 0)
	{
		CryLogAlways("Failed to open audio codec");
		m_audioCodec = nullptr;
		return 1;
	}

	m_swrCtx = swr_alloc();
	av_opt_set_int(m_swrCtx, "in_channel_layout", m_audioCodecCtx->channel_layout, 0);
	av_opt_set_int(m_swrCtx, "in_sample_rate", m_audioCodecCtx->sample_rate, 0);
	av_opt_set_sample_fmt(m_swrCtx, "in_sample_fmt", m_audioCodecCtx->sample_fmt, 0);
	av_opt_set_int(m_swrCtx, "out_channel_layout", AV_CH_LAYOUT_STEREO, 0);
	av_opt_set_int(m_swrCtx, "out_sample_rate", 44100, 0);
	av_opt_set_sample_fmt(m_swrCtx, "out_sample_fmt", AV_SAMPLE_FMT_S16, 0);
	swr_init(m_swrCtx);

	return 1;
}

////////////////////////////////////////////////////////////////////// 
LRESULT CUIVideoPanel::Update(unsigned int iMessage, WPARAM wParam, LPARAM lParam)	//AMD Port
{
	FUNCTION_PROFILER( m_pUISystem->GetISystem(), PROFILE_GAME );

	if ((iMessage == UIM_DRAW) && (wParam == 0))
	{
		if (m_bPlaying && m_formatCtx)
		{
			// handle video playback
			bool ok = ReadVideo();
			ok = DecodeVideo() && ok;
			ok = DecodeAudio() && ok;

			if (!ok && m_availableAudioBytes <= 0)
			{
				CryLogAlways("No frame ready, might have run into problems or end of file");
				Stop();
				OnFinished();
			}

			// we sync video playback with the audio time to keep them in sync. It's the simplest thing we can do...
			float currentTime = GetAudioTime();
			if (m_frameReady && currentTime >= m_frameDisplayTime)
			{
				if (m_iTextureID > -1)
				{
					m_pUISystem->GetIRenderer()->UpdateTextureInVideoMemory(m_iTextureID, m_pSwapBuffer, 0, 0, m_videoCodecCtx->width, m_videoCodecCtx->height, eTF_8888);
					m_frameReady = false;
				}
			}

			StreamAudio();
		}
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
	if (m_streamingBuffer)
	{
		m_streamingBuffer->Stop();
	}
	if (m_primaryBuffer)
	{
		m_primaryBuffer->Stop();
	}
	m_bPaused = 0;
	m_bPlaying = 0;
	return 1;
}

////////////////////////////////////////////////////////////////////// 
int CUIVideoPanel::ReleaseVideo()
{
	if (m_streamingBuffer)
	{
		m_streamingBuffer->Stop();
		m_streamingBuffer->SetCurrentPosition(0);
	}
	m_streamingWriteOffset = 0;
	while (!m_queuedVideoPackets.empty())
	{
		av_packet_unref(&m_queuedVideoPackets.front());
		m_queuedVideoPackets.pop();
	}
	m_queuedVideoBytes = 0;
	while (!m_queuedAudioPackets.empty())
	{
		av_packet_unref(&m_queuedAudioPackets.front());
		m_queuedAudioPackets.pop();
	}
	m_queuedAudioBytes = 0;
	m_availableAudioBytes = 0;
	m_lastPlayPosition = 0;
	m_pcmBuffer.clear();

	if (m_swrCtx)
	{
		swr_free(&m_swrCtx);
	}
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
	if (m_audioCodecCtx)
	{
		avcodec_free_context(&m_audioCodecCtx);
	}
	if (m_videoCodecCtx)
	{
		avcodec_free_context(&m_videoCodecCtx);
	}
	if (m_formatCtx)
	{
		avformat_close_input(&m_formatCtx);
	}
	m_videoCodec = nullptr;
	m_videoParams = nullptr;
	m_audioCodec = nullptr;
	m_audioParams = nullptr;

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
	if (!m_primaryBuffer)
	{
		InitAudio();
	}

	if (fVolume < 0.0f)
	{
		fVolume = 0.0f;
	}
	if (fVolume > 1.0f)
	{
		fVolume = 1.0f;
	}

	//m_primaryBuffer->SetVolume(DSBVOLUME_MIN * pow(1.0f - fVolume, 3));

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

		if (m_bKeepAspect && m_videoCodecCtx)
		{
			float fAspect = m_videoCodecCtx->width / (float)m_videoCodecCtx->height;

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

bool CUIVideoPanel::ReadVideo()
{
	if (m_queuedVideoBytes >= MAX_QUEUED_VIDEO_BYTES || m_queuedAudioBytes >= MAX_QUEUED_AUDIO_BYTES)
		return true;

	AVPacket packet;
	int result = av_read_frame(m_formatCtx, &packet);
	if (result >= 0)
	{
		if (packet.stream_index == m_videoStreamIdx)
		{
			m_queuedVideoPackets.push(packet);
			m_queuedVideoBytes += packet.size;
		}
		else if (packet.stream_index == m_audioStreamIdx)
		{
			m_queuedAudioPackets.push(packet);
			m_queuedAudioBytes += packet.size;
		}
		else
		{
			// don't need this, but must still dereference
			av_packet_unref(&packet);
		}
	}
	else
	{
		return false;
	}

	return true;
}

bool CUIVideoPanel::DecodeAudio()
{
	if (!m_audioCodecCtx)
		return true;

	if (m_pcmBuffer.size() >= MAX_QUEUED_AUDIO_BYTES)
		return true;

	while (!m_queuedAudioPackets.empty())
	{
		AVPacket* packet = &m_queuedAudioPackets.front();
		int result = avcodec_send_packet(m_audioCodecCtx, packet);
		if (result == 0)
		{
			// update audio clock with processed packet's pts
			if (packet->pts != AV_NOPTS_VALUE)
			{
				m_audioTime = m_videoStartTime + packet->pts * av_q2d(m_formatCtx->streams[m_audioStreamIdx]->time_base);
			}
			m_queuedAudioBytes -= packet->size;
			av_packet_unref(packet);
			m_queuedAudioPackets.pop();
		}
		else if (result == AVERROR(EAGAIN))
		{
			// can't send any more data right now, need to try again later
			break;
		}
		else
		{
			// error occurred, or EOF
			return false;
		}
	}

	int result = avcodec_receive_frame(m_audioCodecCtx, m_rawFrame);
	if (result == 0)
	{
		size_t bufferSize = av_samples_get_buffer_size(nullptr, 2, m_rawFrame->nb_samples, AV_SAMPLE_FMT_S16, 0);
		m_pcmBuffer.resize(m_pcmBuffer.size() + bufferSize);
		uint8_t* buffer = &m_pcmBuffer[m_pcmBuffer.size() - bufferSize];
		swr_convert(m_swrCtx, &buffer, bufferSize / (2 * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16)),
			const_cast<const uint8_t**>(m_rawFrame->extended_data), m_rawFrame->nb_samples);

		m_audioTime += m_rawFrame->nb_samples / (double)m_audioCodecCtx->sample_rate;
	}
	else if (result != AVERROR(EAGAIN))
	{
		// error occurred during decoding, or EOF
		return false;
	}

	return true;
}

bool CUIVideoPanel::DecodeVideo()
{
	if (m_frameReady)
		return true;

	while (!m_queuedVideoPackets.empty())
	{
		AVPacket* packet = &m_queuedVideoPackets.front();
		int result = avcodec_send_packet(m_videoCodecCtx, packet);
		if (result == 0)
		{
			// successfully fed packet, can discard
			m_queuedVideoBytes -= packet->size;
			av_packet_unref(packet);
			m_queuedVideoPackets.pop();
		}
		else if (result == AVERROR(EAGAIN))
		{
			// can't send any more data right now, need to try again later
			break;
		}
		else
		{
			// some error occurred, or EOF
			return false;
		}
	}

	// see if we have enough data to get a finished frame
	int result = avcodec_receive_frame(m_videoCodecCtx, m_rawFrame);
	if (result == 0)
	{
		sws_scale(m_swsCtx, m_rawFrame->data, m_rawFrame->linesize, 0, m_videoCodecCtx->height, m_frame->data, m_frame->linesize);
		m_frameReady = true;
		m_frameDisplayTime = m_videoStartTime + m_rawFrame->best_effort_timestamp * av_q2d(m_formatCtx->streams[m_videoStreamIdx]->time_base);
	}
	else if (result != AVERROR(EAGAIN))
	{
		// error occurred during decoding, or EOF
		return false;
	}

	return true;
}

void CUIVideoPanel::StreamAudio()
{
	if (!m_streamingBuffer || !m_primaryBuffer)
		return;

	// check status of primary sound buffer
	DWORD status;
	m_primaryBuffer->GetStatus(&status);
	if (!(status & DSBSTATUS_PLAYING))
	{
		CryLogAlways("Primary buffer was not playing, starting");
		m_primaryBuffer->Play(0, 0, DSBPLAY_LOOPING);
	}
	if (status & DSBSTATUS_BUFFERLOST)
	{
		CryLogAlways("Lost primary sound buffer, trying to restore");
		m_primaryBuffer->Restore();
	}

	DWORD playPos;
	m_streamingBuffer->GetCurrentPosition(&playPos, nullptr);
	if (m_lastPlayPosition <= playPos)
		m_availableAudioBytes -= (playPos - m_lastPlayPosition);
	else
		m_availableAudioBytes -= (MAX_QUEUED_AUDIO_BYTES - m_lastPlayPosition + playPos);
	m_lastPlayPosition = playPos;
	if (m_streamingWriteOffset == MAX_QUEUED_AUDIO_BYTES)
		m_streamingWriteOffset = 0;
	if (m_availableAudioBytes < 0)
	{
		m_streamingBuffer->SetCurrentPosition(0);
		m_streamingWriteOffset = 0;
	}

	if (m_availableAudioBytes >= MAX_QUEUED_AUDIO_BYTES / 2 || m_pcmBuffer.empty())
		return;

	DWORD bytesToWrite = (m_streamingWriteOffset < playPos ? playPos : MAX_QUEUED_AUDIO_BYTES) - m_streamingWriteOffset;
	bytesToWrite = min(bytesToWrite, m_pcmBuffer.size());

	void* buf1, * buf2;
	DWORD size1, size2;
	HRESULT result = m_streamingBuffer->Lock(m_streamingWriteOffset, bytesToWrite, &buf1, &size1, &buf2, &size2, 0);
	if (result == DS_OK)
	{
		memcpy(buf1, &m_pcmBuffer[0], size1);
		m_streamingWriteOffset += size1;
		m_streamingBuffer->Unlock(buf1, size1, buf2, size2);
		m_pcmBuffer.erase(m_pcmBuffer.begin(), m_pcmBuffer.begin() + size1);
		m_availableAudioBytes += size1;

		// start playing if necessary
		DWORD status;
		m_streamingBuffer->GetStatus(&status);
		if (!(status & DSBSTATUS_PLAYING))
		{
			m_streamingBuffer->Play(0, 0, DSBPLAY_LOOPING);
		}
	}
	else if (result == DSERR_BUFFERLOST)
	{
		CryLogAlways("Lost streaming sound buffer, trying to restore");
		m_streamingBuffer->Restore();
		m_streamingWriteOffset = 0;
	}
	else
	{
		CryLogAlways("Unknown error when locking streaming buffer: %i", result);
	}
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

float CUIVideoPanel::GetAudioTime()
{
	if (!m_audioCodecCtx)
	{
		// if we don't have an audio track, fall back to system clock
		return m_pUISystem->GetISystem()->GetITimer()->GetAsyncCurTime();
	}

	int remainingAudioBytes = m_availableAudioBytes + m_pcmBuffer.size();
	int bytesPerSec = 44100 * 2 * sizeof(int16_t);

	// m_audioTime is estimated time at the end of all processed data, need to subtract the amount that hasn't been played, yet
	return m_audioTime - (float)remainingAudioBytes / bytesPerSec;
}
