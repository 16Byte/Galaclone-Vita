# Galaclone

<img width="960" height="544" alt="Galaclone Splash Image" src="https://github.com/user-attachments/assets/bff15637-f33f-4fb0-b798-28514557165a" />

A Galaga-inspired arcade shooter built in Godot 3.5, designed to run on both PC and PS Vita.

Developed by **Player Made Games** as part of an ongoing classic arcade series.

---

## Platform Support

| Platform | Status |
|----------|--------|
| PC (Linux/Windows) | ✅ Supported |
| PS Vita (Homebrew) | ✅ Supported |

---

## PS Vita Requirements

- A hacked PS Vita with HENkaku
- VitaShell for VPK installation
- Built with [SonicMastr's Godot 3.5-rc5 Vita port](https://github.com/SonicMastr/godot-vita)

---

## Controls

### PS Vita
| Input | Action |
|-------|--------|
| Left Analog Stick | Move left / right |
| D-Pad Left / Right | Move left / right |
| L1 / R1 | Move left / right |
| Cross / Square | Shoot |
| Options | Pause |
| Select | Quick menu |

### PC
| Input | Action |
|-------|--------|
| A / D | Move left / right |
| E | Shoot |
| Escape | Pause |
| Tab | Quick menu |

---

## Building

### PC
Open the project in Godot 3.5 and run normally.

### PS Vita
1. Open the project in SonicMastr's Godot 3.5-rc5 Vita build
2. Ensure **Fallback to GLES2** is enabled in Project Settings — the game will crash on boot without it
3. Convert all Live Area assets to 8-bit indexed PNG using ImageMagick:
```bash
magick input.png -dither FloydSteinberg -colors 256 PNG8:output.png
```
4. Assign all live area assets in the export menu in Godot
5. Export as PlayStation Vita (*.vpk)
6. Install the VPK via VitaShell

---

## Development Status

This project is in early development. See [releases](../../releases) for the current build status.

**Implemented:**
- Player ship with movement
- PS Vita and PC input support
- Custom Live Area assets
- Working Godot → VPK export pipeline

**In progress:**
- Projectile firing
- Enemy spawning and behavior
- Collision detection
- Score system
- Game loop

---

## About

Galaclone is part of a classic arcade series by Player Made Games, working through the history of arcade games from Spacewar! to Pac-Man. The series targets both PC and PS Vita as a homebrew platform.

> *"Play on Vita if you have one."*
