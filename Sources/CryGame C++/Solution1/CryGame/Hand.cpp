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
		m_pCharacter->EnableLastIdleAnimationRestart(0);
		HideOtherHand();
		m_pCharacter->SetFlags(m_pCharacter->GetFlags() | CS_FLAG_DRAW_NEAR);
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

void CHand::Update(const Matrix34& controllerTransform)
{
	if (!m_pCharacter)
		return;

	m_pCharacter->Update();
	m_pCharacter->ForceUpdate();
	m_pCharacter->ForceReskin();
	ICryBone* bone = m_pCharacter->GetBoneByName(GetHandBone());
	Matrix34 gripTransform = ((Matrix34)GetTransposed44(bone->GetAbsoluteMatrix())) * Matrix34::CreateTranslationMat(Vec3(0, -0.1f, -0.018f));

	Matrix34 handTransform = controllerTransform * gripTransform.GetInverted();
	m_pos = handTransform.GetTranslation();
	m_ang = ToAnglesDeg(handTransform);
}

void CHand::Render(const SRendParams& _RendParams, const Vec3& basePos)
{
	if (!m_pCharacter)
		return;

	HideUpperArms(GetHandBone());
	HideUpperArms(GetOtherHandBone());

	if (m_pCharacter->GetFlags()&CS_FLAG_DRAW_MODEL)
	{
		SRendParams RendParams      = _RendParams;
		RendParams.vPos             = m_pos;
		RendParams.vAngles          = m_ang;
		m_pCharacter->Draw(RendParams, basePos);
	}
}

void CHand::HideUpperArms(const char* boneName)
{
	ICryBone* bone = m_pCharacter->GetBoneByName(boneName);

	Vec3 pos = bone->GetAbsoluteMatrix().GetTranslationOLD();

	// scale the parent bones to zero to effectively hide those parts of the arms - we only want to see the hands in VR
	// this will create some weird cut off at the hands, but it is the best we can do in code, without editing all the models
	bone = bone->GetParent();
	for (int i = 0; i < 3 && bone != nullptr; ++i)
	{
		Matrix44& m = const_cast<Matrix44&>(bone->GetAbsoluteMatrix());
		m = Matrix44(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1);
		m.SetTranslationOLD(pos);
		bone = bone->GetParent();
	}
}

void CHand::HideOtherHand()
{
	ICryBone* bone = m_pCharacter->GetBoneByName(GetOtherHandBone());
	if (!bone || !bone->GetParent())
		return;
	bone = bone->GetParent()->GetParent();
	if (!bone)
		return;

	Matrix44 zeroScale(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1);
	bone->DoNotCalculateBoneRelativeMatrix(true);
	Matrix44& boneMatrix = const_cast<Matrix44&>(bone->GetRelativeMatrix());
	boneMatrix = zeroScale;
}

const char* CHand::GetHandBone() const
{
	return m_handSide == 1 ? "Bone03" : "Bone19";
}

const char* CHand::GetOtherHandBone() const
{
	return m_handSide == 1 ? "Bone19" : "Bone03";
}
