#include "StdAfx.h"
#include "VRManager.h"
#include "Cry_Camera.h"
#include "xplayer.h"
#include "ComPtr.h"
#include <vulkan/vulkan.h>

//#include <d3d9_interfaces.h>
#include <d3d9.h>
#include <openvr.h>

#include "VRRenderer.h"


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

struct VRManager::D3DResources
{
	ComPtr<IDirect3DDevice9Ex> device;
	ComPtr<IDirect3DTexture9> hudTexture;
	ComPtr<IDirect3DTexture9> eyeTextures[2];
};

VRManager::VRManager()
{
	m_d3d = new D3DResources;
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
	vr::HmdMatrix34_t transform;
	memset(&transform, 0, sizeof(vr::HmdMatrix34_t));
	transform.m[0][0] = transform.m[1][1] = transform.m[2][2] = 1;
	transform.m[0][3] = 0;
	transform.m[1][3] = 0;
	transform.m[2][3] = -2.f;
	vr::VROverlay()->SetOverlayTransformAbsolute(m_hudOverlay, vr::TrackingUniverseSeated, &transform);
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

	m_referencePosition = Vec3(0, 0, 0);
	m_referenceYaw = 0;

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

void VRManager::AwaitFrame()
{
	if (!m_initialized || !m_d3d->device)
		return;

	dxvkLockSubmissionQueue(m_d3d->device.Get(), false);
	vr::VRCompositor()->WaitGetPoses(&m_headPose, 1, nullptr, 0);
	dxvkReleaseSubmissionQueue(m_d3d->device.Get());

	UpdateHmdTransform();
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
		if (error != vr::VRCompositorError_None)
		{
			CryLogAlways("Submitting eye texture failed: %i", error);
		}
	}

	vr::Texture_t texInfo;
	texInfo.eColorSpace = vr::ColorSpace_Auto;
	texInfo.eType = vr::TextureType_Vulkan;
	texInfo.handle = (void*)&vkTexData[2];
	vr::VROverlay()->SetOverlayTexture(m_hudOverlay, &texInfo);

	vr::VRCompositor()->PostPresentHandoff();
	dxvkReleaseSubmissionQueue(m_d3d->device.Get());

	for (int eye = 0; eye < 3; ++eye)
	{
		IDirect3DTexture9 *tex = eye == 2 ? m_d3d->hudTexture.Get() : m_d3d->eyeTextures[eye].Get();
		dxvkTransitionImageLayout(m_d3d->device.Get(), tex, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, origLayout[eye]);
	}

	if (vr_render_force_max_terrain_detail != 0)
	{
		// make sure terrain is rendered at max detail pretty much everywhere
		e_terrain_lod_ratio->Set(0.1f);
	}
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
	if (!UseMotionControllers())
		return;

	m_input.ProcessInput();
	ProcessRoomscale();
}

bool VRManager::UseMotionControllers() const
{
	return (m_inputReady && vr_enable_motion_controllers && !m_pGame->IsMultiplayer());
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

void VRManager::ProcessRoomscale()
{
	CPlayer* player = m_pGame->GetLocalPlayer();
	if (!player || m_pGame->IsCutSceneActive() || !gVRRenderer->ShouldRenderVR() || m_pGame->IsInMenu())
	{
		m_skippedRoomscaleMovement = true;
		return;
	}

	Matrix34 rawHmdTransform = OpenVRToFarCry(m_headPose.mDeviceToAbsoluteTracking);
	Ang3 rawAngles;
	rawAngles.SetAnglesXYZ((Matrix33)rawHmdTransform);

	if (m_skippedRoomscaleMovement)
	{
		// if we previously skipped roomscale movement, reset our offsets to not accidentally move way too much
		m_referencePosition = rawHmdTransform.GetTranslation();
		m_referenceYaw = rawAngles.z;
		UpdateHmdTransform();
		m_skippedRoomscaleMovement = false;
	}

	if (!player->GetVehicle())
	{
		Vec3 offset = m_hmdTransform.GetTranslation();
		player->ProcessRoomscaleMovement(offset);
		m_referencePosition = rawHmdTransform.GetTranslation();
	}

	Ang3 angles;
	angles.SetAnglesXYZ((Matrix33)m_hmdTransform);
	m_pGame->GetClient()->TriggerRoomscaleTurn(RAD2DEG(angles.z), RAD2DEG(angles.x));
	m_referenceYaw = rawAngles.z;

	UpdateHmdTransform();
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
	console->Register("vr_enable_motion_controllers", &vr_enable_motion_controllers, 0, VF_DUMPTODISK, "Enable this to use VR motion controllers instead of keyboard+mouse");
	console->Register("vr_render_force_max_terrain_detail", &vr_render_force_max_terrain_detail, 1, VF_DUMPTODISK, "If enabled, will force terrain to render at max detail even in the distance");

	e_terrain_lod_ratio = console->GetCVar("e_terrain_lod_ratio");

	// disable motion blur, as it does not work properly in VR
	console->GetCVar("r_MotionBlur")->ForceSet("0");
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
