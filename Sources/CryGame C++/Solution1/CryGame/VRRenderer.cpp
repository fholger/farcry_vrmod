#include "StdAfx.h"
#include "VRRenderer.h"

#include "Cry_Camera.h"
#include "Game.h"
#include "Hooks.h"
#include "VRManager.h"
#include <d3d9.h>

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
	CryLogAlways("Original view camera has FOV %.2f", m_originalViewCamera.GetFov());

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
	//if (g_pGameCVars->vr_cutscenes_2d && g_pGame->GetIGameFramework()->GetIViewSystem()->IsPlayingCutScene())
	//	return false;
	return true;

	return !m_binocularsActive;
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
		//DrawCrosshair();
	}

	pSystem->SetViewCamera(m_originalViewCamera);
	m_viewCamOverridden = false;

	gVR->CaptureEye(eye);
}

void VRRenderer::DrawCrosshair()
{
	/* FIXME
	// don't show crosshair during cutscenes
	if (m_pGame->GetIGameFramework()->GetIViewSystem()->IsPlayingCutScene())
		return;

	CPlayer *pPlayer = static_cast<CPlayer *>(m_pGame->GetIGameFramework()->GetClientActor());
	if (!pPlayer)
		return;
	if (CWeapon *weapon = pPlayer->GetWeapon(pPlayer->GetCurrentItemId(true)))
	{
		// don't draw a crosshair if the weapon laser is active
		if (weapon->IsLamLaserActivated())
			return;
	}

	const CCamera& cam = m_originalViewCamera;
	Vec3 crosshairPos = cam.GetPosition();
	Vec3 dir = cam.GetViewdir();
	dir.Normalize();
	float maxDistance = 10.f;

	std::vector<IPhysicalEntity*> skipEntities;
	skipEntities.push_back(pPlayer->GetEntity()->GetPhysics());
	if (pPlayer->GetLinkedVehicle())
	{
		skipEntities.push_back(pPlayer->GetLinkedVehicle()->GetEntity()->GetPhysics());
		IPhysicalEntity* vecSkipEnts[8];
		int numSkips = pPlayer->GetLinkedVehicle()->GetSkipEntities(vecSkipEnts, 8);
		for (int i = 0; i < numSkips; ++i)
			skipEntities.push_back(vecSkipEnts[i]);
		maxDistance = 16.f;
	}
	const int objects = ent_all;
	const int flags = (geom_colltype_ray << rwi_colltype_bit) | rwi_colltype_any | (10 & rwi_pierceability_mask) | (geom_colltype14 << rwi_colltype_bit);

	ray_hit hit;
	if (gEnv->pPhysicalWorld->RayWorldIntersection(crosshairPos, dir*maxDistance, objects, flags, &hit, 1, skipEntities.data(), skipEntities.size()))
	{
		crosshairPos = hit.pt;
	}
	else
	{
		crosshairPos += dir * maxDistance;
	}

	// for the moment, draw something primitive with the debug tools. Maybe later we can find something more elegant...
	SAuxGeomRenderFlags geomMode;
	geomMode.SetDepthTestFlag(e_DepthTestOff);
	geomMode.SetMode2D3DFlag(e_Mode3D);
	geomMode.SetDrawInFrontMode(e_DrawInFrontOn);
	gEnv->pRenderer->GetIRenderAuxGeom()->SetRenderFlags(geomMode);
	gEnv->pRenderer->GetIRenderAuxGeom()->DrawSphere(crosshairPos, 0.03f, ColorB(240, 240, 240));
	gEnv->pRenderer->GetIRenderAuxGeom()->Flush();
	*/
}
