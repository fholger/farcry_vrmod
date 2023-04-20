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

HRESULT D3D9_Present(IDirect3DDevice9Ex *pSelf, const RECT* pSourceRect, const RECT* pDestRect,HWND hDestWindowOverride, const RGNDATA* pDirtyRegion)
{
	HRESULT hr = S_OK;

	if (gVRRenderer->OnPrePresent(pSelf))
	{
		hr = hooks::CallOriginal(D3D9_Present)(pSelf, pSourceRect, pDestRect, hDestWindowOverride, pDirtyRegion);
		gVRRenderer->OnPostPresent();
	}

	return hr;
}

BOOL Hook_SetWindowPos(HWND hWnd, HWND hWndInsertAfter, int  X, int  Y, int  cx, int  cy, UINT uFlags)
{
	if (!gVRRenderer->ShouldIgnoreWindowSizeChanges())
	{
		gVRRenderer->SetDesiredWindowSize();
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
	//hooks::InstallVirtualFunctionHook("IDirect3DDevice9Ex::Present", device, &IDirect3DDevice9Ex::Present, &D3D9_Present);
	hooks::InstallHook("SetWindowPos", &SetWindowPos, &Hook_SetWindowPos);
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
		pSystem->RenderBegin();
		RenderSingleEye(eye, pSystem);
	}

	vector2di renderSize = gVR->GetRenderSize();
	m_pGame->m_pRenderer->SetScissor(0, 0, renderSize.x, renderSize.y);
	// clear render target to fully transparent for HUD render
	dxvkGetCreatedDevice()->Clear(0, nullptr, D3DCLEAR_TARGET, D3DCOLOR_ARGB(0, 0, 0, 0), 0, 0);

	if (!ShouldRenderVR())
	{
		// for things like the binoculars, we skip the stereo rendering and instead render to the 2D screen
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

void VRRenderer::SetDesiredWindowSize()
{
	m_windowWidth = m_pGame->m_pRenderer->GetWidth();
	m_windowHeight = m_pGame->m_pRenderer->GetHeight();
}

vector2di VRRenderer::GetWindowSize() const
{
	return vector2di(m_windowWidth, m_windowHeight);
}

void VRRenderer::ChangeRenderResolution(int width, int height)
{
	CryLogAlways("Changing render resolution to %i x %i", width, height);
	char cmd[16];
	m_ignoreWindowSizeChanges = true;
	snprintf(cmd, sizeof(cmd), "r_width %i", width);
	m_pGame->GetSystem()->GetIConsole()->ExecuteString(cmd);
	snprintf(cmd, sizeof(cmd), "r_height %i", height);
	m_pGame->GetSystem()->GetIConsole()->ExecuteString(cmd);
	m_pGame->m_pRenderer->ChangeResolution(width, height, 8, 0, false);
	m_pGame->m_pRenderer->EnableVSync(false);
	m_ignoreWindowSizeChanges = false;
}

bool VRRenderer::ShouldRenderVR() const
{
	//if (g_pGameCVars->vr_cutscenes_2d && g_pGame->GetIGameFramework()->GetIViewSystem()->IsPlayingCutScene())
	//	return false;

	return !m_binocularsActive;
}

void VRRenderer::RenderSingleEye(int eye, ISystem* pSystem)
{
	CCamera eyeCam = m_originalViewCamera;
	gVR->ModifyViewCamera(eye, eyeCam);
	pSystem->SetViewCamera(eyeCam);
	m_viewCamOverridden = true;
	float fov = eyeCam.GetFov();
	//m_pGame->m_pRenderer->EF_Query(EFQ_DrawNearFov, (INT_PTR)&fov);

	m_pGame->m_pRenderer->ClearColorBuffer(Vec3(0, 0, 0));

	//CFlashMenuObject* menu = static_cast<CGame*>(gEnv->pGame)->GetMenu();
	// do not render while in menu, as it shows a rotating game world that is disorienting
	if (/*!menu->IsMenuActive() &&*/ ShouldRenderVR())
	{
		pSystem->Render();
		DrawCrosshair();
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
