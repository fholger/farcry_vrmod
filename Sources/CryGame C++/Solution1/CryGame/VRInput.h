#pragma once
#include <openvr.h>
#undef GetUserName

class VRInput
{
public:
	bool Init(CXGame* game);

	void ProcessInput();

private:
	CXGame* m_pGame = nullptr;

	vr::VRActionSetHandle_t m_defaultSet = vr::k_ulInvalidActionSetHandle;
	vr::VRActionSetHandle_t m_weaponsSet = vr::k_ulInvalidActionSetHandle;

	vr::VRActionHandle_t m_weaponsFire = vr::k_ulInvalidActionHandle;
};
