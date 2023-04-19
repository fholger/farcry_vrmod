#pragma once
#include "Cry_Camera.h"

struct IDirect3DDevice9Ex;

class VRRenderer
{
	typedef void (*SystemRenderFunc)(ISystem* system);

public:
	void Init(CXGame *game);
	void Shutdown();

	void Render(SystemRenderFunc renderFunc, ISystem *pSystem);
	bool OnPrePresent(IDirect3DDevice9Ex *device);
	void OnPostPresent();

	const CCamera& GetCurrentViewCamera() const;
	void ProjectToScreenPlayerCam(float ptx, float pty, float ptz, float* sx, float* sy, float* sz);

	void SetDesiredWindowSize();
	vector2di GetWindowSize() const;
	void ChangeRenderResolution(int width, int height);

	bool ShouldRenderVR() const;

	//void OnBinoculars(bool bShown) override { m_binocularsActive = bShown; }

	bool ShouldIgnoreWindowSizeChanges() const { return m_ignoreWindowSizeChanges; }

private:
	CXGame* m_pGame;
	CCamera m_originalViewCamera;
	bool m_viewCamOverridden = false;
	bool m_binocularsActive = false;
	bool m_ignoreWindowSizeChanges = false;
	int m_windowWidth = 0;
	int m_windowHeight = 0;

	void RenderSingleEye(int eye, SystemRenderFunc renderFunc, ISystem* pSystem);
	void DrawCrosshair();
};

extern VRRenderer* gVRRenderer;
