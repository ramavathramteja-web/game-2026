# §7 PUZZLE SPECIFICATIONS

**4 puzzle systems. Total player-facing puzzle time: ~5:30 of 13:00.**
Nothing in this game is a "turn on the switch" puzzle. Each one requires the player to look at something.

**Global failure policy (`README` §4.4):** no fail states, no timers, no resets, no death, no damage. Wrong attempts produce a character reaction, never a punishment. Every puzzle below is designed so that *experimenting is the intended path*, not a mistake.

---

## P1 — MODULE 1
**Beat 1 · 0:00–0:20 · the tutorial that is the crime scene**

| | |
|---|---|
| **Goal** | Open the Annex door. |
| **Player observation** | The placard reads: **THROW A AND B.** Four physical switches: A, B, C, D. |
| **Required objects** | Torch, switch bank, door |
| **Interaction sequence** | Read placard → throw **A** → nothing → throw **B** → door grinds open |
| **Correct solution** | A and B, **either order** |
| **Failure behaviour** | A alone: nothing. C or D: nothing, plus `RAY:` *"C. Of course C. Nobody has ever needed C."* Nothing is ever lost. |
| **Why it is a puzzle** | It is not. It is a tutorial, and its only job is to make the player *throw two switches by hand* so that P4 later asks them to do it again from memory in the dark. **The tutorial is the training for the ending.** |
| **Story reward** | Access to the service lift. And a room Ray will return to in Beat 7 without being told why. |

---

## P1b — THE AGREED BEAM
**Beat 1 · 0:20–0:35 · teaches T3 in ten seconds and never explains it**

| | |
|---|---|
| **Goal** | Read the far wall. |
| **Player observation** | The wall has a small circle-and-dot mark on it. Plain light shows nothing. |
| **Required objects** | Torch, marked receiver on the far wall |
| **Interaction sequence** | Placard 3 states the rule: *hold your beam on the mark* → player holds the beam → ~0.7s → sunwriting renders |
| **Rendered text** | `9:14` |
| **Correct solution** | Hold. Stillness is the whole input. |
| **Failure behaviour** | If the player moves off before 0.7s, the reticle resets silently. No text, no buzz. The mark stays there. Players will try again — they always do, because it's a wall that wants something. |
| **Why it is a puzzle** | It teaches the single most important verb in the game (light can be *negotiated*) using a clue the player cannot yet interpret. The player learns a tool and a mystery in the same gesture. |
| **Story reward** | `I-06`. Ray writes `9:14` in his notebook. He does not know why he is writing it. |
| **REPLAY TELL** | On a second playthrough Ray reads it aloud: *"Nine fourteen. I wrote this. This morning. Or — I don't know which."* He stops being funny for one line and moves on. |

---

## P2 — MARLOW'S BEACON
**Beat 4 · 0:25–1:05 · the false solution's evidence, and the gut-punch**

| | |
|---|---|
| **Goal** | Read the counter on Marlow's replica Sun Control switch. |
| **Player observation** | Three things, none of which connect yet: (a) the switch replica on the bench, its face blank; (b) the dead lighthouse beacon above, which lights; (c) a workshop mirror, already angled at the switch. |
| **Why it looks impossible** | The switch's face cannot be read by the torch — it's covered in eleven days of the counter's own grime, and it is **not** a marked receiver. T3 does not work here. The player must get a **different light source** to it. |
| **Required objects** | Rotatable beacon (1 axis), fixed workshop mirror, switch replica |
| **Interaction sequence** | Examine mirror → notice it already faces the switch → look up at the beacon → notice the beacon is pointed at the *city*, not the mirror → swing the beacon |
| **Correct solution** | Rotate the beacon until its beam crosses the mirror and lands on the switch face. Reflection delivers the light. Counter renders. |
| **Rendered at T3** | Counter: **`2`**. Stamps: **`TECH 4 / MARLOW`** (oxidised, faded — old) and, beneath it, **`CD-19`** (sharp, clean — new). |
| **Failure behaviour** | The beam simply misses. Wick/Marlow react. Rotating is free and unlimited. **The player can brute-force this by spinning the beacon for 30 seconds and finding it by luck — that's acceptable and intended.** |
| **Why it is a puzzle** | The player must deduce that the existing mirror means the puzzle was *already solved once by somebody*, and that the missing piece is light, not aim. It teaches rule §4.3.1 (light is portable) as a fact about the world, not a mechanic. |
| **Story reward** | `V-02` + `V-03`. Two events. Ray's own badge. And Marlow's line: *"It won't take my light."* Ray: *"…It took mine."* |
| **The moment** | This is the beat where the game teaches its thesis (Pillar 4) and immediately violates it. Every clue is true; the conclusion is still wrong. |

---

## P3 — THE LIGHT-LOCKED GATE
**Beat 5 · 0:00–1:50 · the game's real puzzle, three chained steps**

### P3a — THE AGREED GLYPHS
| | |
|---|---|
| **Goal** | Read four glyphs on the Facility gate receivers. |
| **Player observation** | Four circular receiver plates. Torch on them shows blank metal. They have a faint ring-and-dot mark in the centre — the same mark as Beat 1's wall. |
| **Required objects** | Torch, four receivers |
| **Interaction sequence** | Torch alone → blank. Hold on receiver 1 → shape renders + number. Repeat ×4. |
| **Rendered** | **① triangle · ② circle · ③ bar · ④ dot** — shapes, not letters |
| **Correct solution** | Hold each of the four until it renders |
| **Failure behaviour** | Silent reset. Re-aim freely. No counter, no score. |
| **Why it is a puzzle** | The player must notice a *pattern from Beat 1* and apply it somewhere new. The mark was never explained; it was just shown. That is the entire "this game respects your memory" contract. |
| **Story reward** | `N-01`. `RAY:` *"Shapes. Not letters. Somebody didn't want this read by anyone who'd recognise the alphabet."* |

### P3b — THE CROWBAR
| | |
|---|---|
| **Goal** | Carry Wick's beam from the street across the service bridge into the Facility vault slit. |
| **Player observation** | Wick's beam points away from the Facility. A **relay mirror** on the bridge is adjustable. A narrow **slit** in the vault wall shows dark. |
| **Required objects** | Wick (fixed), relay mirror (1 axis), vault slit |
| **Interaction sequence** | Rotate the relay mirror → the beam bends → find the angle where the beam enters the slit → a visible light bridge forms |
| **Correct solution** | One axis, one correct angle, wide tolerance (generous — this is not the hard puzzle) |
| **Failure behaviour** | Beam misses the slit. Wick comments. Free to spin. |
| **Story reward** | `N-02`. First time the player *feels* that light is a tool they are carrying, not a cone they are pointing. |

### P3c — FOUR SWITCHES
| | |
|---|---|
| **Goal** | Open the gate. |
| **Player observation** | Four switches on the gate, unlabelled, beside the four receivers. The glyphs from P3a are now in the notebook. |
| **Interaction sequence** | Match glyph → switch → throw, in the order the glyphs numbered |
| **Correct solution** | **Triangle → Circle → Bar → Dot**, in ascending numeric order |
| **Failure behaviour** | **Nothing happens, ever, for any wrong order.** The gate does not lock, does not reset, does not punish. Wick comments if the player has thrown something silly. This is a deliberate design choice: the puzzle is *reading*, not *bruteforce resistance*. |
| **Why it is a puzzle** | It is only a puzzle if the player trusts the glyphs they read in P3a. The gate is the payoff for having done the boring-looking thing first. |
| **Story reward** | The gate opens. A voice from an unlit room: **LUMEN:** *"I'm on. I've always been on."* Beat break. |

---

## P4 — THE RECONSTRUCTION
**Beat 7 · 0:00–0:45 · the ending, and it is a light puzzle**

| | |
|---|---|
| **Goal** | Restore the Annex light path to reveal the rest of Ray's message. |
| **Why the player can solve it** | They solved this exact configuration in Beat 1, by hand, in twenty seconds, and never thought about it again. **This is the only advanced training the game gives, and it was disguised as a tutorial.** |
| **Player observation** | Ray has brought the case to the Annex because the wall is here and the message is here. The room has: the **demo lamp** (docked, `DO NOT USE`), the **swivel mirror** (still at its original angle — `I-05`), and the **switch bank** A/B/C/D. |
| **Required objects** | Demo lamp, swivel mirror (rotatable), switches A and B |
| **Interaction sequence** | Lamp on → beam hits the mirror → beam must reach the **far wall mark** → Ray reads and says the completed line aloud → switches A and B throw → the door that Ray came out of in Beat 1 is still the way he leaves |
| **Correct solution** | Lamp **on**, mirror at its Beat 1 angle (which the player has seen twice and never questioned), **A and B** thrown |
| **Partial configurations** | **Each completed element triggers one memory fragment**, readable and additive. The player can solve it in four separate sittings and get four fifths of Ray's motive. **Partial states are content, not failure.** This is the main reason P4 has no fail state. |
| **Failure behaviour** | None. The room simply stays dark. Ray says nothing, because Ray does not yet understand what he's looking at. |
| **Why it is a puzzle** | It requires the player to reproduce a **spatial arrangement from memory of a scene from twelve minutes ago**, in a dark room, while the character next to them is amnesiac. The mechanic, the memory, and the theme are the same object. |
| **Story reward** | `Z-02`, and M1–M5, and Ray's motive: the restart surge, 9:14 in the morning, a city awake, the Custody Transfer, the apology. Then the notebook connection, then the Sun comes back. |
| **REPLAY TELL** | The mirror never moved between Beat 1 and Beat 7. The player who looks up will realise Ray had *already set it up for himself, twelve minutes before he arrived.* |

---

## §7.1 PUZZLE-TO-TIER MAP

| Puzzle | Teaches / requires | Tier introduced |
|---|---|---|
| P1 | Two switches, a door | — |
| P1b | Agreed beam (T3) | **T3** |
| P2 | Light is portable | Portable |
| P3a | T3 as an **answer key** | **T3 (applied)** |
| P3b | Light is portable, in transit | Portable |
| P3c | Trust your own reading | — |
| P4 | T3 + memory of geometry | **T3 + memory** |

**Nothing else in the game requires a new mechanic.** In a 13-minute game there is room for exactly one verb (point the light) and exactly one modifier (hold it still). Anything a designer wants to add beyond that must be cut elsewhere to pay for it.

---

## §7.2 PUZZLE CUT ORDER (if behind schedule)

1. **P3b — the crowbar.** Reduce the gate to: light bridge is already there, only P3a + P3c remain. Saves ~35s and one mirror object.
2. **P1b — the agreed beam.** Fold the `9:14` reveal into P1 so the wall renders when the door opens. Saves ~15s. **Cost: P4 loses its cleanest replay tell.** Only cut if the T3 hold mechanic is going unstable.
3. **P3c partial-order tolerance.** Never cut the glyphs; cut only the four-to-four matching and make the order simply 1→4 left to right. Saves authoring, not playtime.
4. **P4's three memory triggers → one.** Keep the final throw, drop M1–M3. Saves ~20s. **Last resort — the fragments are the motive.**