#include "StdAfx.h"
#include "VRInput.h"

#include "XPlayer.h"

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
	vr::VRInput()->GetActionSetHandle("/actions/weapons", &m_weaponsSet);

	vr::VRInput()->GetActionHandle("/actions/move/in/move", &m_moveMove);
	vr::VRInput()->GetActionHandle("/actions/move/in/continuousturn", &m_moveTurn);
	vr::VRInput()->GetActionHandle("/actions/move/in/sprint", &m_moveSprint);
	vr::VRInput()->GetActionHandle("/actions/move/in/jump", &m_moveJump);
	vr::VRInput()->GetActionHandle("/actions/move/in/crouch", &m_moveCrouch);

	vr::VRInput()->GetActionHandle("/actions/weapons/in/fire", &m_weaponsFire);

	m_pGame = game;
	return true;
}

void VRInput::ProcessInput()
{
	std::vector<vr::VRActiveActionSet_t> activeSets;
	activeSets.push_back({ m_defaultSet, vr::k_ulInvalidInputValueHandle });
	activeSets.push_back({ m_moveSet, vr::k_ulInvalidInputValueHandle });
	activeSets.push_back({ m_weaponsSet, vr::k_ulInvalidInputValueHandle });

	vr::VRInput()->UpdateActionState(&activeSets[0], sizeof(vr::VRActiveActionSet_t), activeSets.size());

	if (!m_pGame->GetClient())
		return;

	HandleAnalogAction(m_moveMove, 0, &CXClient::TriggerMoveLR);
	HandleAnalogAction(m_moveMove, 1, &CXClient::TriggerMoveFB);
	HandleAnalogAction(m_moveTurn, 0, &CXClient::TriggerTurnLR);
	HandleBooleanAction(m_moveSprint, &CXClient::TriggerRunSprint);
	HandleBooleanAction(m_moveCrouch, &CXClient::TriggerMoveModeSwitch, false);
	HandleBooleanAction(m_moveJump, &CXClient::TriggerJump, false);
	HandleBooleanAction(m_weaponsFire, &CXClient::TriggerFire0);
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
