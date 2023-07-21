#pragma once
#include <openvr.h>

#undef GetUserName

class CXGame;
class VRInput;
class IDirect3DDevice9Ex;

class VRManager
{
public:
	VRManager();
	~VRManager();

	static Matrix34 OpenVRToCrysis(const vr::HmdMatrix34_t& mat);

	bool Init(CXGame *game);
	void Shutdown();

	void AwaitFrame();

	void CaptureEye(int eye);
	void CaptureHUD();

	void SetDevice(IDirect3DDevice9Ex *device);
	void FinishFrame();

	vector2di GetRenderSize() const;

	void ModifyViewCamera(int eye, CCamera& cam);

	void GetEffectiveRenderLimits(int eye, float* left, float* right, float* top, float* bottom);
	int vr_render_debug_hands;
	vr::TrackedDevicePose_t* VRManager::getHandPose(int leftRight);

private:
	struct D3DResources;

	CXGame* m_pGame;
	bool m_initialized = false;
	D3DResources* m_d3d = nullptr;
	vr::TrackedDevicePose_t m_headPose;
	vr::TrackedDevicePose_t m_poses[vr::k_unMaxTrackedDeviceCount];
	vr::IVRSystem *m_system;
	vr::VROverlayHandle_t m_hudOverlay;
	VRInput* m_vrInput;
	float m_verticalFov;
	float m_horizontalFov;
	float m_vertRenderScale;
	float m_horzRenderScale;
	float m_prevViewYaw = 0;

	void InitDevice(IDirect3DDevice9Ex* device);
	void CreateEyeTexture(int eye);
	void CreateHUDTexture();

	float vr_yaw_deadzone_angle;
	int vr_render_force_max_terrain_detail;
	ICVar* e_terrain_lod_ratio = nullptr;
	void RegisterCVars();
};

extern VRManager* gVR;
