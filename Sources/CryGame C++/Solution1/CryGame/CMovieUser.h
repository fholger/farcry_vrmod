
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//	
//	File: GameMovieUser.h
//  Description:	Give access to movie functions from within the game. 
//	Interface for movie-system implemented by user for advanced function-support.
//
//	History:
//	- October 1 2003: Created by Timur Davidenko and Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef MOVIE_USER_H
#define MOVIE_USER_H

//////////////////////////////////////////////////////////////////////
class CMovieUser : public IMovieUser, public ISoundEventListener
{
private:
	CXGame *m_pGame;
public: 
	CMovieUser(CXGame *pGame)
	{
		m_InCutSceneCounter = 0;
		m_wPrevClientId = 0;
		m_pGame=pGame;
		m_fPrevMusicVolume=0;
	}

	// interface IMovieUser
	void SetActiveCamera(const SCameraParams &Params);
	void BeginCutScene(unsigned long dwFlags,bool bResetFX);
	void EndCutScene();
	void SendGlobalEvent(const char *pszEvent);
	void PlaySubtitles( ISound *pSound );

	// Implements ISoundEventListener.
	void OnSoundEvent( ESoundCallbackEvent event,ISound *pSound );

private:
	void ResetCutSceneParams();

	int m_InCutSceneCounter;
	int m_wPrevClientId;
	Vec3d m_vPrevClientPos;
	bool m_bSoundsPaused;
	float m_fPrevMusicVolume;
};

#endif