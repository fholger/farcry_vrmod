#pragma once
#include <openvr.h>
#include <vulkan/vulkan_core.h>

#include "VRHaptics.h"
#include "VRInput.h"

#undef GetUserName

class CWeaponClass;
class CXGame;
class IDirect3DDevice9Ex;
class IDirect3DTexture9;

Matrix34 OpenVRToFarCry(const vr::HmdMatrix34_t& mat);

class VRManager
{
public:
	VRManager();
	~VRManager();

	bool Init(CXGame *game);
	void Shutdown();

	void Update();

	void AwaitFrame();
	void HandleEvents();

	void CaptureEye(int eye);
	void CaptureStereo(int eye);
	void CaptureHUD();

	void MirrorEyeToBackBuffer();

	void SetDevice(IDirect3DDevice9Ex *device);
	void FinishFrame();

	vector2di GetRenderSize() const;

	void ModifyViewCamera(int eye, CCamera& cam);
	void Modify2DCamera(CCamera& cam);
	void Modify3DCamera(int eye, CCamera& cam);
	void ModifyBinocularCamera(IEntityCamera* cam);

	void GetEffectiveRenderLimits(int eye, float* left, float* right, float* top, float* bottom);

	void ProcessInput();
	void ProcessMenuInput();

	bool MousePressed() const { return m_mousePressed; }
	bool MouseReleased() const { return m_mouseReleased; }

	bool UseMotionControllers() const;
	Matrix34 GetControllerTransform(int hand);
	Matrix34 GetHmdTransform() { return m_hmdTransform; }

	void UpdatePlayerTurnOffset(float yawDeltaDeg);
	void UpdatePlayerMoveOffset(const Vec3& offset, const Ang3& hmdAnglesDeg);

	void OnPostPlayerCameraUpdate();
	void CommitYawAndOffsetChanges();

	VRHaptics* GetHaptics() { return &m_vrHaptics; }

	const Vec3& GetBinocularAngles() const { return m_curBinocularAngles; }
	const Vec3& GetBinocularPos() const { return m_curBinocularPos; }

private:
	struct D3DResources;

	CXGame* m_pGame;
	bool m_initialized = false;
	bool m_inputReady = false;
	D3DResources* m_d3d = nullptr;
	vr::TrackedDevicePose_t m_headPose;
	vr::VROverlayHandle_t m_hudOverlay;
	vr::VROverlayHandle_t m_3DOverlay;
	float m_verticalFov;
	float m_horizontalFov;
	float m_vertRenderScale;
	float m_horzRenderScale;
	float m_prevViewYaw = 0;

	int m_curWindowWidth = 0;
	int m_curWindowHeight = 0;

	void SetHudAttachedToHead();
	void SetHudInFrontOfPlayer();
	void SetHudAsBinoculars();
	void SetHudAsWeaponZoom();

	void InitDevice(IDirect3DDevice9Ex* device);
	void CreateEyeTexture(int eye);
	void CreateHUDTexture();
	void CreateStereoTexture();

	void PrepareTextureForSubmission(IDirect3DTexture9* tex, vr::VRVulkanTextureData_t& vrTexData, VkImageLayout& origLayout);
	void PostSubmissionTransitionTexture(IDirect3DTexture9* tex, VkImageLayout origLayout);

public:
	// VR-specific cvars
	float vr_yaw_deadzone_angle;
	int vr_render_force_max_terrain_detail;
	int vr_render_force_obj_draw_dist;
	int vr_enable_motion_controllers;
	int vr_window_width;
	int vr_window_height;
	int vr_mirrored_eye;
	int vr_debug_draw_grip;
	int vr_debug_override_grip;
	float vr_melee_swing_threshold;
	int vr_snap_turn_amount;
	float vr_smooth_turn_speed;
	float vr_button_long_press_time;
	float vr_haptics_effect_strength;
	float vr_weapon_pitch_offset;
	float vr_weapon_yaw_offset;
	int vr_crosshair;
	int vr_movement_dir;
	int vr_show_empty_hands;
	int vr_immersive_ladders;
	int vr_render_world_while_zoomed;
	float vr_binocular_size;
	float vr_scope_size;
	int vr_seated_mode;
	int vr_cutscenes_cinema_mode;
	float vr_hud_distance;
	float vr_hud_width;
	float vr_menu_distance;
	float vr_menu_width;
	int vr_skip_vehicle_transitions;
	ICVar* vr_debug_override_rh_offset = nullptr;
	ICVar* vr_debug_override_rh_angles = nullptr;
	ICVar* vr_debug_override_lh_offset = nullptr;
	ICVar* e_terrain_lod_ratio = nullptr;
	ICVar* e_detail_texture_min_fov = nullptr;
	ICVar* e_obj_view_dist_ratio = nullptr;

private:
	void RegisterCVars();

	VRInput m_input;
	VRHaptics m_vrHaptics;

	Vec3 m_referencePosition;
	Vec3 m_uncommittedReferencePosition;
	float m_referenceYaw = 0;
	float m_uncommittedReferenceYaw = 0;
	float m_referenceHeight = -1;
	Matrix34 m_hmdTransform;
	bool m_skippedRoomscaleMovement = false;
	bool m_wasInMenu = false;
	bool m_mousePressed = false;
	bool m_mouseReleased = false;
	float m_lastTimeButtonPressed = 0;
	bool m_buttonPressed = false;

	Matrix34 m_fixedHudTransform;

	Ang3 m_curBinocularAngles;
	Vec3 m_curBinocularPos;
	CCamera m_binocularOriginalPlayerCam;
	bool m_wasBinocular = false;

	void UpdateHmdTransform();
	void ProcessRoomscale();

	void RecalibrateView();
};

extern VRManager* gVR;
