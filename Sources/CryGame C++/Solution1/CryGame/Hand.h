#pragma once

class CHand
{
public:
	CHand(int handSide, CPlayer* player);
	~CHand();

	void Init();
	void Reset();

	void Update(const Vec3& pos, const Ang3& angles);
	void Render(const SRendParams& _RendParams);

private:
	int m_handSide;
	ICryCharInstance* m_pCharacter;
	CPlayer* m_pPlayer;
	Vec3 m_pos;
	Ang3 m_ang;
};

