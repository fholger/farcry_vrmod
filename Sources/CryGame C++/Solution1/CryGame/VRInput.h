#pragma once
#include <openvr.h>
#undef GetUserName

class VRInput
{
public:
	bool Init(CXGame* game);

	void ProcessInput();
	Matrix34 GetControllerTransform(int hand);

private:
	CXGame* m_pGame = nullptr;

	vr::VRActionSetHandle_t m_defaultSet = vr::k_ulInvalidActionSetHandle;
	vr::VRActionSetHandle_t m_moveSet = vr::k_ulInvalidActionSetHandle;
	vr::VRActionSetHandle_t m_weaponsSet = vr::k_ulInvalidActionSetHandle;

	vr::VRActionHandle_t m_handPoses[2] = { vr::k_ulInvalidInputValueHandle };
	vr::VRActionHandle_t m_defaultUse = vr::k_ulInvalidInputValueHandle;
	vr::VRActionHandle_t m_defaultMenu = vr::k_ulInvalidInputValueHandle;
	vr::VRActionHandle_t m_defaultBinoculars = vr::k_ulInvalidInputValueHandle;

	vr::VRActionHandle_t m_moveMove = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveTurn = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveSprint = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveJump = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveCrouch = vr::k_ulInvalidActionHandle;

	vr::VRActionHandle_t m_weaponsFire = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_weaponsReload = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_weaponsFireMode = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_weaponsNextWeapon = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_weaponsPrevWeapon = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_weaponsAim = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_weaponsGrip = vr::k_ulInvalidActionHandle;

	using TriggerFn = void (CXClient::*)(float value, XActivationEvent ae);

	void HandleBooleanAction(vr::VRActionHandle_t actionHandle, TriggerFn trigger, bool continuous = true);
	void HandleAnalogAction(vr::VRActionHandle_t actionHandle, int axis, TriggerFn trigger);
};
