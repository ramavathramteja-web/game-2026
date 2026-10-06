# THE MISSING SUN

A first-person comedy mystery. At 9:14:00 the Sun stops — not sets, not clouds over, not an
eclipse — it stops. Every clock in the world freezes. You did it.

The only light left in the city is the one in your hand. Point it at something and that
thing exists. Look away and it's gone.

Built in **Godot 4.7** (Forward+), GDScript, roughly 10–15 minutes.

---

## Running it

Open the project in Godot 4.7 and press F5. The main scene is `src/levels/L1_DarkCity.tscn`.

From a shell:

```
godot --path .
```

The game requires a mouse (it is captured on start) and a GPU with Vulkan support.

## Controls

| Input | Action |
|---|---|
| `W` `A` `S` `D` | Move |
| Mouse | Look |
| `E` | Interact (throw switches, take objects, question suspects) |
| `F` | Toggle torch |
| `Tab` | Notebook — every clue you have, and who said what |
| `G` | Gallery |

Hold your beam steady on a mark to make it reveal itself. That mechanic is the whole game:
several clues will not appear until you hold the light on them.

Actions are registered at runtime in `src/autoload/Game.gd:150` (`_setup_input`), not in
`project.godot`.

## How it fits together

```
project.godot            autoloads: Game (state), Engrave (post FX), Snd (audio),
                             DevShot (dev captures)
src/levels/              Title → L1 DarkCity → L2 SuspectStreet → L3 VillainLair
                             → L4 SunFacility → L5 TheSwitch
src/core/                shared systems: Sign, Surface, Trim, Props, Atmosphere,
                             BeamReceiver, Interactable, GateDoor, Speaker, LogProp, TapeProp
src/player/Player.gd     movement, interaction raycast, torch
src/ui/                  HUD, Notebook, DialogueRunner, Engrave overlay
src/autoload/            Game state machine, engraving pass, dev capture tool
shaders/                 surface (PBR + procedural), engrave (screen pass), nightsky
assets/textures/         CC0 PBR sets — see Credits
design/                  the written design docs the game is built from
ui/                      standalone browser prototype
tests/                   headless regression suites (see below)
```

Levels are almost entirely code-built rather than authored in the editor: each `L*.gd`
constructs its own geometry, lighting and signage on `_ready`.

## Building

Windows desktop build (this is what goes on itch.io):

```
godot --headless --path . --export-release "Windows Desktop" "build/TheMissingSun.exe"
```

Produces `build/TheMissingSun.exe` + `build/TheMissingSun.pck`. The `.pck` must ship
alongside the `.exe` — the build is not self-contained (`binary_format/embed_pck=false`).

The export preset excludes `shots/`, `src/tests/`, `design/`, `ui/` and the repo docs.
`assets/audio` and `assets/textures` are included as imported resources.

To package for upload, zip the exe, the pck and `build/README.txt` together.

Requires the Godot 4.7.2 export templates in
`%APPDATA%\Godot\export_templates\4.7.2.stable\`.

## Tests

Ten headless suites, 196 assertions. Each is a `SceneTree` script:

```
for s in p1b gates notebook interact suspects marlow sky facility ending chain; do
  godot --headless --path . --script "res://src/tests/run_$s.gd"
done
```

Each prints `PASS <description>` per assertion and `<NAME>: ALL PASS` at the end.
`CHAIN` is the useful one for a full sweep — it resolves every gate rule between all five
levels and asserts each level builds exactly one player, HUD, dialogue runner and notebook.

## Credits

All textures are **CC0** from [Poly Haven](https://polyhaven.com):

- `brushed_concrete` — walls
- `concrete_floor_worn_001` — floors
- `wood_planks_dirt` — crates and furniture

All audio is **synthesised from scratch with numpy** — there are no sampled audio assets in
the project. `assets/audio/music_dark.wav` is a 32-second loopable drone (sub A, a fifth, a
breathing minor third, filtered noise, and a sparse clock bell every 8 seconds, because the
premise is a stopped clock). The five SFX are torch click, switch throw, interact, footstep
and clue-found, hooked into `Snd` at the point of action rather than each level.

Everything else — geometry, shaders, code, design — is original.

## Audio notes

`Snd.gd` sets `loop_end` from `get_length() * mix_rate` rather than `data.size()`. That
matters: Godot's WAV importer defaults to IMA-ADPCM, where the byte count is *not* a frame
count — deriving it that way loopsed the track at 6.5s instead of 32s. The imports here are
set to `compress/mode=0` (PCM16) for quality on the drone.

## Dev captures

`src/autoload/DevShot.gd` grabs 1280×720 stills for visual review:

```
godot --audio-driver Dummy --path . -- --scene=res://src/levels/L3_VillainLair.tscn --shot=M3 --look=0.95,-0.02
```

`--look=YAW,PITCH` pins the camera so captures are reproducible, and the tool re-asserts
that transform every frame to cancel the startup mouse delta. Output lands in `shots/`,
which is gitignored.

Note: Godot needs `--audio-driver Dummy` in this environment or a WASAPI error can hang the
process mid-capture.