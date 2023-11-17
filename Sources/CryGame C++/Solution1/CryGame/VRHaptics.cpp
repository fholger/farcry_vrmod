#include "StdAfx.h"
#include "ICryPak.h"
#include "VRHaptics.h"
#include "VRInput.h"
#include "VRManager.h"
#include <HapticLibrary.h>
#include <protubevr.h>



void VRHaptics::Init(CXGame* game, VRInput* vrInput)
{
	m_pGame = game;
	m_vrInput = vrInput;
	CryLogAlways("Initialised haptics.");
	InitialiseSync("farcryvr", "Far Cry VR");
	InitRifle();
	InitEffects();
}

void VRHaptics::Update()
{
	float curTime = m_pGame->GetSystem()->GetITimer()->GetAsyncCurTime();
	bool update = (m_nextUpdateTime <= curTime);

	for (int hand = 0; hand < 2; ++hand)
	{
		float amplitude = 0.0f;
		for (std::vector<ActiveHapticEffect>::iterator it = m_activeEffects[hand].begin(); it != m_activeEffects[hand].end(); )
		{
			if (it->curStep == it->effect->numSteps)
			{
				it = m_activeEffects[hand].erase(it);
			}
			else
			{
				amplitude += it->effect->amplitudeSteps[it->curStep] / 255.0f * it->amplitudeModifier;
				if (update)
					++it->curStep;
				++it;
			}
		}

		amplitude = clamp_tpl(amplitude * gVR->vr_haptics_effect_strength, 0.0f, 1.0f);
		m_vrInput->TriggerHaptics(hand, amplitude, HAPTIC_STEPS_PER_SEC, 1.0f / HAPTIC_STEPS_PER_SEC);
	}

	if (update || m_nextUpdateTime > curTime + 1.0f / HAPTIC_STEPS_PER_SEC)
	{
		m_nextUpdateTime = curTime + 1.0f / HAPTIC_STEPS_PER_SEC;
	}
}

void VRHaptics::RegisterBHapticsEffect(const char* key, const char* file)
{
	if (IsFeedbackRegistered(key))
	{
		return;
	}

	ICryPak* pak = m_pGame->GetSystem()->GetIPak();
	FILE* f = pak->FOpen(file, "rb");
	if (!f)
	{
		CryLogAlways("BHaptics effect file not found: %s", file);
		return;
	}
	pak->FSeek(f, 0, SEEK_END);
	int size = pak->FTell(f);
	pak->FSeek(f, 0, SEEK_SET);

	char* buffer = new char[size+1];
	pak->FRead(buffer, size, 1, f);
	pak->FClose(f);
	buffer[size] = 0;

	RegisterFeedbackFromTactFile(key, buffer);
	delete[] buffer;
}

void VRHaptics::TriggerEffect(int hand, const char* effectName, float amplitudeModifier)
{
	if (m_activeEffects[hand].size() >= 20)
	{
		// safety measure: limit amount of active effects
		return;
	}

	std::map<std::string, HapticEffect>::iterator it = m_effects.find(effectName);
	if (it == m_effects.end())
		return;

	m_activeEffects[hand].push_back(ActiveHapticEffect{ &it->second, 0, amplitudeModifier });
}

void VRHaptics::TriggerBHapticsEffect(const char* key, float intensity, float offsetAngleX, float offsetY)
{
	SubmitRegisteredWithOption(key, key, intensity, 1.0f, offsetAngleX, offsetY);
}

bool VRHaptics::IsBHapticsEffectPlaying(const char* key) const
{
	return IsPlayingKey(key);
}

void VRHaptics::StopBHapticsEffect(const char* key)
{
	TurnOffKey(key);
}

void VRHaptics::StopEffects(int hand)
{
	m_activeEffects[hand].clear();
	m_vrInput->TriggerHaptics(hand, 0, 0, 0);
}

void VRHaptics::StopAllEffects()
{
	StopEffects(0);
	StopEffects(1);
	TurnOff();
}

void VRHaptics::ProtubeKick(float power, bool twoHanded)
{
	uint8 pw = clamp_tpl(power, 0.f, 1.f) * 255;
	ForceTubeVRChannel channel = twoHanded ? rifle : rifleButt;
	KickChannel(pw, channel);
}

void VRHaptics::ProtubeRumble(float power, float seconds, bool twoHanded)
{
	uint8 pw = clamp_tpl(power, 0.f, 1.f) * 255;
	ForceTubeVRChannel channel = twoHanded ? rifle : rifleButt;
	RumbleChannel(pw, seconds, channel);
}

void VRHaptics::ProtubeShot(float kickPower, float rumblePower, float rumbleSeconds, bool twoHanded)
{
	uint8 kpw = clamp_tpl(kickPower, 0.f, 1.f) * 255;
	uint8 rpw = clamp_tpl(rumblePower, 0.f, 1.f) * 255;
	ForceTubeVRChannel channel = twoHanded ? rifle : rifleButt;
	ShotChannel(kpw, rpw, rumbleSeconds, channel);
}

void VRHaptics::CreateFlatEffect(const char* effectName, float duration, float amplitude, float easeInTime, float easeOutTime)
{
	HapticEffect& effect = m_effects[effectName];

	uint32_t numSteps = duration * HAPTIC_STEPS_PER_SEC;
	effect.numSteps = clamp_tpl<uint32_t>(numSteps, 0, MAX_HAPTIC_STEPS);
	for (uint32_t i = 0; i < effect.numSteps; ++i)
	{
		effect.amplitudeSteps[i] = 255 * amplitude;
	}

	uint32_t easeInSteps = clamp_tpl<uint32_t>(easeInTime * HAPTIC_STEPS_PER_SEC, 0, effect.numSteps);
	for (uint32_t i = 0; i < easeInSteps; ++i)
	{
		effect.amplitudeSteps[i] *= i * 1.0f / easeInSteps;
	}

	uint32_t easeOutSteps = clamp_tpl<uint32_t>(easeOutTime * HAPTIC_STEPS_PER_SEC, 0, effect.numSteps);
	for (uint32_t i = 0; i < easeOutSteps; ++i)
	{
		uint32_t idx = effect.numSteps - 1 - i;
		effect.amplitudeSteps[idx] *= i * 1.0f / easeOutSteps;
	}
}

void VRHaptics::CreateCustomEffect(const char* effectName, float* amplitudes, int count)
{
	HapticEffect& effect = m_effects[effectName];
	effect.numSteps = clamp_tpl<uint32_t>(count, 0, MAX_HAPTIC_STEPS);

	for (int i = 0; i < count; ++i)
	{
		effect.amplitudeSteps[i] = 255 * amplitudes[i];
	}
}

void VRHaptics::InitEffects()
{
}
