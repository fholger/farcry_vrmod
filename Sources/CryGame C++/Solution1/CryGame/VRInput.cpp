#include "StdAfx.h"
#include "VRInput.h"

#include "VRManager.h"
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

	vr::VRInput()->GetActionSetHandle("/actions/default", &m_defaultSet);
	vr::VRInput()->GetActionSetHandle("/actions/move", &m_moveSet);
	vr::VRInput()->GetActionSetHandle("/actions/vehicles", &m_vehiclesSet);
	vr::VRInput()->GetActionSetHandle("/actions/weapons", &m_weaponsSet);

	vr::VRInput()->GetActionHandle("/actions/default/in/HandPoseLeft", &m_handPoses[0]);
	vr::VRInput()->GetActionHandle("/actions/default/in/HandPoseRight", &m_handPoses[1]);
	vr::VRInput()->GetActionHandle("/actions/default/in/menu", &m_defaultMenu);
	vr::VRInput()->GetActionHandle("/actions/default/in/use", &m_defaultUse);
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
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/changeseat", &m_vehiclesChangeSeat);
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/leave", &m_vehiclesLeave);
	vr::VRInput()->GetActionHandle("/actions/vehicles/in/lights", &m_vehiclesLights);

	vr::VRInput()->GetActionHandle("/actions/weapons/in/fire", &m_weaponsFire);
	vr::VRInput()->GetActionHandle("/actions/weapons/in/reload", &m_weaponsReload);
	vr::VRInput()->GetActionHandle("/actions/weapons/in/aim", &m_weaponsAim);
	vr::VRInput()->GetActionHandle("/actions/weapons/in/firemode", &m_weaponsFireMode);
	vr::VRInput()->GetActionHandle("/actions/weapons/in/next", &m_weaponsNextWeapon);
	vr::VRInput()->GetActionHandle("/actions/weapons/in/prev", &m_weaponsPrevWeapon);
	vr::VRInput()->GetActionHandle("/actions/weapons/in/grip", &m_weaponsGrip);

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

	HandleBooleanAction(m_defaultMenu, &CXClient::TriggerMenu, false);
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
	else if (player && player->GetVehicle())
		ProcessInputInVehicles();
	else
		ProcessInputOnFoot();
}

void VRInput::ProcessInputOnFoot()
{
	HandleBooleanAction(m_defaultUse, &CXClient::TriggerUse, false);
	HandleBooleanAction(m_defaultBinoculars, &CXClient::TriggerItem0, false);
	HandleAnalogAction(m_moveMove, 0, &CXClient::TriggerMoveLR);
	HandleAnalogAction(m_moveMove, 1, &CXClient::TriggerMoveFB);
	HandleBooleanAction(m_moveSprint, &CXClient::TriggerRunSprint);
	HandleBooleanAction(m_moveCrouch, &CXClient::TriggerMoveModeSwitch, false);
	HandleBooleanAction(m_moveJump, &CXClient::TriggerJump, false);
	HandleBooleanAction(m_weaponsFire, &CXClient::TriggerFire0);
	HandleBooleanAction(m_weaponsReload, &CXClient::TriggerReload, false);
	HandleBooleanAction(m_weaponsNextWeapon, &CXClient::TriggerNextWeapon, false);
	HandleBooleanAction(m_weaponsPrevWeapon, &CXClient::TriggerPrevWeapon, false);
	HandleBooleanAction(m_weaponsFireMode, &CXClient::TriggerFireMode, false);
	//HandleBooleanAction(m_weaponsAim, &CXClient::TriggerZoomToggle, false);
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
		HandleBooleanAction(m_weaponsReload, &CXClient::TriggerReload, false);
		HandleBooleanAction(m_weaponsNextWeapon, &CXClient::TriggerNextWeapon, false);
		HandleBooleanAction(m_weaponsPrevWeapon, &CXClient::TriggerPrevWeapon, false);
		HandleBooleanAction(m_weaponsFireMode, &CXClient::TriggerFireMode, false);
		HandleBooleanAction(m_weaponsGrip, &CXClient::TriggerTwoHandedGrip);
	}

	HandleBooleanAction(m_vehiclesLeave, &CXClient::TriggerUse, false);
	HandleBooleanAction(m_vehiclesChangeView, &CXClient::TriggerChangeView, false);
	HandleBooleanAction(m_vehiclesChangeSeat, &CXClient::TriggerRunSprint, false); // yep, really...

	// process some of the default actions to prevent them from immediately triggering when exiting the vehicle
	HandleBooleanAction(m_defaultBinoculars, &CXClient::NoOp, false);
	HandleBooleanAction(m_defaultUse, &CXClient::NoOp, false);
	HandleBooleanAction(m_moveCrouch, &CXClient::NoOp, false);
	HandleBooleanAction(m_moveJump, &CXClient::NoOp, false);
	HandleBooleanAction(m_moveSprint, &CXClient::NoOp, false);
}

void VRInput::ProcessInputBinoculars()
{
	HandleBooleanAction(m_defaultUse, &CXClient::TriggerUse, false);
	HandleBooleanAction(m_defaultBinoculars, &CXClient::TriggerItem0, false);
	HandleBooleanAction(m_defaultZoomIn, &CXClient::TriggerZoomIn, false);
	HandleBooleanAction(m_defaultZoomOut, &CXClient::TriggerZoomOut, false);
	HandleAnalogAction(m_moveMove, 0, &CXClient::TriggerMoveLR);
	HandleAnalogAction(m_moveMove, 1, &CXClient::TriggerMoveFB);
}

Matrix34 VRInput::GetControllerTransform(int hand)
{
	hand = clamp_tpl(hand, 0, 1);

	vr::InputPoseActionData_t data;
	vr::VRInput()->GetPoseActionDataForNextFrame(m_handPoses[hand], vr::TrackingUniverseSeated, &data, sizeof(data), vr::k_ulInvalidInputValueHandle);

	// the grip pose has a peculiar orientation that we need to fix
	Matrix33 correction = Matrix33::CreateRotationXYZ(Ang3(0, 0, -gf_PI/2)) * Matrix33::CreateRotationXYZ(Ang3(gf_PI/2, 0, 0));
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
