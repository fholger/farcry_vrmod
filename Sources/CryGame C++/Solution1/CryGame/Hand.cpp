#include "stdafx.h"
#include "Hand.h"

#include "CryCharAnimationParams.h"
#include "xplayer.h"

CHand::CHand(int handSide, CPlayer* player)
	: m_handSide(handSide)
	, m_pCharacter(nullptr)
	, m_pPlayer(player)
{
}

CHand::~CHand()
{
	Reset();
}

void CHand::Init()
{
	Reset();

	ISystem* pSystem = m_pPlayer->GetGame()->GetSystem();
	const char* handModel = "Objects/Weapons/hands/hands.cgf";

	m_pCharacter = pSystem->GetIAnimationSystem()->MakeCharacter(handModel, ICryCharManager::nHintModelTransient);
	if (m_pCharacter)
	{
		m_pCharacter->ResetAnimations();
		m_pCharacter->SetFlags(m_pCharacter->GetFlags() | CS_FLAG_DRAW_MODEL | CS_FLAG_UPDATE);

		const char* defaultIdle = "Idle11";
		// set keyframe 1
		CryCharAnimationParams ccap;
		ccap.fBlendInTime = 0;
		ccap.fBlendOutTime = 0;
		ccap.nLayerID = 0;
		m_pCharacter->SetAnimationSpeed(1.0f);
		m_pCharacter->SetDefaultIdleAnimation(0,defaultIdle);
		m_pCharacter->StartAnimation(defaultIdle,ccap);
		m_pCharacter->Update();
		m_pCharacter->ForceUpdate(); 
	}
}

void CHand::Reset()
{
	if (m_pCharacter)
	{
		m_pPlayer->GetGame()->GetSystem()->GetI3DEngine()->RemoveCharacter(m_pCharacter);
		m_pCharacter = nullptr;
	}
}

void CHand::Update(const Vec3& pos, const Ang3& angles)
{
}

void CHand::Render(const SRendParams& _RendParams)
{
	if (!m_pCharacter)
		return;

	if (m_pCharacter->GetFlags()&CS_FLAG_DRAW_MODEL)
	{
		SRendParams RendParams      = _RendParams;
		RendParams.vPos             = m_pos;
		RendParams.vAngles          = m_ang;

		m_pCharacter->Draw(RendParams, m_pos);
	}
}
