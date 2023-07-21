#pragma once
#include <openvr.h>
#include <sys/stat.h>

class CXGame;

inline bool fileExists(const char* fileName) {
	struct stat buff;
	return (stat(fileName, &buff) == 0);
}

class VRInput
{
private:
	vr::VRActionSetHandle_t m_actionSetFarCry = vr::k_ulInvalidActionSetHandle;
	const char* actionSetFarCryPath = "/actions/farcry";

	vr::VRActionHandle_t m_actionHandle_ACTION_FIRE0 = vr::k_ulInvalidActionHandle;
	const char* actionFarcry_ACTION_FIRE0_Path = "/actions/farcry/in/ACTION_FIRE0";

	vr::VRActiveActionSet_t m_activeActionSet;
	
	CXGame* m_pGame;
public:
	VRInput(CXGame* pGame);
	void ProcessInput();
	
};

