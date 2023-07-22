#include <openvr.h>
#include "StdAfx.h"
#include "VRInput.h"
#include "Cry_Camera.h"
#include "xplayer.h"
#include "ComPtr.h"
#include <vulkan/vulkan.h>


VRInput::VRInput(CXGame* pGame) {
	m_pGame = pGame;


	if (!fileExists("C:\\Users\\Tom\\Downloads\\far cry\\farcry_vrmod\\Sources\\CryGame C++\\Solution1\\CryGame\\bindings\\actions.json")) {
		CryError("Action.json not found");
	}

	vr::EVRInputError input_error = vr::VRInput()->SetActionManifestPath(
		"C:\\Users\\Tom\\Downloads\\far cry\\farcry_vrmod\\Sources\\CryGame C++\\Solution1\\CryGame\\bindings\\actions.json"
	);
	if (input_error != vr::VRInputError_None) {
		CryError("Failed to initialize VRInput: %s", input_error);
	}

	input_error = vr::VRInput()->GetActionSetHandle(actionSetFarCryPath, &m_actionSetFarCry);
	if (input_error != vr::EVRInputError::VRInputError_None)
	{
		CryError("GetActionSetHandle error.\n");
	}

	IConsole* console = pGame->GetSystem()->GetIConsole();
	console->PrintLine("VR input initialized");
	auto inputError = vr::VRInput()->GetActionHandle(actionFarcry_ACTION_FIRE0_Path, &m_actionHandle_ACTION_FIRE0);
	if (inputError != vr::VRInputError_None) {
		CryError("Error: Unable to get action handle: %d\n", inputError);
	}

	m_activeActionSet.ulActionSet = m_actionSetFarCry;
	m_activeActionSet.ulRestrictedToDevice = vr::k_ulInvalidInputValueHandle;
	m_activeActionSet.nPriority = 0;
}

void VRInput::ProcessInput() {
	IConsole* console = VRInput::m_pGame->GetSystem()->GetIConsole();

	auto error = vr::VRInput()->UpdateActionState(&m_activeActionSet, sizeof(m_activeActionSet), 1);
	if (error != vr::EVRInputError::VRInputError_None)
	{
		console->PrintLine("error vr input");
		CryError("Error UpdateActionState");
		return;
	}
	vr::InputDigitalActionData_t actionDataStruct;
	vr::VRInput()->GetDigitalActionData(m_actionHandle_ACTION_FIRE0, &actionDataStruct, sizeof(actionDataStruct), vr::k_ulInvalidInputValueHandle);
	if (actionDataStruct.bActive) {
		if (actionDataStruct.bState) {
			CPlayer* player = m_pGame->GetLocalPlayer();
			if (player) {
				CXEntityProcessingCmd tempPC;
				tempPC.AddAction(ACTION_FIRE0);
				player->ProcessWeapons(tempPC);
			}
			
		}
	}
}