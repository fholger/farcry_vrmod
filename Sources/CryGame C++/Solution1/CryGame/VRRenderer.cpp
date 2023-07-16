#include "StdAfx.h"
#include "VRRenderer.h"

#include "Cry_Camera.h"
#include "Game.h"
#include "Hooks.h"
#include "VRManager.h"
#include <d3d9.h>

#include "WeaponClass.h"
#include "xplayer.h"
#include "XVehicle.h"

namespace
{
	VRRenderer g_vrRendererImpl;
}

VRRenderer* gVRRenderer = &g_vrRendererImpl;

BOOL Hook_SetWindowPos(HWND hWnd, HWND hWndInsertAfter, int  X, int  Y, int  cx, int  cy, UINT uFlags)
{
	if (!gVRRenderer->ShouldIgnoreWindowSizeChanges())
	{
		return hooks::CallOriginal(Hook_SetWindowPos)(hWnd, hWndInsertAfter, 0, 0, cx, cy, uFlags);
	}

	return TRUE;
}

extern "C" {
  __declspec(dllimport) IDirect3DDevice9Ex* dxvkGetCreatedDevice();
}

void VRRenderer::Init(CXGame *game)
{
	m_pGame = game;

	IDirect3DDevice9Ex* device = dxvkGetCreatedDevice();
	if (!device)
	{
		CryLogAlways("Could not get d3d9 device from dxvk");
		return;
	}

	CryLogAlways("Initializing rendering function hooks");
	//hooks::InstallHook("SetWindowPos", &SetWindowPos, &Hook_SetWindowPos);
}

void VRRenderer::Shutdown()
{
}

void VRRenderer::Render(ISystem* pSystem)
{
	m_originalViewCamera = pSystem->GetViewCamera();

	gVR->SetDevice(dxvkGetCreatedDevice());
	gVR->AwaitFrame();

	for (int eye = 0; eye < 2; ++eye)
	{
		RenderSingleEye(eye, pSystem);
	}

	vector2di renderSize = gVR->GetRenderSize();
	m_pGame->m_pRenderer->SetScissor(0, 0, renderSize.x, renderSize.y);
	// clear render target to fully transparent for HUD render
	dxvkGetCreatedDevice()->Clear(0, nullptr, D3DCLEAR_TARGET, D3DCOLOR_ARGB(0, 0, 0, 0), 0, 0);

	if (!ShouldRenderVR())
	{
		// for things like the binoculars, we skip the stereo rendering and instead render to the 2D screen
		pSystem->RenderBegin();
		pSystem->Render();
	}
}

bool VRRenderer::OnPrePresent(IDirect3DDevice9Ex *device)
{
	gVR->SetDevice(device);
	gVR->CaptureHUD();
	return true;
}

void VRRenderer::OnPostPresent()
{
	gVR->FinishFrame();
}

const CCamera& VRRenderer::GetCurrentViewCamera() const
{
	if (m_viewCamOverridden)
		return m_originalViewCamera;

	return m_pGame->m_pSystem->GetViewCamera();
}

void VRRenderer::ProjectToScreenPlayerCam(float ptx, float pty, float ptz, float* sx, float* sy, float* sz)
{
	const CCamera &currentCam = m_pGame->m_pRenderer->GetCamera();
	m_pGame->m_pRenderer->SetCamera(GetCurrentViewCamera());
	m_pGame->m_pRenderer->ProjectToScreen(ptx, pty, ptz, sx, sy, sz);
	m_pGame->m_pRenderer->SetCamera(currentCam);
}

void VRRenderer::ChangeRenderResolution(int width, int height)
{
	CryLogAlways("Changing render resolution to %i x %i", width, height);

	// Far Cry's renderer has a safeguard where it checks the window size does not exceed the desktop size
	// this is no good for VR, so we temporarily change the memory where the game stores the desktop size (as found with the debugger)
	int* desktopWidth = reinterpret_cast<int*>(reinterpret_cast<uintptr_t>(m_pGame->m_pRenderer) + 0x016808);
	int* desktopHeight = reinterpret_cast<int*>(reinterpret_cast<uintptr_t>(m_pGame->m_pRenderer) + 0x01680C);
	int oldDeskWidth = *desktopWidth;
	int oldDeskHeight = *desktopHeight;
	*desktopWidth = width + 16;
	*desktopHeight = height + 32;

	m_ignoreWindowSizeChanges = true;
	m_pGame->m_pRenderer->ChangeResolution(width, height, 32, 0, false);
	m_pGame->m_pRenderer->EnableVSync(false);
	m_ignoreWindowSizeChanges = false;

	*desktopWidth = oldDeskWidth;
	*desktopHeight = oldDeskHeight;
}

bool VRRenderer::ShouldRenderVR() const
{
	if (m_pGame->AreBinocularsActive())
		return false;

	CPlayer *player = m_pGame->GetLocalPlayer();
	if (player && player->IsWeaponZoomActive())
		return false;

	return true;
}

void VRRenderer::RenderSingleEye(int eye, ISystem* pSystem)
{
	CCamera eyeCam = m_originalViewCamera;
	gVR->ModifyViewCamera(eye, eyeCam);
	pSystem->SetViewCamera(eyeCam);
	m_viewCamOverridden = true;
	//m_pGame->m_pRenderer->EF_Query(EFQ_DrawNearFov, (INT_PTR)&fov);

	m_pGame->m_pRenderer->ClearColorBuffer(Vec3(0, 0, 0));

	//CFlashMenuObject* menu = static_cast<CGame*>(gEnv->pGame)->GetMenu();
	// do not render while in menu, as it shows a rotating game world that is disorienting
	if (/*!menu->IsMenuActive() &&*/ ShouldRenderVR())
	{
		pSystem->RenderBegin();
		pSystem->Render();
		DrawCrosshair();
	}

	pSystem->SetViewCamera(m_originalViewCamera);
	m_viewCamOverridden = false;

	gVR->CaptureEye(eye);
}

void VRRenderer::DrawCrosshair()
{
	// don't show crosshair if HUD is disabled (e.g. during cutscenes
	if (m_pGame->cl_display_hud->GetIVal() == 0)
		return;

	CPlayer* pPlayer = m_pGame->GetLocalPlayer();
	if (!pPlayer)
		return;

	const CCamera& cam = m_originalViewCamera;
	Vec3 crosshairPos = cam.GetPos();
	Matrix33 transform;
	transform.SetRotationXYZ(Deg2Rad(cam.GetAngles()));
	Vec3 dir = -transform.GetColumn(1);
	dir.Normalize();
	float maxDistance = 16.f;

	IPhysicalEntity* skipPlayer = pPlayer->GetEntity()->GetPhysics();
	IPhysicalEntity* skipVehicle = nullptr;
	if (pPlayer->GetVehicle())
	{
		skipVehicle = pPlayer->GetVehicle()->GetEntity()->GetPhysics();
		maxDistance = 24.f;
	}
	const int objects = ent_all;
	const int flags = rwi_separate_important_hits;

	ray_hit hit;
	IPhysicalWorld *physicalWorld = m_pGame->GetSystem()->GetIPhysicalWorld();
	if (physicalWorld->RayWorldIntersection(crosshairPos, dir*maxDistance, objects, flags, &hit, 1, skipPlayer, skipVehicle))
	{
		crosshairPos = hit.pt;
	}
	else
	{
		crosshairPos += dir * maxDistance;
	}

	// for the moment, draw something primitive with the debug tools. Maybe later we can find something more elegant...
	m_pGame->m_pRenderer->SetState(GS_NODEPTHTEST);
	m_pGame->m_pRenderer->DrawBall(crosshairPos - dir * 0.06f, 0.06f);
}
