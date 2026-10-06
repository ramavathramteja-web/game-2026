# THE MISSING SUN — UI PROTOTYPE

**Zero dependencies. No build step. No Godot. Open `index.html` in any browser and it runs.**

---

## WHAT THIS IS

The complete UI for THE MISSING SUN, built to prove one thing: that the game's core verb works.

The design doc names the project's single fatal risk — *"build `P1b` in isolation, before anything else; if `P1b` is unclear, none of it matters."* `P1b` is the **agreed beam**: you point the torch at a marked surface and hold it still, and hidden writing appears.

**This prototype implements `P1b` for real.** Move the mouse to aim the beam. Put it on the ring-and-dot mark on the far wall and hold for 0.7 seconds. The `9:14` writes itself out in Ray's handwriting, because he has not explained why he is writing it yet.

Everything else here is the shell that a Godot build would inherit verbatim: the HUD, the subtitle system, the clue toasts, the notebook, the drag-to-connect deduction, the access-log tape, the end card.

---

## RUN IT

Double-click `ui/index.html`.

| Input | Action |
|---|---|
| Mouse | Aim the torch |
| `F` | Torch on / off |
| `TAB` | Notebook |
| `G` | UI gallery — every screen and state, without playing |
| `Esc` | Close overlay |

---

## THE FLOW

```
TITLE  →  BEAT 1: the Annex
            ↓  throw switch A  (nothing happens)
            ↓  throw switch B  (the door opens)
            ↓  hold the beam on the mark   ← P1b, the whole point
            ↓  9:14 appears in sunwriting
            ↓  Ray signs page twelve
            ↓  THE ACCESS LOG TAPE      "HELLO, RAY…"
            ↓  CONNECT: drag all three entries onto the switch
            ↓  CASE CLOSED
            ↓  9:13:41
```

---

## THE DESIGN SYSTEM

### Three tiers of dark, three colours

The colour tells you what kind of light you are standing in. Nothing else in the game needs a legend.

| Tier | Colour | What it reveals |
|---|---|---|
| `T1` moonlight | `#9db4d6` cold silver | Silhouettes, mass, movement |
| `T2` beam | `#ffb968` amber | Everything in the cone. Text. `EXAMINE` |
| `T3` agreed beam | `#d9f2a8` phosphor | Sunwriting. Counters, stamps, fingerprints |

T3 is the only colour that appears *nowhere else* in the UI. When the screen turns that green, something is being revealed that was not there before.

### Type

| Use | Stack | Feel |
|---|---|---|
| Titles | heavy grotesk, `-0.035em` | A police case file |
| HUD & labels | 9–10px, `0.22em` tracking | Institutional. Cold. |
| Spoken dialogue | 19px grotesk | Present, unhurried |
| **Ray's inner voice** | italic, silver, in quote marks | He is narrating to himself |
| Notebook & logs | monospace | The system, recording |
| **Ray's handwriting** | `Segoe Script` → cursive | The tell. Also the reveal. |

**The handwriting is load-bearing, not decoration.** Ray's notebook, Marlow's logbook and the access-log tape are all the same hand. One playthrough you will not notice. Two playthroughs it is the whole game.

### Motion

The torch **lags** behind the cursor (`lerp 0.16`). It reads as a hand holding a torch, not a mouse cursor.

Sunwriting has a deliberate four-stage flicker — bloom, dim, bloom, hold — like radium paint finding its stride.

Nothing animates for longer than 1.4s. Nothing bounces. Nothing eases out and back.

### Sunwriting reveal

```css
@keyframes phosIn{
  0%  {opacity:0; filter:blur(6px)}
  14% {opacity:.35; filter:blur(2px)}
  22% {opacity:.1}                      ← the flicker
  30% {opacity:1; filter:blur(0)}
  70% {opacity:1} 100% {opacity:.94}
}
```

---

## THE SCREENS

| Screen | What it is |
|---|---|
| **Title** | `9:14:00` in monospace, breathing amber glow. "BEGIN INVESTIGATION" |
| **Stage** | The mock Annex: door, switch bank, demo lamp, angled mirror, the mark. Beam + bloom + reticle |
| **HUD** | Frozen clock `9:14:00`, torch state, and Ray's wristwatch — **only visible when the torch is off** |
| **Placard** | Diegetic world text. Ray reads tutorial signage aloud |
| **Subtitle** | Spoken lines, typewriter at ~45 cps, amber nameplate |
| **Thought** | Ray's inner voice. Silver, italic, lower third, no nameplate |
| **Clue toast** | Slides in right, 2px amber edge, tags the clue ID |
| **Notebook** | Four tabs: CLUES (list + detail pane) · PEOPLE (suspect cards) · WHAT I KNOW (handwriting) · CONNECT |
| **Tape** | Full-screen access log in Ray's handwriting. The reveal |
| **End card** | `LOG ENTRY 914` — line twelve stays black. `9:13:41` |
| **Gallery** | 12 components, one screen, for review without a playthrough |

---

## THE NOTEBOOK

The design doc killed the string-board: twelve connections is a twenty-minute system, and this game has thirteen minutes.

So there is **one** connection, and it is the ending.

Drag three entries onto the Sun Control switch. Two entries give Ray a partial reading. All three closes the case.

```
SIGNATURE · CD-19      +  HANDWRITING · MINE
  "A signature and my handwriting. That's not a coincidence, that's a policy."

HANDWRITING · MINE     +  COUNTER · 2
  "I knew about one of these. I wrote down one of these and then I forgot it."

SIGNATURE · CD-19      +  COUNTER · 2
  "Somebody finished what Marlow started, and they had to sign for it."
```

All three: **Case closed.**

The `WHAT I KNOW` tab writes Ray's three thesis lines in his own hand. The last one is `It was me.` — written by Ray, on screen, thirteen minutes after he forgot writing it.

---

## NO FAIL STATE

There is no wrong answer anywhere in this prototype. Let go of the mark mid-hold and the ring resets silently — no buzz, no penalty, no text. The world's natural state is darkness, so doing nothing is not a failure; it is just more dark.

---

## VALIDATION RUN

```
node test-content.js     18/18 PASS
```

Covers: clue integrity (18 entries, all six required fields), beat-sequence ordering (the T3 hold gates the `I-06` sunwriting), chip pair matrix (every chip has a line for both others), tape content, end-card withholding, and suspect roster.

Also verified: `app.js` and `content.js` pass `node --check`; all 44 DOM selectors in `app.js` resolve against `index.html`; CSS braces balance (249 rules, 1066 declarations).

**One real bug found and fixed during validation:** `$("#tape")` targeted a non-existent id (it is `#screen-tape`). That threw at load and would have killed every script in the file.

---

## WHAT GODOT INHERITS

Direct, 1:1:

- The three-tier colour contract — the single most important thing to port intact
- Subtitle vs. thought as two separate presentation modes
- The clue-card schema (`ID / tag / title / quote / where / means / reacts / unlocks`)
- The drag-connect board and its partial-pair rejection lines
- Sunwriting as a shader/material with the flicker, not a fade
- No-fail interaction policy, written into every spec

---

## NEXT

Port `P1b` into Godot 4.7 as a grey-box test: a wall, a torch, a marked receiver, a 0.7s hold. Nothing else.

If it reads in ten seconds, everything downstream is assembly.