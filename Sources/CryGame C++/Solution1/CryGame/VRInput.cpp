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
	vr::VRInput()->GetActionSetHandle("/actions/weapons", &m_weaponsSet);
	vr::VRInput()->GetActionHandle("/actions/weapons/in/fire", &m_weaponsFire);

	m_pGame = game;
	return true;
}

void VRInput::ProcessInput()
{
	std::vector<vr::VRActiveActionSet_t> activeSets;
	activeSets.push_back({ m_defaultSet, vr::k_ulInvalidInputValueHandle });
	activeSets.push_back({ m_weaponsSet, vr::k_ulInvalidInputValueHandle });

	vr::VRInput()->UpdateActionState(&activeSets[0], sizeof(vr::VRActiveActionSet_t), activeSets.size());

	if (m_pGame->GetClient())
	{
		vr::InputDigitalActionData_t actionData;
		vr::VRInput()->GetDigitalActionData(m_weaponsFire, &actionData, sizeof(vr::InputDigitalActionData_t), vr::k_ulInvalidInputValueHandle);
		if (actionData.bActive && actionData.bState)
		{
			m_pGame->GetClient()->TriggerFire0(1.f, XActivationEvent());
		}
	}
}
