#pragma once
#include <openvr.h>
#include "VRInput.h"

#undef GetUserName

class CXGame;
class IDirect3DDevice9Ex;

class VRManager
{
public:
	VRManager();
	~VRManager();

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

	void ProcessInput();
	bool UseMotionControllers() const;

private:
	struct D3DResources;

	CXGame* m_pGame;
	bool m_initialized = false;
	bool m_inputReady = false;
	D3DResources* m_d3d = nullptr;
	vr::TrackedDevicePose_t m_headPose;
	vr::VROverlayHandle_t m_hudOverlay;
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
	int vr_enable_motion_controllers;
	ICVar* e_terrain_lod_ratio = nullptr;
	void RegisterCVars();

	VRInput m_input;

	Vec3 m_referencePosition;
	float m_referenceYaw = 0;
	Matrix34 m_hmdTransform;
	bool m_skippedRoomscaleMovement = false;

	void UpdateHmdTransform();
	void ProcessRoomscale();
};

extern VRManager* gVR;
