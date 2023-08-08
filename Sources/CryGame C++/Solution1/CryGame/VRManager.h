#pragma once
#include <openvr.h>
#include "VRInput.h"

#undef GetUserName

class CWeaponClass;
class CXGame;
class IDirect3DDevice9Ex;

Matrix34 OpenVRToFarCry(const vr::HmdMatrix34_t& mat);

class VRManager
{
public:
	VRManager();
	~VRManager();

	bool Init(CXGame *game);
	void Shutdown();

	void AwaitFrame();
	void HandleEvents();

	void CaptureEye(int eye);
	void CaptureHUD();

	void MirrorEyeToBackBuffer();

	void SetDevice(IDirect3DDevice9Ex *device);
	void FinishFrame();

	vector2di GetRenderSize() const;

	void ModifyViewCamera(int eye, CCamera& cam);
	void Modify2DCamera(CCamera& cam);

	void GetEffectiveRenderLimits(int eye, float* left, float* right, float* top, float* bottom);

	void ProcessInput();
	void ProcessMenuInput();

	bool MousePressed() const { return m_mousePressed; }
	bool MouseReleased() const { return m_mouseReleased; }

	bool UseMotionControllers() const;
	Matrix34 GetControllerTransform(int hand);

	void UpdatePlayerTurnOffset(float yawDeltaDeg);
	void UpdatePlayerMoveOffset(const Vec3& offset, const Ang3& hmdAnglesDeg);

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

	void SetHudAttachedToHead();
	void SetHudInFrontOfPlayer();
	void SetHudFixed();

	void InitDevice(IDirect3DDevice9Ex* device);
	void CreateEyeTexture(int eye);
	void CreateHUDTexture();

public:
	// VR-specific cvars
	float vr_yaw_deadzone_angle;
	int vr_render_force_max_terrain_detail;
	int vr_enable_motion_controllers;
	int vr_window_width;
	int vr_window_height;
	int vr_mirrored_eye;
	int vr_debug_draw_grip;
	int vr_debug_override_grip;
	float vr_melee_swing_threshold;
	int vr_snap_turn_amount;
	float vr_smooth_turn_speed;
	ICVar* vr_debug_override_rh_offset = nullptr;
	ICVar* vr_debug_override_rh_angles = nullptr;
	ICVar* vr_debug_override_lh_offset = nullptr;
	ICVar* e_terrain_lod_ratio = nullptr;

private:
	void RegisterCVars();

	VRInput m_input;

	Vec3 m_referencePosition;
	float m_referenceYaw = 0;
	Matrix34 m_hmdTransform;
	bool m_skippedRoomscaleMovement = false;
	bool m_wasInMenu = false;
	bool m_mousePressed = false;
	bool m_mouseReleased = false;

	void UpdateHmdTransform();
	void ProcessRoomscale();
};

extern VRManager* gVR;
