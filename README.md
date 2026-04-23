# Microstrip Patch Antenna Design at 2.4 GHz (MATLAB)

Simulation of a square microstrip patch antenna for the 2.4 GHz ISM band, using MATLAB Antenna Toolbox. Done as part of an RF/Antenna course at Faculté des Sciences de Bizerte (L2 TIC).

The full design methodology, theory, and results are documented in the included report (`RF.pdf`).

---

## Specs

| Parameter | Value |
|---|---|
| Frequency | 2.400 GHz |
| Substrate | FR4 (εr = 4.65, h = 1.6 mm) |
| Patch | Square, ~26.97 mm × 26.97 mm |
| Feed | Microstrip edge feed, offset 7.5 mm |
| S11 | −11.1 dB |
| Directivity | 7.85 dBi |
| Bandwidth (−10 dB) | ~85 MHz |

---

## Requirements

- MATLAB R2021a or later
- **Antenna Toolbox** (required)

## Usage

Open `Script.m` and run it. The script outputs 8 figures covering S11, impedance, radiation patterns, directivity, and surface current. Console prints the resonance frequency, S11, directivity, and bandwidth.

The fine mesh simulation for radiation takes a few minutes depending on your machine.

---

## Files

```
.
├── Script.m        # Simulation script
├── RF.pdf          # Full project report
└── README.md
```

---

*L2 TIC — Faculté des Sciences de Bizerte, Université de Carthage — January 2026*
