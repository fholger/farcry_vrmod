import sys
import json

def interpolate(t, t0, t1, v0, v1):
    return v0 + (v1 - v0) * (t - t0) / (t1 - t0)

def main():
    if len(sys.argv) < 3:
        print("Usage: haps_to_lua.py <haps_file> <effect_name> [<amplitude_modifier>] [<time_cutoff>]")
        return

    json_file = sys.argv[1]
    effect_name = sys.argv[2]
    amplitude_modifier = float(sys.argv[3]) if len(sys.argv) >= 4 else 1
    time_cutoff = float(sys.argv[4]) if len(sys.argv) >= 5 else 3

    with open(json_file, 'r') as f:
        data = json.load(f)

    amplitude_values = []

    for melody in data["m_vibration"]["m_melodies"]:
        melody_amp_values = []
        for note in melody["m_notes"]:
            keyframes = note["m_hapticEffect"]["m_amplitudeModulation"]["m_keyframes"]

            prev_keyframe = keyframes[0]
            for i in range(1, len(keyframes)):
                curr_keyframe = keyframes[i]
                t0, v0 = prev_keyframe["m_time"], prev_keyframe["m_value"]
                t1, v1 = curr_keyframe["m_time"], curr_keyframe["m_value"]

                for t in range(int(t0 * 30), int(t1 * 30) + 1):
                    interpolated_value = interpolate(t / 30, t0, t1, v0, v1)
                    melody_amp_values.append(interpolated_value)

                prev_keyframe = curr_keyframe
        amplitude_values += [0] * (len(melody_amp_values) - len(amplitude_values))
        for i in range(len(melody_amp_values)):
            amplitude_values[i] += melody_amp_values[i]

    maxIndex = int(time_cutoff * 30)

    print("_amplitudeValues = {")
    for amplitude in amplitude_values[:maxIndex]:
        print(f"  {amplitude * amplitude_modifier},")
    print("};")
    print(f"Game:CreateHapticsEffectCustom(\"{effect_name}\", _amplitudeValues);")

if __name__ == "__main__":
    main()
