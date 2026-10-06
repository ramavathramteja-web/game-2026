# THE MISSING SUN — DESIGN INDEX

**Genre:** First-person comedy detective mystery
**View:** 3D, first-person
**Target:** Godot 4.7, game jam, submission 2026-10-06
**Runtime:** **10–15 minutes.** ~13 min target, ~11 min skip-everything, ~15 min investigate-everything.
**Document status:** SOURCE OF TRUTH for the implementation phase. No code. No scenes.

---

## 0. LOCKED DECISIONS

| # | Decision | Value |
|---|---|---|
| 1 | Presentation | 3D first-person |
| 2 | The truth about the Sun | Marlow + Custody Transfer (see `06_...` §9.1) |
| 3 | **Runtime** | **10–15 min. Beat-based, not act-based.** |
| 4 | Scope | Full 7-beat design, hard cut ladder in §13 |
| 5 | Dialogue | ~120 written lines total. Text + VO accents, no full VO |

---

## 1. FILES

| File | Brief section |
|---|---|
| `01_OVERVIEW_STORY_BEATS.md` | §1 Game overview, §2 Synopsis, §3 Beat structure |
| `02_DIALOGUE.md` | §4 Complete dialogue script |
| `03_CLUES_NOTEBOOK.md` | §5 Complete clue list, §6 Notebook design |
| `04_PUZZLES.md` | §7 Puzzle specifications |
| `05_CHARACTERS.md` | §8 Character design |
| `06_TIMELINE_REVEAL_TUTORIAL.md` | §9 Timeline, §10 Final reveal, §11 Tutorial replay meaning |
| `07_OPTIONAL_SCOPE_DURATION.md` | §12 Optional content, §13 Scope control, §14 Final duration |

---

## 2. THE 13-MINUTE SHAPE

Seven **beats**, not seven acts. Each beat is one room, one mechanic, one exchange, one clue.
A beat is *allowed* to be a hallway. A beat is **not allowed** to be a hallway with nothing in it.

| Beat | Location | Budget | Job |
|---|---|---|---|
| 1 | Apprentice Annex | 2:00 | Tutorial. Also the crime scene. |
| 2 | Dark Street | 1:15 | Darkness hides information. |
| 3 | Suspects (Moon / Lamp / Toaster / Clouds) | 2:30 | Establish direction + a real Ray deduction. |
| 4 | Marlow's Workshop | 1:30 | The false solution, then the gut-punch. |
| 5 | Facility Gate | 2:00 | The only real puzzle. |
| 6 | Lamp Vault → Control Room | 2:00 | Reveal. |
| 7 | Annex again → the switch | 1:45 | Payoff. |
| | **Total** | **13:00** | +~2:00 optional = **15:00** ceiling |

Pacing rule: **never a beat over 2:30, never under 0:45.** A new location under 45 seconds feels like a bug.

---

## 3. THE FIVE PILLARS

1. **LIGHT IS EVIDENCE.** Darkness is not atmosphere. It is the tool.
2. **RAY IS THE CULPRIT, BUT NOT A VILLAIN.** Overconfident, occasionally brilliant, and the reason the city still has a morning.
3. **THE TRAIL IS THE LOCK.** Ray built this mystery to release the Sun. The player is the mechanism.
4. **EVERY CLUE IS TRUE.** Only Ray's conclusions are wrong. Beat 4 teaches it; Beat 6 spends it.
5. **THE TUTORIAL IS THE CRIME SCENE.** The player has already walked the crime scene once and signed it.

---

## 4. THE MECHANIC: THREE TIERS OF DARK

The whole game is one readable rule: *a brighter **kind** of light shows a different **kind** of truth.*

| Tier | Source | Reveals | Cannot reveal |
|---|---|---|---|
| **T1 — Moonlight** | The Moon | Silhouettes, mass, movement | Colour, text, faces |
| **T2 — Beam** | Flashlight cone | Everything in the cone. Readable text. **EXAMINE** unlocks | Hidden writing |
| **T3 — Agreed Beam** | Beam held steady ~0.7s on a marked receiver | **Sunwriting.** Hidden ink. Counters, stamps, fingerprints in dust | Anything physically blacked out |

### 4.1 Sunwriting
Phosphorescent ink. Ray's handwriting. Only renders at T3. It is how Ray talks to himself, and it is the entire tutorial-replay payload.

### 4.2 Teaching order — 3 beats, not 5
- **Beat 1** teaches T2 (the beam) and shows T3 **once**, on a number the player does not understand: `9:14`. The game does not explain it. The game never explains it.
- **Beat 5** teaches T3 as an **answer key**. The glyphs are unreadable until the player deliberately agrees light with them.
- **Beat 7** requires the player to reproduce Beat 1's geometry by memory. That is the finale.

### 4.3 Two universal rules
1. **Light is portable.** It bounces off mirrors, water, glass, polished floors.
2. **Light has direction.** Shadows point at where the light *was*. This is a clue-reading tool, never decoration.

### 4.4 Failure policy — JAM-CRITICAL
**There is no fail state. No wrong answers, no timers, no death, no damage, no punishment.**

The world's natural state is darkness, so doing nothing is not a failure — it is just more dark. Every unsolved puzzle produces a **reaction line from a character**, not a reset. This kills the need for fail art, restart logic, and checkpoint stress, and it is thematically true: *you cannot make the dark darker.*

This one decision is what makes 13 minutes achievable in 3 days.

### 4.5 The clock — MUST HAVE, DO NOT CUT
The HUD clock is always on screen and always reads **9:14:00**. Every clock in the world reads 9:14:00.
Ray's wristwatch is the only moving clock in the game, and it is **only visible when the flashlight is off.**

Cheapest, highest-impact worldbuilding beat in the design.

---

## 5. RULES FOR WRITING DIALOGUE

- **Ray never explains the joke.** The comedy is his sincerity.
- **Ray never says "amnesia", "memory", or "trauma" until Beat 7.** He says "soft", "a bit foggy", "I was on a break".
- **No line over two sentences.** If it needs three, it is two lines.
- **Every suspect takes the evidence seriously**, even while lying. Nobody jokes their way out of a question.
- **Total script budget: ~120 lines.** Every line in `02_DIALOGUE.md` is final. Additions are scope debt.
- **Tone:** Beats 1–4 funny → Beat 5 uneasy → Beat 6 serious → Beat 7 serious, then one warm line. **Beat 7 has zero jokes until the last line.**
- **Comedy density:** one joke per ~40 seconds. That is the whole budget.