#pragma once
#include <openvr.h>

#undef GetUserName

class VRInput
{
public:
	bool Init(CXGame* game);

	void ProcessInput();
	void ProcessInputOnFoot();
	void ProcessInputInVehicles();
	void ProcessInputBinoculars();

	void TriggerHaptics(int hand, float amplitude, float frequency, float duration);

	Matrix34 GetControllerTransform(int hand);

private:
	struct DoubleBindAction
	{
		vr::VRActionHandle_t handle = vr::k_ulInvalidActionHandle;
		bool isPressed = false;
		float timeFirstPressed = 0;
	};

	CXGame* m_pGame = nullptr;

	vr::VRActionSetHandle_t m_defaultSet = vr::k_ulInvalidActionSetHandle;
	vr::VRActionSetHandle_t m_moveSet = vr::k_ulInvalidActionSetHandle;
	vr::VRActionSetHandle_t m_weaponsSet = vr::k_ulInvalidActionSetHandle;
	vr::VRActionSetHandle_t m_vehiclesSet = vr::k_ulInvalidActionHandle;

	vr::VRInputValueHandle_t m_handHandle[2] = { vr::k_ulInvalidInputValueHandle };
	vr::VRActionHandle_t m_handPoses[2] = { vr::k_ulInvalidActionHandle };
	vr::VRActionHandle_t m_haptics = vr::k_ulInvalidActionHandle;
	DoubleBindAction m_defaultUse;
	DoubleBindAction m_defaultMenu;
	vr::VRActionHandle_t m_defaultBinoculars = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_defaultZoomIn = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_defaultZoomOut = vr::k_ulInvalidActionHandle;

	vr::VRActionHandle_t m_moveMove = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveTurn = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveSnapTurnLeft = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveSnapTurnRight = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveSprint = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveJump = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_moveCrouch = vr::k_ulInvalidActionHandle;

	vr::VRActionHandle_t m_vehiclesSteer = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_vehiclesAccelerate = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_vehiclesBrake = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_vehiclesLeave = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_vehiclesAttack = vr::k_ulInvalidActionHandle;
	vr::VRActionHandle_t m_vehiclesChangeView = vr::k_ulInvalidActionHandle;
	DoubleBindAction m_vehiclesChangeSeat;
	vr::VRActionHandle_t m_vehiclesLights = vr::k_ulInvalidActionHandle;

	vr::VRActionHandle_t m_weaponsFire = vr::k_ulInvalidActionHandle;
	DoubleBindAction m_weaponsReloadFireMode;
	DoubleBindAction m_weaponsNextDrop;
	vr::VRActionHandle_t m_weaponsGrip = vr::k_ulInvalidActionHandle;
	DoubleBindAction m_weaponsGrenades;

	using TriggerFn = void (CXClient::*)(float value, XActivationEvent ae);

	void HandleBooleanAction(vr::VRActionHandle_t actionHandle, TriggerFn trigger, bool continuous = true);
	void HandleAnalogAction(vr::VRActionHandle_t actionHandle, int axis, TriggerFn trigger);
	float GetFloatValue(vr::VRActionHandle_t actionHandle, int axis = 0);

	void InitDoubleBindAction(DoubleBindAction& action, const char* actionName);
	void HandleDoubleBindAction(DoubleBindAction& action, TriggerFn shortPressTrigger, TriggerFn longPressTrigger, bool longContinuous = true);

	bool IsHandTouchingHead(int hand, float radius = 0.3f);
};
