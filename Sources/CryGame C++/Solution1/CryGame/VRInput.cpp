#include "StdAfx.h"
#include "VRInput.h"

#include "VRManager.h"
#include "WeaponClass.h"
#include "XPlayer.h"
#include "XVehicle.h"

std::string GetDLLPath()
{
	HMODULE hModule = GetModuleHandleA("CryGame.dll");
	if (hModule == nullptr)
		return "";

	char filePath[MAX_PATH];
	filePath[0] = 0;
	GetModuleFileNameA(hModule, filePath, MAX_PATH);
	return std::string(filePath);
}

std::string GetActionManifestPath()
{
	std::string dllPath = GetDLLPath();
	std::string parentPath = dllPath.substr(0, dllPath.find_last_of("\\/"));
	return parentPath + "\\..\\steamvr\\actions.json";
}

bool VRInput::Init(CXGame* game)
{
	std::string actionManifestPath = GetActionManifestPath();
	CryLogAlways("SteamVR action manifest path: %s", actionManifestPath.c_str());
	vr::EVRInputError err = vr::VRInput()->SetActionManifestPath(actionManifestPath.c_str());
	if (err != vr::VRInputError_None)
	{
		CryLogAlways("Failed to load SteamVR action manifest: %i", err);
		return false;
	}

	vr::VRInput()->GetInputSourceHandle("/user/hand/left", &m_handHandle[0]);
	vr::VRInput()->GetInputSourceHandle("/user/hand/right", &m_handHandle[1]);

	vr::VRInput()->GetActionSetHandle("/actions/default", &m_defaultSet);
	vr::VRInput()->GetActionSetHandle("/actions/move", &m_moveSet);
	vr::VRInput()->GetActionSetHandle("/actions/vehicles", &m_vehiclesSet);
	vr::VRInput()->GetActionSetHandle("/actions/weapons", &m_weaponsSet);

	vr::VRInput()->GetActionHandle("/actions/default/in/hapticvibration", &m_haptics);
	vr::VRInput()->GetActionHandle("/actions/default/in/HandPoseLeft", &m_handPoses[0]);
	vr::VRInput()->GetActionHandle("/actions/default/in/HandPoseRight", &m_handPoses[1]);
	InitDoubleBindAction(m_defaultMenu, "/actions/default/in/menu");
	InitDoubleBindAction(m_defaultUse, "/actions/default/in/use");
	vr::VRInput()->GetActionHandle("/actions/default/in/binoculars", &m_defaultBinoculars);
	vr::VRInput()->GetActionHandle("/actions/default/in/zoomin", &m_defaultZoomIn);
	vr::VRInput()->GetActionHandle("/actions/default/in/zoomout", &m_defaultZoomOut);

	vr::VRInput()->GetActionHandle("/actions/move/in/move", &m_moveMove);
	vr::VRInput()->GetActionHandle("/actions/move/in/continuousturn", &m_moveTurn);
	vr::VRInput()->GetActionHandle("/actions/move/in/turnleft", &m_moveSnapTurnLeft);
	vr::VRInput()->GetActionHandle("/actions/move/in/turnright", &m_moveSnapTurnRight);
	vr::VRInput()->GetActionHandle("/actions/move/in/sprint", &m_moveSprint);
	vr::VRInput()->GetActionHandle("/actions/move/in/jump", &m_moveJump);
	vr::VRInput()->GetActionHandle("/actions/move/in/crouch", &m_moveCrouch);

	vr::VRInput()->GetActionHandle("/actions/vehicles/in/steer", &m_vehiclesSteer);
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/accelerate", &m_vehiclesAccelerate);
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/brake", &m_vehiclesBrake);
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/attack", &m_vehiclesAttack);
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/changeview", &m_vehiclesChangeView);
	InitDoubleBindAction(m_vehiclesChangeSeat, "/actions/vehicles/in/changeseat");
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/leave", &m_vehiclesLeave);
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/lights", &m_vehiclesLights);

	vr::VRInput()->GetActionHandle("/actions/weapons/in/fire", &m_weaponsFire);
	InitDoubleBindAction(m_weaponsReloadFireMode, "/actions/weapons/in/reload");
	InitDoubleBindAction(m_weaponsNextDrop, "/actions/weapons/in/next");
	vr::VRInput()->GetActionHandle("/actions/weapons/in/grip", &m_weaponsGrip);
	InitDoubleBindAction(m_weaponsGrenades, "/actions/weapons/in/grenades");

	m_pGame = game;

	return true;
}

void VRInput::ProcessInput()
{
	vr::ETrackedControllerRole hand = vr::TrackedControllerRole_RightHand;
	vr::VRInput()->GetDominantHand(&hand);
	if (hand == vr::TrackedControllerRole_RightHand && m_pGame->g_LeftHanded->GetIVal() != 0)
		vr::VRInput()->SetDominantHand(vr::TrackedControllerRole_LeftHand);
	if (hand == vr::TrackedControllerRole_LeftHand && m_pGame->g_LeftHanded->GetIVal() == 0)
		vr::VRInput()->SetDominantHand(vr::TrackedControllerRole_RightHand);

	std::vector<vr::VRActiveActionSet_t> activeSets;
	activeSets.push_back({ m_defaultSet, vr::k_ulInvalidInputValueHandle });
	activeSets.push_back({ m_moveSet, vr::k_ulInvalidInputValueHandle });
	activeSets.push_back({ m_weaponsSet, vr::k_ulInvalidInputValueHandle });
	activeSets.push_back({ m_vehiclesSet, vr::k_ulInvalidInputValueHandle });

	vr::VRInput()->UpdateActionState(&activeSets[0], sizeof(vr::VRActiveActionSet_t), activeSets.size());

	if (!m_pGame->GetClient())
		return;

	HandleDoubleBindAction(m_defaultMenu, &CXClient::TriggerMenu, &CXClient::TriggerScoreBoard);
	if (gVR->vr_snap_turn_amount == 0)
	{
		HandleAnalogAction(m_moveTurn, 0, &CXClient::TriggerTurnLR);
	}
	else
	{
		HandleBooleanAction(m_moveSnapTurnLeft, &CXClient::TriggerSnapTurnLeft, false);
		HandleBooleanAction(m_moveSnapTurnRight, &CXClient::TriggerSnapTurnRight, false);
	}

	CPlayer* player = m_pGame->GetLocalPlayer();
	if (m_pGame->AreBinocularsActive())
		ProcessInputBinoculars();
	else if (player && player->GetVehicle() && player->GetVehicle()->GetType() != VHT_PARAGLIDER)  // paraglider works better with on-foot controls
		ProcessInputInVehicles();
	else
		ProcessInputOnFoot();
}

void VRInput::ProcessInputOnFoot()
{
	int mainHand = m_pGame->g_LeftHanded->GetIVal() != 0 ? 0 : 1;
	int offHand = m_pGame->g_LeftHanded->GetIVal() != 0 ? 1 : 0;
	CPlayer* player = m_pGame->GetLocalPlayer();
	if (player && player->GetSelectedWeapon())
	{
		CWeaponClass* weapon = player->GetSelectedWeapon();
		if (weapon->IsZoomActive() && (!IsHandTouchingHead(mainHand) || !player->IsTwoHandedModeActive()))
		{
			player->GetEntity()->SendScriptEvent(ScriptEvent_ZoomToggle, 2);
		}
		else if (player->IsTwoHandedModeActive() && !weapon->IsZoomActive() && IsHandTouchingHead(mainHand) && weapon->HasActualScope())
		{
			player->GetEntity()->SendScriptEvent(ScriptEvent_ZoomToggle, 1);
		}
	}

	if (player && player->IsWeaponZoomActive())
	{
		HandleBooleanAction(m_defaultZoomIn, &CXClient::TriggerZoomIn, false);
		HandleBooleanAction(m_defaultZoomOut, &CXClient::TriggerZoomOut, false);
	}
	else
	{
		if (IsHandTouchingHead(offHand))
		{
			// if touching head, toggle flashlight or thermal vision
			HandleDoubleBindAction(m_defaultUse, &CXClient::TriggerFlashlight, &CXClient::TriggerItem1, false);
		}
		else
		{
			// otherwise, normal use
			HandleBooleanAction(m_defaultUse.handle, &CXClient::TriggerUse, false);
			m_defaultUse.isPressed = false;
		}
		HandleBooleanAction(m_defaultBinoculars, &CXClient::TriggerItem0, false);
		HandleBooleanAction(m_moveCrouch, &CXClient::TriggerMoveModeSwitch, false);
		HandleBooleanAction(m_moveJump, &CXClient::TriggerJump, false);
		HandleDoubleBindAction(m_weaponsNextDrop, &CXClient::TriggerNextWeapon, &CXClient::TriggerDropWeapon, false);
		HandleDoubleBindAction(m_weaponsGrenades, &CXClient::CycleGrenade, &CXClient::TriggerFireGrenade, false);
		HandleAnalogAction(m_moveMove, 0, &CXClient::TriggerMoveLR);
		HandleAnalogAction(m_moveMove, 1, &CXClient::TriggerMoveFB);
		HandleBooleanAction(m_moveSprint, &CXClient::TriggerRunSprint);
	}

	HandleBooleanAction(m_weaponsFire, &CXClient::TriggerFire0);
	HandleDoubleBindAction(m_weaponsReloadFireMode, &CXClient::TriggerReload, &CXClient::TriggerFireMode, false);
	HandleBooleanAction(m_weaponsGrip, &CXClient::TriggerTwoHandedGrip);
}

void VRInput::ProcessInputInVehicles()
{
	CPlayer* player = m_pGame->GetLocalPlayer();
	CVehicle* vehicle = player->GetVehicle();
	if (vehicle->GetUserInState(CPlayer::PVS_DRIVER) == player)
	{
		HandleAnalogAction(m_vehiclesSteer, 0, &CXClient::TriggerMoveLR);
		HandleBooleanAction(m_vehiclesLights, &CXClient::TriggerFlashlight, false);
		HandleBooleanAction(m_vehiclesAttack, &CXClient::TriggerFire0);

		// combine accelerate/brake to movement value
		float accel = GetFloatValue(m_vehiclesAccelerate);
		float brake = GetFloatValue(m_vehiclesBrake);
		float move = accel - brake;
		m_pGame->GetClient()->TriggerMoveFB(move, XActivationEvent());
	}
	else
	{
		HandleBooleanAction(m_weaponsFire, &CXClient::TriggerFire0);
		HandleDoubleBindAction(m_weaponsReloadFireMode, &CXClient::TriggerReload, &CXClient::TriggerFireMode, false);
		HandleDoubleBindAction(m_weaponsNextDrop, &CXClient::TriggerNextWeapon, &CXClient::TriggerDropWeapon, false);
		HandleBooleanAction(m_weaponsGrip, &CXClient::TriggerTwoHandedGrip);
		HandleDoubleBindAction(m_weaponsGrenades, &CXClient::CycleGrenade, &CXClient::TriggerFireGrenade, false);
	}

	HandleBooleanAction(m_vehiclesLeave, &CXClient::TriggerUse, false);
	HandleBooleanAction(m_vehiclesChangeView, &CXClient::TriggerChangeView, false);
	HandleDoubleBindAction(m_vehiclesChangeSeat, &CXClient::TriggerRunSprint, &CXClient::TriggerFireMode, false);

	// process some of the default actions to prevent them from immediately triggering when exiting the vehicle
	HandleBooleanAction(m_defaultBinoculars, &CXClient::NoOp, false);
	HandleBooleanAction(m_defaultUse.handle, &CXClient::NoOp, false);
	HandleBooleanAction(m_moveCrouch, &CXClient::NoOp, false);
	HandleBooleanAction(m_moveJump, &CXClient::NoOp, false);
	HandleBooleanAction(m_moveSprint, &CXClient::NoOp, false);
}

void VRInput::ProcessInputBinoculars()
{
	HandleBooleanAction(m_defaultUse.handle, &CXClient::TriggerUse, false);
	HandleBooleanAction(m_defaultBinoculars, &CXClient::TriggerItem0, false);
	HandleBooleanAction(m_defaultZoomIn, &CXClient::TriggerZoomIn, false);
	HandleBooleanAction(m_defaultZoomOut, &CXClient::TriggerZoomOut, false);
	HandleAnalogAction(m_moveMove, 0, &CXClient::TriggerMoveLR);
	HandleAnalogAction(m_moveMove, 1, &CXClient::TriggerMoveFB);
}

void VRInput::TriggerHaptics(int hand, float amplitude, float frequency, float duration)
{
	vr::VRInput()->TriggerHapticVibrationAction(m_haptics, 0.f, duration, frequency, amplitude, m_handHandle[hand]);
}

Matrix34 VRInput::GetControllerTransform(int hand)
{
	hand = clamp_tpl(hand, 0, 1);

	vr::InputPoseActionData_t data;
	vr::VRInput()->GetPoseActionDataForNextFrame(m_handPoses[hand], vr::TrackingUniverseSeated, &data, sizeof(data), vr::k_ulInvalidInputValueHandle);

	// the grip pose has a peculiar orientation that we need to fix
	Matrix33 correction = Matrix33::CreateRotationX(gf_PI/2);
	return OpenVRToFarCry(data.pose.mDeviceToAbsoluteTracking) * correction;
}

void VRInput::HandleBooleanAction(vr::VRActionHandle_t actionHandle, TriggerFn trigger, bool continuous)
{
	vr::InputDigitalActionData_t actionData;
	vr::VRInput()->GetDigitalActionData(actionHandle, &actionData, sizeof(vr::InputDigitalActionData_t), vr::k_ulInvalidInputValueHandle);
	if (actionData.bActive && actionData.bState && (continuous || actionData.bChanged))
	{
		(m_pGame->GetClient()->*trigger)(1.f, XActivationEvent());
	}
}

void VRInput::HandleAnalogAction(vr::VRActionHandle_t actionHandle, int axis, TriggerFn trigger)
{
	vr::InputAnalogActionData_t actionData;
	vr::VRInput()->GetAnalogActionData(actionHandle, &actionData, sizeof(vr::InputAnalogActionData_t), vr::k_ulInvalidInputValueHandle);
	if (!actionData.bActive)
		return;

	float value = axis == 0 ? actionData.x : (axis == 1 ? actionData.y : actionData.z);
	(m_pGame->GetClient()->*trigger)(value, XActivationEvent());
}

float VRInput::GetFloatValue(vr::VRActionHandle_t actionHandle, int axis)
{
	vr::InputAnalogActionData_t actionData;
	vr::VRInput()->GetAnalogActionData(actionHandle, &actionData, sizeof(vr::InputAnalogActionData_t), vr::k_ulInvalidInputValueHandle);
	if (!actionData.bActive)
		return 0.f;

	float value = axis == 0 ? actionData.x : (axis == 1 ? actionData.y : actionData.z);
	return value;
}

void VRInput::InitDoubleBindAction(DoubleBindAction& action, const char* actionName)
{
	vr::VRInput()->GetActionHandle(actionName, &action.handle);
}

void VRInput::HandleDoubleBindAction(DoubleBindAction& action, TriggerFn shortPressTrigger, TriggerFn longPressTrigger, bool longContinuous)
{
	vr::InputDigitalActionData_t actionData;
	vr::VRInput()->GetDigitalActionData(action.handle, &actionData, sizeof(vr::InputDigitalActionData_t), vr::k_ulInvalidInputValueHandle);
	if (!actionData.bActive)
	{
		action.isPressed = false;
		action.timeFirstPressed = 0;
		return;
	}

	if (actionData.bState && actionData.bChanged)
	{
		action.isPressed = true;
		action.timeFirstPressed = m_pGame->GetSystem()->GetITimer()->GetAsyncCurTime();
	}

	if (actionData.bState && action.isPressed)
	{
		if (action.timeFirstPressed == 0)
		{
			// long press already active
			if (longContinuous)
				(m_pGame->GetClient()->*longPressTrigger)(1.f, XActivationEvent());
		}
		else
		{
			float delta = m_pGame->GetSystem()->GetITimer()->GetAsyncCurTime() - action.timeFirstPressed;
			if (delta >= gVR->vr_button_long_press_time)
			{
				action.timeFirstPressed = 0;  // mark long press active
				(m_pGame->GetClient()->*longPressTrigger)(1.f, XActivationEvent());
			}
		}
	}

	if (!actionData.bState && action.isPressed)
	{
		if (action.timeFirstPressed != 0)
		{
			// enable short press action on release since long press was not active
			(m_pGame->GetClient()->*shortPressTrigger)(1.f, XActivationEvent());
		}

		action.isPressed = false;
		action.timeFirstPressed = 0;
	}
}

bool VRInput::IsHandTouchingHead(int hand, float radius)
{
	Matrix34 hmdTransform = gVR->GetHmdTransform();
	Vec3 hmdPos = hmdTransform.GetTranslation();
	hmdPos -= hmdTransform.GetForward() * 0.1f; // get a bit closer to the player head's centre
	Matrix34 controllerTransform = gVR->GetControllerTransform(hand);
	Vec3 controllerPos = controllerTransform.GetTranslation();
	return controllerPos.GetDistance(hmdPos) <= radius;
}
