#include "StdAfx.h"
#include "VRManager.h"
#include "Cry_Camera.h"
#include "xplayer.h"
#include "ComPtr.h"
#include <vulkan/vulkan.h>

//#include <d3d9_interfaces.h>
#include <d3d9.h>
#include <openvr.h>

#include "UISystem.h"
#include "VRRenderer.h"
#include "WeaponClass.h"


VRManager s_VRManager;
VRManager* gVR = &s_VRManager;

extern "C" void dxvkLockSubmissionQueue(IDirect3DDevice9Ex * device, bool flush);
extern "C" void dxvkReleaseSubmissionQueue(IDirect3DDevice9Ex * device);
extern "C" HRESULT dxvkFillVulkanTextureInfo(IDirect3DDevice9Ex * device, IDirect3DTexture9 * texture, vr::VRVulkanTextureData_t & data, VkImageLayout & layout);
extern "C" void dxvkTransitionImageLayout(IDirect3DDevice9Ex * device, IDirect3DTexture9 * texture, VkImageLayout from, VkImageLayout to);

// OpenVR: x = right, y = up, -z = forward
// FarCry: x = left, -y = forward, z = up
Matrix34 OpenVRToFarCry(const vr::HmdMatrix34_t &mat)
{
	Matrix34 m;
	m.m00 = mat.m[0][0];
	m.m01 = -mat.m[0][2];
	m.m02 = -mat.m[0][1];
	m.m03 = -mat.m[0][3];
	m.m10 = -mat.m[2][0];
	m.m11 = mat.m[2][2];
	m.m12 = mat.m[2][1];
	m.m13 = mat.m[2][3];
	m.m20 = -mat.m[1][0];
	m.m21 = mat.m[1][2];
	m.m22 = mat.m[1][1];
	m.m23 = mat.m[1][3];
	return m;
}

vr::HmdMatrix34_t FarCryToOpenVR(const Matrix34& mat)
{
	vr::HmdMatrix34_t res;
	res.m[0][0] = mat.m00;
	res.m[0][1] = -mat.m02;
	res.m[0][2] = -mat.m01;
	res.m[0][3] = -mat.m03;
	res.m[1][0] = -mat.m20;
	res.m[1][1] = mat.m22;
	res.m[1][2] = mat.m21;
	res.m[1][3] = mat.m23;
	res.m[2][0] = -mat.m10;
	res.m[2][1] = mat.m12;
	res.m[2][2] = mat.m11;
	res.m[2][3] = mat.m13;
	return res;
}

struct VRManager::D3DResources
{
	ComPtr<IDirect3DDevice9Ex> device;
	ComPtr<IDirect3DTexture9> hudTexture;
	ComPtr<IDirect3DTexture9> eyeTextures[2];
};

VRManager::VRManager()
{
	m_d3d = new D3DResources;
	m_hmdTransform = Matrix34::CreateIdentity();
}


VRManager::~VRManager()
{
	// if Shutdown isn't properly called, we will get an infinite hang when trying to dispose of our D3D resources after
	// the game already shut down. So just let go here to avoid that
	m_d3d->device.Detach();
	delete m_d3d;
}

bool VRManager::Init(CXGame *game)
{
	if (m_initialized)
		return true;

	m_pGame = game;

	vr::EVRInitError error;
	vr::VR_Init(&error, vr::VRApplication_Scene);
	if (error != vr::VRInitError_None)
	{
		CryError("Failed to initialize OpenVR: %s", vr::VR_GetVRInitErrorAsEnglishDescription(error));
		return false;
	}

	vr::VRCompositor()->SetTrackingSpace(vr::TrackingUniverseSeated);

	vr::VROverlay()->CreateOverlay("CrysisHud", "Crysis HUD", &m_hudOverlay);
	vr::VROverlay()->SetOverlayWidthInMeters(m_hudOverlay, 2.f);

	SetHudFixed();
	vr::VROverlay()->ShowOverlay(m_hudOverlay);

	float ll, lr, lt, lb, rl, rr, rt, rb;
	vr::VRSystem()->GetProjectionRaw(vr::Eye_Left, &ll, &lr, &lt, &lb);
	vr::VRSystem()->GetProjectionRaw(vr::Eye_Right, &rl, &rr, &rt, &rb);
	CryLogAlways(" Left eye - l: %.2f  r: %.2f  t: %.2f  b: %.2f", ll, lr, lt, lb);
	CryLogAlways("Right eye - l: %.2f  r: %.2f  t: %.2f  b: %.2f", rl, rr, rt, rb);
	m_verticalFov = max(max(fabsf(lt), fabsf(lb)), max(fabsf(rt), fabsf(rb)));
	m_horizontalFov = max(max(fabsf(ll), fabsf(lr)), max(fabsf(rl), fabsf(rr)));
	m_vertRenderScale = 2.f * m_verticalFov / min(fabsf(lt) + fabsf(lb), fabsf(rt) + fabsf(rb));
	CryLogAlways("VR vert fov: %.2f  horz fov: %.2f  vert scale: %.2f", m_verticalFov, m_horizontalFov, m_vertRenderScale);

	RegisterCVars();

	m_inputReady = m_input.Init(game);
	m_vrHaptics.Init(game, &m_input);

	m_hmdTransform = Matrix34::CreateIdentity();
	m_referencePosition = Vec3(0, 0, 0);
	m_referenceYaw = 0;
	m_uncommittedReferenceYaw = 0;
	m_uncommittedReferencePosition = Vec3(0, 0, 0);

	m_initialized = true;
	return true;
}

void VRManager::Shutdown()
{
	m_d3d->device.Reset();

	if (!m_initialized)
		return;

	vr::VROverlay()->DestroyOverlay(m_hudOverlay);
	vr::VR_Shutdown();
	m_initialized = false;
}

void VRManager::Update()
{
	if (!m_initialized)
		return;

	m_vrHaptics.Update();
	HandleEvents();
	if (vr_window_width != m_curWindowWidth || vr_window_height != m_curWindowHeight)
	{
		m_pGame->m_pRenderer->ChangeResolution(vr_window_width, vr_window_height, 32, 0, false);
		m_curWindowWidth = vr_window_width;
		m_curWindowHeight = vr_window_height;
	}
}

void VRManager::AwaitFrame()
{
	if (!m_initialized || !m_d3d->device)
		return;

	dxvkLockSubmissionQueue(m_d3d->device.Get(), false);
	vr::VRCompositor()->WaitGetPoses(&m_headPose, 1, nullptr, 0);
	dxvkReleaseSubmissionQueue(m_d3d->device.Get());

	UpdateHmdTransform();
}

void VRManager::HandleEvents()
{
	vr::VREvent_t event;
	while (vr::VRSystem()->PollNextEvent(&event, sizeof(vr::VREvent_t)))
	{
		if (event.eventType == vr::VREvent_SeatedZeroPoseReset)
		{
			m_referencePosition.Set(0, 0, 0);
			m_referenceYaw = 0;
			UpdateHmdTransform();
		}
		if (event.eventType == vr::VREvent_Quit)
		{
			vr::VRSystem()->AcknowledgeQuit_Exiting();
			m_pGame->GetSystem()->Quit();
		}
		if (event.eventType == vr::VREvent_DashboardActivated)
		{
			m_pGame->GotoMenu(false);
		}
	}
}

void VRManager::CaptureEye(int eye)
{
	if (!m_d3d->device)
		return;

	if (!m_d3d->eyeTextures[eye])
	{
		CreateEyeTexture(eye);
		if (!m_d3d->eyeTextures[eye])
			return;
	}

	D3DSURFACE_DESC desc;
	m_d3d->eyeTextures[eye]->GetLevelDesc(0, &desc);
	vector2di expectedSize = GetRenderSize();
	if (desc.Width != expectedSize.x || desc.Height != expectedSize.y)
	{
		// recreate with new resolution
		CreateEyeTexture(eye);
		if (!m_d3d->eyeTextures[eye])
			return;
	}

	// acquire and copy the current swap chain buffer to the eye texture
	ComPtr<IDirect3DSurface9> backBuffer;
	m_d3d->device->GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, backBuffer.GetAddressOf());
	ComPtr<IDirect3DSurface9> texSurface;
	m_d3d->eyeTextures[eye]->GetSurfaceLevel(0, texSurface.GetAddressOf());
	HRESULT hr = m_d3d->device->StretchRect(backBuffer.Get(), nullptr, texSurface.Get(), nullptr, D3DTEXF_POINT);
	if (hr != S_OK)
	{
		CryLogAlways("ERROR: Capturing HUD failed: %i", hr);
	}
}

void VRManager::CaptureHUD()
{
	if (!m_d3d->device)
		return;

	if (!m_d3d->hudTexture)
	{
		CreateHUDTexture();
		if (!m_d3d->hudTexture)
			return;
	}

	D3DSURFACE_DESC desc;
	m_d3d->hudTexture->GetLevelDesc(0, &desc);
	vector2di expectedSize = GetRenderSize();
	if (desc.Width != expectedSize.x || desc.Height != expectedSize.y)
	{
		// recreate with new resolution
		CreateHUDTexture();
		if (!m_d3d->hudTexture)
			return;
	}

	// acquire and copy the current back buffer to the HUD texture
	ComPtr<IDirect3DSurface9> backBuffer;
	m_d3d->device->GetBackBuffer(0, 0, D3DBACKBUFFER_TYPE_MONO, backBuffer.GetAddressOf());
	ComPtr<IDirect3DSurface9> texSurface;
	m_d3d->hudTexture->GetSurfaceLevel(0, texSurface.GetAddressOf());
	HRESULT hr = m_d3d->device->StretchRect(backBuffer.Get(), nullptr, texSurface.Get(), nullptr, D3DTEXF_POINT);
	if (hr != S_OK)
	{
		CryLogAlways("ERROR: Capturing HUD failed: %i", hr);
	}
}

void VRManager::MirrorEyeToBackBuffer()
{
	if (!gVRRenderer->ShouldRenderVR() || gVRRenderer->ShouldRender2D())
		return;

	int eye = clamp_tpl(vr_mirrored_eye, 0, 1);

	if (!m_d3d->device || !m_d3d->eyeTextures[eye] || m_pGame->IsInMenu())
		return;

	// figure out aspect ratio correction
	float windowAspect = (float)vr_window_width / vr_window_height;
	float vrAspect = (float)m_pGame->m_pRenderer->GetWidth() / m_pGame->m_pRenderer->GetHeight();
	float scale = vrAspect / windowAspect;

	Vec2 size;
	if (scale < 1.f)
	{
		// mirror view is wider than rendered eye
		size.x = 1.f;
		size.y = scale;
	} else
	{
		// rendered eye is wider than mirror view
		size.x = scale;
		size.y = 1.f;
	}
	Vec2 offset(.5f - .5f * size.x, .5f - .5f * size.y);

	struct Vertex
	{
		float x, y, z, w;
		float u, v;
	};
	Vertex vertices[4] =
	{
		{ -0.5f, -0.5f, 0.0f, 1.0f, offset.x, offset.y },
		{ m_pGame->m_pRenderer->GetWidth() - 0.5f, -0.5f, 0.0f, 1.0f, offset.x + size.x, offset.y },
		{ m_pGame->m_pRenderer->GetWidth() - 0.5f, m_pGame->m_pRenderer->GetHeight() - 0.5f, 0.0f, 1.0f, offset.x + size.x, offset.y + size.y },
		{ -0.5f, m_pGame->m_pRenderer->GetHeight() - 0.5f, 0.0f, 1.0f, offset.x, offset.y + size.y },
	};

	m_pGame->m_pRenderer->ResetToDefault();

	// save current render state
	IDirect3DStateBlock9* stateBlock = nullptr;
	m_d3d->device->CreateStateBlock(D3DSBT_ALL, &stateBlock);

	// set state for fullscreen quad
	m_d3d->device->SetRenderState(D3DRS_LIGHTING, FALSE);
	m_d3d->device->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
	m_d3d->device->SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
	m_d3d->device->SetRenderState(D3DRS_ALPHABLENDENABLE, TRUE);
	m_d3d->device->SetRenderState(D3DRS_SRCBLEND, D3DBLEND_INVDESTALPHA);
	m_d3d->device->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_DESTALPHA);
	m_d3d->device->SetRenderState(D3DRS_VERTEXBLEND, FALSE);
	m_d3d->device->SetRenderState(D3DRS_FOGENABLE, FALSE);
	m_d3d->device->SetRenderState(D3DRS_SPECULARENABLE, FALSE);
	m_d3d->device->SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);
	m_d3d->device->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);
	m_d3d->device->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
	m_d3d->device->SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
	m_d3d->device->SetTexture(0, m_d3d->eyeTextures[eye].Get());
	m_d3d->device->SetFVF(D3DFVF_XYZRHW | D3DFVF_TEX1);
	m_d3d->device->SetVertexShader(nullptr);
	m_d3d->device->SetPixelShader(nullptr);

	// draw quad
	m_d3d->device->DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, vertices, sizeof(Vertex));

	// restore state
	if (stateBlock)
	{
		stateBlock->Apply();
		stateBlock->Release();
	}
}

void VRManager::SetDevice(IDirect3DDevice9Ex *device)
{
	if (device != m_d3d->device.Get())
		InitDevice(device);
}

void VRManager::FinishFrame()
{
	if (!m_initialized || !m_d3d->device || !m_d3d->eyeTextures[0] || !m_d3d->eyeTextures[1])
		return;

	vr::VRVulkanTextureData_t vkTexData[3];
	VkImageLayout origLayout[3];

	for (int eye = 0; eye < 3; ++eye)
	{
		IDirect3DTexture9 *tex = eye == 2 ? m_d3d->hudTexture.Get() : m_d3d->eyeTextures[eye].Get();
		HRESULT hr = dxvkFillVulkanTextureInfo(m_d3d->device.Get(), tex, vkTexData[eye], origLayout[eye]);
		if (hr != S_OK)
		{
			CryLogAlways("Fetching vulkan image info failed: %i", hr);
		}
		dxvkTransitionImageLayout(m_d3d->device.Get(), tex, origLayout[eye], VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
	}

	dxvkLockSubmissionQueue(m_d3d->device.Get(), true);

	for (int eye = 0; eye < 2; ++eye) 
	{
		// game is currently using symmetric projection, we need to cut off the texture accordingly
		vr::VRTextureBounds_t bounds;
		GetEffectiveRenderLimits(eye, &bounds.uMin, &bounds.uMax, &bounds.vMin, &bounds.vMax);

		vr::Texture_t vrTexData;
		vrTexData.eColorSpace = vr::ColorSpace_Auto;
		vrTexData.eType = vr::TextureType_Vulkan;
		vrTexData.handle = &vkTexData[eye];

		auto error = vr::VRCompositor()->Submit(eye == 0 ? vr::Eye_Left : vr::Eye_Right, &vrTexData, &bounds);
		if (error != vr::VRCompositorError_None && error != vr::VRCompositorError_AlreadySubmitted)
		{
			CryLogAlways("Submitting eye texture failed: %i", error);
		}
	}

	vr::Texture_t texInfo;
	texInfo.eColorSpace = vr::ColorSpace_Auto;
	texInfo.eType = vr::TextureType_Vulkan;
	texInfo.handle = (void*)&vkTexData[2];
	vr::VROverlay()->SetOverlayTexture(m_hudOverlay, &texInfo);

	// apparently we need to set the overlay mouse scale to some values with the proper aspect ratio, otherwise it just won't work
	vr::HmdVector2_t mouseScale;
	mouseScale.v[0] = m_pGame->m_pRenderer->GetWidth();
	mouseScale.v[1] = m_pGame->m_pRenderer->GetHeight();
	vr::VROverlay()->SetOverlayMouseScale(m_hudOverlay, &mouseScale);

	vr::VRCompositor()->PostPresentHandoff();
	dxvkReleaseSubmissionQueue(m_d3d->device.Get());

	for (int eye = 0; eye < 3; ++eye)
	{
		IDirect3DTexture9 *tex = eye == 2 ? m_d3d->hudTexture.Get() : m_d3d->eyeTextures[eye].Get();
		dxvkTransitionImageLayout(m_d3d->device.Get(), tex, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, origLayout[eye]);
	}

	m_wasBinocular = m_pGame->AreBinocularsActive();
}

vector2di VRManager::GetRenderSize() const
{
	if (!m_initialized)
		return vector2di(1280, 800);

	uint32_t width, height;
	vr::VRSystem()->GetRecommendedRenderTargetSize(&width, &height);
	height *= m_vertRenderScale;
	width = height * m_horizontalFov / m_verticalFov;
	return vector2di(width, height);
}

void VRManager::ModifyViewCamera(int eye, CCamera& cam)
{
	if (IsEquivalent(cam.GetPos(), Vec3(0, 0, 0), VEC_EPSILON))
	{
		// no valid camera set, leave it
		return;
	}

	if (!m_initialized)
	{
		if (eye == 1)
		{
			Vec3 pos = cam.GetPos();
			pos.x += 0.1f;
			cam.SetPos(pos);
		}
		return;
	}

	if (m_pGame->AreBinocularsActive() || m_wasBinocular)
	{
		cam = m_binocularOriginalPlayerCam;
	}

	Ang3 angles = cam.GetAngles();
	Vec3 position = cam.GetPos();

	angles = Deg2Rad(angles);
	// eliminate pitch and roll
	angles.y = 0;
	angles.x = 0;

	if (eye == 0)
	{
		// manage the aiming deadzone in which the camera should not be rotated
		float yawAngle = DEG2RAD(AngleMod(RAD2DEG(angles.z)));
		float yawDiff = yawAngle - m_prevViewYaw;
		if (yawDiff < -gf_PI)
			yawDiff += 2 * gf_PI;
		else if (yawDiff > gf_PI)
			yawDiff -= 2 * gf_PI;

		float maxDiff = vr_yaw_deadzone_angle * gf_PI / 180.f;
		if (yawDiff > maxDiff)
			m_prevViewYaw += yawDiff - maxDiff;
		if (yawDiff < -maxDiff)
			m_prevViewYaw += yawDiff + maxDiff;
		if (m_prevViewYaw > gf_PI)
			m_prevViewYaw -= 2*gf_PI;
		if (m_prevViewYaw < -gf_PI)
			m_prevViewYaw += 2*gf_PI;

		CPlayer *pPlayer = 0;
		if (m_pGame->GetMyPlayer())
		{
			m_pGame->GetMyPlayer()->GetContainer()->QueryContainerInterface(CIT_IPLAYER,(void **)&pPlayer);
		}
		if (pPlayer && pPlayer->GetVehicle())
		{
			// don't use this while in a vehicle, it feels off
			m_prevViewYaw = angles.z;
		}
	}
	if (!UseMotionControllers())
		angles.z = m_prevViewYaw;

	Matrix34 viewMat;
	viewMat.SetRotationXYZ(angles, position);

	vr::HmdMatrix34_t eyeMatVR = vr::VRSystem()->GetEyeToHeadTransform(eye == 0 ? vr::Eye_Left : vr::Eye_Right);
	Matrix34 eyeMat = OpenVRToFarCry(eyeMatVR);
	Matrix34 headMat = m_hmdTransform;
	viewMat = viewMat * headMat * eyeMat;

	position = viewMat.GetTranslation();
	cam.SetPos(position);
	angles.SetAnglesXYZ(Matrix33(viewMat));
	angles.Rad2Deg();
	cam.SetAngle(angles);

	// we don't have obvious access to the projection matrix, and the camera code is written with symmetric projection in mind
	// for now, set up a symmetric FOV and cut off parts of the image during submission
	vector2di renderSize = GetRenderSize();
	float vertFovAngle = atanf(m_verticalFov) * 2;
	float horzFovAngle = vertFovAngle * renderSize.x / (float)renderSize.y;
	cam.Init(renderSize.x, renderSize.y, horzFovAngle, cam.GetZMax(), 0, cam.GetZMin());
	cam.Update();

	// but we can set up frustum planes for our asymmetric projection, which should help culling accuracy.
	float tanl, tanr, tant, tanb;
	vr::VRSystem()->GetProjectionRaw(eye == 0 ? vr::Eye_Left : vr::Eye_Right, &tanl, &tanr, &tant, &tanb);
	//cam.UpdateFrustumFromVRRaw(tanl, tanr, -tanb, -tant);
}

void VRManager::Modify2DCamera(CCamera& cam)
{
	// in some instances (e.g. binoculars, weapon zoom) we still want to include head movements in the camera orientation

	if (IsEquivalent(cam.GetPos(), Vec3(0, 0, 0), VEC_EPSILON))
	{
		// no valid camera set, leave it
		return;
	}

	if (m_pGame->AreBinocularsActive())
	{
		// already corrected in player cam by necessity - otherwise, the motion tracking markers just don't display at the right position
		return;
	}

	Ang3 angles = cam.GetAngles();
	Vec3 position = cam.GetPos();

	angles = Deg2Rad(angles);
	// eliminate pitch and roll
	angles.y = 0;
	angles.x = 0;

	Matrix34 viewMat = Matrix34::CreateRotationXYZ(angles, position);

	Matrix34 headMat = m_hmdTransform;
	Matrix34 modifiedViewMat = viewMat * headMat;

	position = modifiedViewMat.GetTranslation();
	cam.SetPos(position);
	angles.SetAnglesXYZ(Matrix33(modifiedViewMat));
	angles.Rad2Deg();
	cam.SetAngle(angles);

	CPlayer* player = m_pGame->GetLocalPlayer();
	if (player && player->IsWeaponZoomActive())
	{
		// set camera to weapon firing pos, instead
		Vec3 muzzlePos, muzzleAngles;
		player->GetFirePosAngles(muzzlePos, muzzleAngles);
		cam.SetPos(muzzlePos);
		cam.SetAngle(muzzleAngles);
	}
}

void VRManager::ModifyBinocularCamera(IEntityCamera* cam)
{
	m_binocularOriginalPlayerCam = cam->GetCamera();

	if (!cam || !UseMotionControllers() || !m_pGame->AreBinocularsActive())
		return;

	Ang3 angles = cam->GetAngles();
	Vec3 position = cam->GetPos();
	angles = Deg2Rad(angles);
	// eliminate pitch and roll
	angles.y = 0;
	angles.x = 0;
	Matrix34 viewMat = Matrix34::CreateRotationXYZ(angles, position);

	// set camera to off hand position, instead
	Matrix34 offset = Matrix34::CreateTranslationMat(Vec3(-vr_binocular_size / 2, 0, vr_binocular_size / 2));
	Matrix34 controllerTransform = GetControllerTransform(m_pGame->g_LeftHanded->GetIVal() == 1 ? 1 : 0);
	Matrix34 modifiedViewMat = viewMat * controllerTransform * offset;
	m_curBinocularPos = modifiedViewMat.GetTranslation();
	cam->SetPos(m_curBinocularPos);
	angles.SetAnglesXYZ(Matrix33(modifiedViewMat));
	angles.Rad2Deg();

	// smooth rotation for a more stable zoom
	Vec3 smoothedAngles = angles;
	float factor = 0.025 * (DEFAULT_FOV / cam->GetFov());
	float yawPitchDecay = powf(2.f, -m_pGame->GetSystem()->GetITimer()->GetFrameTime() / factor);
	smoothedAngles.z = angles.z + GetAngleDifference360(m_curBinocularAngles.z, angles.z) * yawPitchDecay;
	smoothedAngles.x = angles.x + GetAngleDifference360(m_curBinocularAngles.x, angles.x) * yawPitchDecay;
	m_curBinocularAngles = smoothedAngles;

	cam->SetAngles(smoothedAngles);
}

void VRManager::GetEffectiveRenderLimits(int eye, float* left, float* right, float* top, float* bottom)
{
	float l, r, t, b;
	vr::VRSystem()->GetProjectionRaw(eye == 0 ? vr::Eye_Left : vr::Eye_Right, &l, &r, &t, &b);
	*left = 0.5f + 0.5f * l / m_horizontalFov;
	*right = 0.5f + 0.5f * r / m_horizontalFov;
	*top = 0.5f - 0.5f * b / m_verticalFov;
	*bottom = 0.5f - 0.5f * t / m_verticalFov;
}

void VRManager::ProcessInput()
{
	if ((m_pGame->IsInMenu() || m_pGame->GetSystem()->GetIConsole()->IsOpened()) && UseMotionControllers())
	{
		if (!m_wasInMenu)
		{
			m_wasInMenu = true;
			m_buttonPressed = false;
			vr::VROverlay()->SetOverlayInputMethod(m_hudOverlay, vr::VROverlayInputMethod_Mouse);
			vr::VROverlay()->SetOverlayFlag(m_hudOverlay, vr::VROverlayFlags_MakeOverlaysInteractiveIfVisible, true);
			vr::VROverlay()->SetOverlayFlag(m_hudOverlay, vr::VROverlayFlags_HideLaserIntersection, true);
			m_fixedHudTransform = OpenVRToFarCry(m_headPose.mDeviceToAbsoluteTracking);
			// erase pitch and roll
			Ang3 angles;
			angles.SetAnglesXYZ((Matrix33)m_fixedHudTransform);
			angles.x = angles.y = 0;
			m_fixedHudTransform.SetRotationXYZ(angles, m_fixedHudTransform.GetTranslation());
			Vec3 dir = -((Matrix33)m_fixedHudTransform).GetColumn(1);
			m_fixedHudTransform.SetTranslation(m_fixedHudTransform.GetTranslation() + 2.f * dir);
		}
		SetHudInFrontOfPlayer();
		ProcessMenuInput();
		return;
	}

	if (m_wasInMenu)
	{
		m_wasInMenu = false;
		m_buttonPressed = false;
		vr::VROverlay()->SetOverlayInputMethod(m_hudOverlay, vr::VROverlayInputMethod_None);
		vr::VROverlay()->SetOverlayFlag(m_hudOverlay, vr::VROverlayFlags_MakeOverlaysInteractiveIfVisible, false);
	}

	if (!UseMotionControllers())
		return;

	CPlayer* player = m_pGame->GetLocalPlayer();
	if (player && player->IsWeaponZoomActive())
		SetHudAsWeaponZoom();
	else if (m_pGame->AreBinocularsActive())
		SetHudAsBinoculars();
	else
		SetHudAttachedToHead();

	m_input.ProcessInput();
	ProcessRoomscale();
}

void VRManager::ProcessMenuInput()
{
	m_mousePressed = false;
	m_mouseReleased = false;
	m_pGame->RequestStopVideo(false);

	vr::VREvent_t event;
	while (vr::VROverlay()->PollNextOverlayEvent(m_hudOverlay, &event, sizeof(vr::VREvent_t)))
	{
		if (event.eventType == vr::VREvent_MouseMove)
		{
			IMouse* mouse = m_pGame->GetSystem()->GetIInput()->GetIMouse();
			mouse->SetVScreenX(800.f * event.data.mouse.x / m_pGame->m_pRenderer->GetWidth());
			mouse->SetVScreenY(600.f * (1.f - event.data.mouse.y / m_pGame->m_pRenderer->GetHeight()));
		}
		if (event.eventType == vr::VREvent_MouseButtonDown)
		{
			if (event.data.mouse.button == vr::VRMouseButton_Left)
				m_mousePressed = true;
			m_buttonPressed = true;
			m_lastTimeButtonPressed = m_pGame->GetSystem()->GetITimer()->GetAsyncCurTime();
		}
		if (event.eventType == vr::VREvent_MouseButtonUp)
		{
			if (event.data.mouse.button == vr::VRMouseButton_Left)
				m_mouseReleased = true;
			m_buttonPressed = false;
		}
		if (event.eventType == vr::VREvent_ButtonPress)
		{
			m_buttonPressed = true;
			m_lastTimeButtonPressed = m_pGame->GetSystem()->GetITimer()->GetAsyncCurTime();
		}
		if (event.eventType == vr::VREvent_ButtonUnpress)
		{
			m_buttonPressed = false;
		}
	}

	if (m_buttonPressed && m_pGame->GetSystem()->GetITimer()->GetAsyncCurTime() - m_lastTimeButtonPressed >= 0.5f)
	{
		m_pGame->RequestStopVideo(true);
		m_buttonPressed = false;
	}
}

bool VRManager::UseMotionControllers() const
{
	return (m_inputReady && vr_enable_motion_controllers);
}

Matrix34 VRManager::GetControllerTransform(int hand)
{
	Ang3 refAngles(0, 0, m_referenceYaw);
	Matrix33 refTransform;
	refTransform.SetRotationXYZ(refAngles);
	refTransform.Transpose();
	Matrix34 rawControllerTransform = m_input.GetControllerTransform(hand);
	rawControllerTransform.SetTranslation(rawControllerTransform.GetTranslation() - m_referencePosition);
	return refTransform * rawControllerTransform;
}

void VRManager::UpdatePlayerTurnOffset(float yawDeltaDeg)
{
	m_uncommittedReferenceYaw += DEG2RAD(yawDeltaDeg);
	//UpdateHmdTransform();
}

void VRManager::UpdatePlayerMoveOffset(const Vec3& offset, const Ang3& hmdAnglesDeg)
{
	// transform offset back into raw HMD space
	Ang3 refAngles(0, 0, m_uncommittedReferenceYaw - DEG2RAD(hmdAnglesDeg.z));
	Matrix33 refTransform = Matrix33::CreateRotationXYZ(refAngles);

	Vec3 rawOffset = refTransform * offset;
	rawOffset.z = 0;
	m_uncommittedReferencePosition += rawOffset;
	UpdateHmdTransform();
}

void VRManager::OnPostPlayerCameraUpdate() 
{
	CommitYawAndOffsetChanges();
}

void VRManager::CommitYawAndOffsetChanges() 
{
	m_referenceYaw = m_uncommittedReferenceYaw;
	m_referencePosition = m_uncommittedReferencePosition;
	UpdateHmdTransform();
}

void VRManager::ProcessRoomscale()
{
	CPlayer* player = m_pGame->GetLocalPlayer();
	if (!player || m_pGame->IsCutSceneActive() || m_pGame->IsInMenu())
	{
		m_skippedRoomscaleMovement = true;
		return;
	}

	if (m_skippedRoomscaleMovement)
	{
		// if we previously skipped roomscale movement, reset our offsets to not accidentally move way too much
		Matrix34 rawHmdTransform = OpenVRToFarCry(m_headPose.mDeviceToAbsoluteTracking);
		Ang3 rawAngles;
		rawAngles.SetAnglesXYZ((Matrix33)rawHmdTransform);
		m_referencePosition = rawHmdTransform.GetTranslation();
		m_referenceYaw = rawAngles.z;
		UpdateHmdTransform();
		m_skippedRoomscaleMovement = false;
	}

	if (m_pGame->GetClient())
	{
		m_pGame->GetClient()->EnableMotionControls(m_pGame->g_LeftHanded->GetIVal() == 0);
		Vec3 hmdPos = m_hmdTransform.GetTranslation();
		Ang3 hmdAngles = ToAnglesDeg(m_hmdTransform);
		m_pGame->GetClient()->UpdateHmdTransform(hmdPos, hmdAngles);

		for (int i = 0; i < 2; ++i)
		{
			Matrix34 controllerTransform = GetControllerTransform(i);
			Vec3 controllerPos = controllerTransform.GetTranslation();
			Ang3 controllerAngles = ToAnglesDeg(controllerTransform);
			m_pGame->GetClient()->UpdateControllerTransform(i, controllerPos, controllerAngles);
		}
	}
}


void VRManager::SetHudAttachedToHead()
{
	vr::HmdMatrix34_t hudTransform;
	memset(&hudTransform, 0, sizeof(vr::HmdMatrix34_t));
	hudTransform.m[0][0] = hudTransform.m[1][1] = hudTransform.m[2][2] = 1;
	hudTransform.m[2][3] = -2.5f;
	vr::VROverlay()->SetOverlayFlag(m_hudOverlay, vr::VROverlayFlags_IgnoreTextureAlpha, false);
	vr::VROverlay()->SetOverlayWidthInMeters(m_hudOverlay, 2.f);
	vr::VROverlay()->SetOverlayTransformTrackedDeviceRelative(m_hudOverlay, vr::k_unTrackedDeviceIndex_Hmd, &hudTransform);
}

void VRManager::SetHudInFrontOfPlayer()
{
	vr::HmdMatrix34_t hudTransform = FarCryToOpenVR(m_fixedHudTransform);
	vr::VROverlay()->SetOverlayFlag(m_hudOverlay, vr::VROverlayFlags_IgnoreTextureAlpha, false);
	vr::VROverlay()->SetOverlayWidthInMeters(m_hudOverlay, 2.f);
	vr::VROverlay()->SetOverlayTransformAbsolute(m_hudOverlay, vr::TrackingUniverseSeated, &hudTransform);
}

void VRManager::SetHudFixed()
{
	vr::HmdMatrix34_t hudTransform;
	memset(&hudTransform, 0, sizeof(vr::HmdMatrix34_t));
	hudTransform.m[0][0] = hudTransform.m[1][1] = hudTransform.m[2][2] = 1;
	hudTransform.m[2][3] = -2.f;
	vr::VROverlay()->SetOverlayFlag(m_hudOverlay, vr::VROverlayFlags_IgnoreTextureAlpha, false);
	vr::VROverlay()->SetOverlayWidthInMeters(m_hudOverlay, 2.f);
	vr::VROverlay()->SetOverlayTransformAbsolute(m_hudOverlay, vr::TrackingUniverseSeated, &hudTransform);
}

void VRManager::SetHudAsBinoculars()
{
	bool leftHanded = m_pGame->g_LeftHanded->GetIVal() == 1;
	Matrix34 transform = m_input.GetControllerTransform(leftHanded ? 1 : 0);
	transform = transform * Matrix34::CreateTranslationMat(Vec3((leftHanded ? 1 : -1) * vr_binocular_size / 2, 0, vr_binocular_size / 2));
	vr::HmdMatrix34_t hudTransform = FarCryToOpenVR(transform);
	vr::VROverlay()->SetOverlayFlag(m_hudOverlay, vr::VROverlayFlags_IgnoreTextureAlpha, true);
	vr::VROverlay()->SetOverlayWidthInMeters(m_hudOverlay, vr_binocular_size);
	vr::VROverlay()->SetOverlayTransformAbsolute(m_hudOverlay, vr::TrackingUniverseSeated, &hudTransform);
}

void VRManager::SetHudAsWeaponZoom()
{
	Matrix34 transform = m_input.GetControllerTransform(m_pGame->g_LeftHanded->GetIVal() == 1 ? 1 : 0);
	Matrix34 rawHmdTransform = OpenVRToFarCry(m_headPose.mDeviceToAbsoluteTracking);
	Vec3 headPos = rawHmdTransform.GetTranslation() - Vec3(0, 0, vr_scope_size / 2);
	Vec3 fwd = transform.GetTranslation() - headPos;
	Vec3 up(0, 0, 1);
	Vec3 left = -fwd.Cross(up).GetNormalized();
	up = left.Cross(-fwd).GetNormalized();
	transform.SetMatFromVectors(left, -fwd, up, transform.GetTranslation());
	Ang3 angles = ToAnglesDeg(transform);
	angles.y = 0;
	transform.SetRotationXYZ(Deg2Rad(angles), transform.GetTranslation());
	transform = transform * Matrix34::CreateTranslationMat(Vec3(0, 0, vr_scope_size / 2));
	vr::HmdMatrix34_t hudTransform = FarCryToOpenVR(transform);
	vr::VROverlay()->SetOverlayFlag(m_hudOverlay, vr::VROverlayFlags_IgnoreTextureAlpha, true);
	vr::VROverlay()->SetOverlayWidthInMeters(m_hudOverlay, vr_scope_size);
	vr::VROverlay()->SetOverlayTransformAbsolute(m_hudOverlay, vr::TrackingUniverseSeated, &hudTransform);
}

void VRManager::InitDevice(IDirect3DDevice9Ex* device)
{
	m_d3d->hudTexture.Reset();
	m_d3d->eyeTextures[0].Reset();
	m_d3d->eyeTextures[1].Reset();

	CryLogAlways("Acquiring device...");
	m_d3d->device = device;

	//VR_InitD3D10DeviceHooks(m_device.Get());
}

void VRManager::CreateEyeTexture(int eye)
{
	if (!m_d3d->device)
		return;

	vector2di size = GetRenderSize();
	CryLogAlways("Creating eye texture %i: %i x %i", eye, size.x, size.y);
	HRESULT hr = m_d3d->device->CreateTexture(size.x, size.y, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, m_d3d->eyeTextures[eye].ReleaseAndGetAddressOf(), nullptr);
	CryLogAlways("CreateTexture2D return code: %i", hr);
}

void VRManager::CreateHUDTexture()
{
	if (!m_d3d->device)
		return;

	vector2di size = GetRenderSize();
	CryLogAlways("Creating HUD texture: %i x %i", size.x, size.y);
	HRESULT hr = m_d3d->device->CreateTexture(size.x, size.y, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, m_d3d->hudTexture.ReleaseAndGetAddressOf(), nullptr);
	CryLogAlways("CreateRenderTarget return code: %i", hr);
}

void VRManager::RegisterCVars()
{
	IConsole* console = m_pGame->GetSystem()->GetIConsole();
	console->Register("vr_yaw_deadzone_angle", &vr_yaw_deadzone_angle, 30, VF_DUMPTODISK, "Controls the deadzone angle in front of the player where weapon aim does not rotate the camera");
	console->Register("vr_enable_motion_controllers", &vr_enable_motion_controllers, 1, VF_DUMPTODISK, "Enable this to use VR motion controllers instead of keyboard+mouse");
	console->Register("vr_render_force_max_terrain_detail", &vr_render_force_max_terrain_detail, 1, VF_DUMPTODISK, "If enabled, will force terrain to render at max detail even in the distance");
	console->Register("vr_render_force_obj_draw_dist", &vr_render_force_obj_draw_dist, 0, VF_DUMPTODISK, "If enabled, will force objects and enemies to be drawn at much further distances (might result in rendering issues in some instances)");
	console->Register("vr_window_width", &vr_window_width, 1920, VF_DUMPTODISK, "Configures the Far Cry desktop window width");
	console->Register("vr_window_height", &vr_window_height, 1080, VF_DUMPTODISK, "Configures the Far Cry desktop window height");
	console->Register("vr_mirrored_eye", &vr_mirrored_eye, 1, VF_DUMPTODISK, "Which eye view is mirrored to the desktop window. 0 - left, 1 - right");
	console->Register("vr_melee_swing_threshold", &vr_melee_swing_threshold, 2.f, VF_CHEAT, "Configures speed threshold for physical swings to register as melee attacks");
	console->Register("vr_debug_draw_grip", &vr_debug_draw_grip, 0, 0, "If enabled, highlights the position of the current weapon's grip positions");
	console->Register("vr_debug_override_grip", &vr_debug_override_grip, 0, VF_CHEAT, "If enabled, overrides the weapon grip transform offsets");
	console->Register("vr_snap_turn_amount", &vr_snap_turn_amount, 0, VF_DUMPTODISK, "The amount of degrees to snap turn (set to 0 to disable snap turn)");
	console->Register("vr_smooth_turn_speed", &vr_smooth_turn_speed, 1.0f, VF_DUMPTODISK, "Determines speed of smooth turn.");
	console->Register("vr_button_long_press_time", &vr_button_long_press_time, 0.35f, VF_DUMPTODISK, "How long you need to hold a button down to register as a long press");
	console->Register("vr_haptics_effect_strength", &vr_haptics_effect_strength, 1.0f, VF_DUMPTODISK, "Modify the strength of controller haptic events. Set to 0 to disable haptics");
	console->Register("vr_weapon_pitch_offset", &vr_weapon_pitch_offset, 15.0f, VF_DUMPTODISK, "Modify the weapon grip vertical angle.");
	console->Register("vr_weapon_yaw_offset", &vr_weapon_yaw_offset, 0.0f, VF_DUMPTODISK, "Modify the weapon grip horizontal angle.");
	console->Register("vr_crosshair", &vr_crosshair, 1, VF_DUMPTODISK, "VR crosshair type. 0 - none, 1 - ball, 2 - laser");
	console->Register("vr_movement_dir", &vr_movement_dir, -1, VF_DUMPTODISK, "Movement direction reference: -1 = head, 0 = left hand, 1 = right hand");
	console->Register("vr_show_empty_hands", &vr_show_empty_hands, 1, VF_DUMPTODISK, "If enabled, draws empty player hands when appropriate");
	console->Register("vr_immersive_ladders", &vr_immersive_ladders, 1, VF_DUMPTODISK, "Climb ladders by grabbing with your hands");
	console->Register("vr_render_world_while_zoomed", &vr_render_world_while_zoomed, 1, VF_DUMPTODISK, "Keep rendering the world in VR while binoculars or weapon scopes are active - costs performance!");
	console->Register("vr_binocular_size", &vr_binocular_size, 0.4f, VF_DUMPTODISK, "Width of the binocular overlay (in meters)");
	console->Register("vr_scope_size", &vr_scope_size, 0.3f, VF_DUMPTODISK, "Width of the weapon scope overlay (in meters)");
	vr_debug_override_rh_offset = console->CreateVariable("vr_debug_override_rh_offset", "0.0 -0.1 -0.018", VF_CHEAT);
	vr_debug_override_lh_offset = console->CreateVariable("vr_debug_override_lh_offset", "0.0 -0.1 -0.018", VF_CHEAT);
	vr_debug_override_rh_angles = console->CreateVariable("vr_debug_override_rh_angles", "0.0 0.0 0.0", VF_CHEAT);

	e_terrain_lod_ratio = console->GetCVar("e_terrain_lod_ratio");
	e_detail_texture_min_fov = console->GetCVar("e_detail_texture_min_fov");

	// disable motion blur, as it does not work properly in VR
	console->GetCVar("r_MotionBlur")->ForceSet("0");

	console->Update();
}

void VRManager::UpdateHmdTransform()
{
	Ang3 refAngles(0, 0, m_referenceYaw);
	Matrix33 refTransform;
	refTransform.SetRotationXYZ(refAngles);
	refTransform.Transpose();

	Matrix34 rawHmdTransform = OpenVRToFarCry(m_headPose.mDeviceToAbsoluteTracking);
	rawHmdTransform.SetTranslation(rawHmdTransform.GetTranslation() - m_referencePosition);
	m_hmdTransform = refTransform * rawHmdTransform;
}
