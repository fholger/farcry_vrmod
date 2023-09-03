#pragma once

class VRInput;
constexpr uint32_t HAPTIC_STEPS_PER_SEC = 30;
constexpr uint32_t MAX_HAPTIC_STEPS = 3 * HAPTIC_STEPS_PER_SEC;

struct HapticEffect
{
	uint8_t amplitudeSteps[MAX_HAPTIC_STEPS];
	uint32_t numSteps;
};

struct ActiveHapticEffect
{
	HapticEffect* effect = nullptr;
	uint32_t curStep = 0;
	float amplitudeModifier = 1.0f;
};


class VRHaptics
{
public:
	void Init(CXGame* game, VRInput* vrInput);
	void Update();

	void RegisterBHapticsEffect(const char* key, const char* file);

	void TriggerEffect(int hand, const char* effectName, float amplitudeModifier = 1.0f);
	void TriggerBHapticsEffect(const char* key, float intensity = 1.0f, float offsetAngleX = 0, float offsetY = 0);
	void StopEffects(int hand);
	void StopAllEffects();

	void CreateFlatEffect(const char* effectName, float duration, float amplitude, float easeInTime = 0.0f, float easeOutTime = 0.0f);
	void CreateCustomEffect(const char* effectName, float* amplitudes, int count);

private:
	void InitEffects();

	CXGame* m_pGame = nullptr;
	VRInput* m_vrInput = nullptr;

	std::map<std::string, HapticEffect> m_effects;
	std::vector<ActiveHapticEffect> m_activeEffects[2];
	
	float m_nextUpdateTime = 0.0f;
};
