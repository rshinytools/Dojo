"""Render Beast Dojo's original combat cues with Python's standard library."""

import argparse
import hashlib
import io
import json
import math
from pathlib import Path
import random
import struct
import wave


DIRECTORY = Path(__file__).resolve().parent
SAMPLE_RATE = 44100
PEAK_DBFS = -3
PCM_PEAK = round(32767 * 10 ** (PEAK_DBFS / 20))


def tone(samples, *, at=0, gain, high, low, sweep, decay, attack=.004, phase=0):
    """Add a damped resonant mode with a short pitch settling curve."""
    start = round(at * SAMPLE_RATE)
    stop = min(len(samples), start + round(decay * 8 * SAMPLE_RATE))
    for i in range(start, stop):
        seconds = (i - start) / SAMPLE_RATE
        settling = sweep * (1 - math.exp(-seconds / sweep))
        cycles = low * seconds + (high - low) * settling
        envelope = min(1, seconds / attack) * math.exp(-seconds / decay)
        samples[i] += gain * envelope * math.sin(math.tau * (cycles + phase))


def texture(samples, *, seed, at=0, gain, low, high, decay, attack=.002):
    """Add a decaying band of seeded noise for cloth, wood and grit."""
    rng = random.Random(seed)
    start = round(at * SAMPLE_RATE)
    stop = min(len(samples), start + round(decay * 8 * SAMPLE_RATE))
    edge, body = 0.0, 0.0
    edge_rate = 1 - math.exp(-math.tau * high / SAMPLE_RATE)
    body_rate = 1 - math.exp(-math.tau * low / SAMPLE_RATE)
    for i in range(start, stop):
        white = 2 * rng.random() - 1
        edge += edge_rate * (white - edge)
        body += body_rate * (white - body)
        seconds = (i - start) / SAMPLE_RATE
        envelope = min(1, seconds / attack) * math.exp(-seconds / decay)
        samples[i] += gain * envelope * (edge - body)


def light(samples):
    tone(samples, gain=.74, high=244, low=126, sweep=.019, decay=.036)
    tone(samples, gain=.18, high=483, low=413, sweep=.020, decay=.024, phase=.14)
    texture(samples, seed=51, gain=.61, low=430, high=2630, decay=.019)
    texture(samples, seed=52, at=.010, gain=.26, low=1050, high=4260, decay=.033, attack=.010)


def heavy(samples):
    tone(samples, gain=.85, high=156, low=72, sweep=.039, decay=.060, attack=.006)
    tone(samples, gain=.49, high=325, low=201, sweep=.024, decay=.043, phase=.19)
    tone(samples, gain=.16, high=708, low=582, sweep=.027, decay=.023)
    texture(samples, seed=70, gain=.70, low=220, high=2510, decay=.047)
    texture(samples, seed=71, at=.031, gain=.18, low=970, high=3810, decay=.044, attack=.022)


def guard(samples):
    texture(samples, seed=91, gain=.72, low=650, high=3640, decay=.027)
    tone(samples, gain=.61, high=448, low=323, sweep=.021, decay=.031)
    tone(samples, gain=.30, high=763, low=684, sweep=.014, decay=.031, phase=.24)
    tone(samples, at=.028, gain=.35, high=220, low=190, sweep=.020, decay=.039)
    texture(samples, seed=92, at=.022, gain=.37, low=245, high=1170, decay=.049, attack=.010)


def parry(samples):
    texture(samples, seed=111, gain=.31, low=1090, high=4870, decay=.025)
    tone(samples, gain=.70, high=858, low=829, sweep=.036, decay=.095, attack=.005)
    tone(samples, gain=.45, high=1709, low=1647, sweep=.031, decay=.062)
    tone(samples, gain=.24, high=2633, low=2517, sweep=.028, decay=.039)
    tone(samples, at=.043, gain=.28, high=1393, low=1347, sweep=.025, decay=.093, attack=.011)
    tone(samples, at=.044, gain=.11, high=2169, low=2087, sweep=.028, decay=.051, attack=.007)


def pulse(samples):
    tone(samples, gain=.31, high=283, low=153, sweep=.024, decay=.033)
    texture(samples, seed=131, gain=.53, low=360, high=2190, decay=.045)
    tone(samples, at=.011, gain=.78, high=131, low=65, sweep=.057, decay=.087, attack=.010)
    tone(samples, at=.015, gain=.34, high=225, low=127, sweep=.050, decay=.067, attack=.012)
    texture(samples, seed=132, at=.032, gain=.42, low=145, high=1040, decay=.088, attack=.023)
    texture(samples, seed=133, at=.070, gain=.20, low=947, high=3320, decay=.073, attack=.033)


def bell(samples):
    texture(samples, seed=151, gain=.17, low=480, high=2180, decay=.015)
    tone(samples, gain=.67, high=603, low=592, sweep=.035, decay=.124, attack=.008)
    tone(samples, gain=.25, high=1282, low=1249, sweep=.031, decay=.084, attack=.005)
    tone(samples, gain=.24, high=1653, low=1627, sweep=.030, decay=.073, attack=.006)
    tone(samples, gain=.13, high=2161, low=2122, sweep=.027, decay=.059, attack=.006)
    tone(samples, gain=.07, high=2942, low=2873, sweep=.027, decay=.043)


CLIPS = (
    ("light-thup", .160, light, "Confirmed light strike or quick counter.", .33),
    ("planted-impact", .250, heavy, "Confirmed heavy strike, strong shove or committed resident attack.", .40),
    ("guard-clack", .205, guard, "Confirmed block.", .34),
    ("parry-chime", .370, parry, "Confirmed timed parry.", .36),
    ("ground-pulse", .350, pulse, "Resolved floor impact from a slam, stamp or trail burst.", .34),
    ("countdown-bell", .410, bell, "Local countdown step or round start.", .24),
)


def pcm(voice, duration):
    samples = [0.0] * round(SAMPLE_RATE * duration)
    voice(samples)
    dc = 0.0
    coefficient = 1 - math.exp(-math.tau * 31 / SAMPLE_RATE)
    tail = round(min(.045, duration * .20) * SAMPLE_RATE)
    last = len(samples) - 1
    for i, amplitude in enumerate(samples):
        dc += coefficient * (amplitude - dc)
        release = min(1, (last - i) / tail)
        samples[i] = math.tanh(amplitude - dc) * release * release * (3 - 2 * release)
    scale = PCM_PEAK / max(abs(sample) for sample in samples)
    return [round(sample * scale) for sample in samples]


def render(samples):
    payload = io.BytesIO()
    with wave.open(payload, "wb") as target:
        target.setparams((1, 2, SAMPLE_RATE, 0, "NONE", "not compressed"))
        target.writeframes(struct.pack(f"<{len(samples)}h", *samples))
    return payload.getvalue()


def validate(data, frames):
    with wave.open(io.BytesIO(data), "rb") as source:
        assert source.getparams()[:5] == (1, 2, SAMPLE_RATE, frames, "NONE")
        samples = struct.unpack(f"<{frames}h", source.readframes(frames))
    assert samples[0] == samples[-1] == 0
    assert max(map(abs, samples)) == PCM_PEAK
    rms = math.sqrt(sum(sample ** 2 for sample in samples) / len(samples))
    rms_dbfs = 20 * math.log10(rms / 32767)
    assert -28 < rms_dbfs < -6
    return round(rms_dbfs, 2)


def package(check):
    manifest = {
        "creator": "Beast Dojo",
        "origin": "Original procedural synthesis in render_combat_audio.py",
        "sample_rate_hz": SAMPLE_RATE,
        "channels": 1,
        "sample_format": "PCM signed 16-bit little-endian",
        "peak_dbfs": PEAK_DBFS,
        "clips": [],
    }
    outputs = {}
    for name, duration, voice, trigger, starting_volume in CLIPS:
        samples = pcm(voice, duration)
        data = render(samples)
        filename = f"{name}.wav"
        outputs[DIRECTORY / filename] = data
        manifest["clips"].append({
            "file": filename,
            "duration_ms": round(duration * 1000),
            "frames": len(samples),
            "rms_dbfs": validate(data, len(samples)),
            "suggested_trigger": trigger,
            "starting_volume": starting_volume,
            "sha256": hashlib.sha256(data).hexdigest(),
        })
    outputs[DIRECTORY / "manifest.json"] = (json.dumps(manifest, indent=2) + "\n").encode()
    for path, contents in outputs.items():
        if check:
            if not path.exists() or path.read_bytes() != contents:
                raise SystemExit(f"Checked-in output differs: {path.name}")
        else:
            path.write_bytes(contents)
    action = "Verified" if check else "Rendered"
    print(f"{action} {len(CLIPS)} clips with mono PCM at {SAMPLE_RATE} Hz and {PEAK_DBFS} dBFS peak.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Verify existing outputs without overwriting them.")
    package(parser.parse_args().check)
