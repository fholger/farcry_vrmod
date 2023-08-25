#pragma once

class CHand
{
public:
	CHand(int handSide, CPlayer* player);
	~CHand();

	void Init();
	void Reset();

	void Update(const Matrix34& controllerTransform);
	void Render(const SRendParams& _RendParams, const Vec3& basePos);

private:
	void HideUpperArms(const char* boneName);
	void HideOtherHand();

	const char* GetHandBone() const;
	const char* GetOtherHandBone() const;

	int m_handSide;
	ICryCharInstance* m_pCharacter;
	CPlayer* m_pPlayer;
	Vec3 m_pos;
	Ang3 m_ang;
};

