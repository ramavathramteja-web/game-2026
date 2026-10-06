const $ = (s, r = document) => r.querySelector(s);
const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));

const S = {
  screen: null,
  torch: true,
  mouse: { x: 0.5, y: 0.5 },
  smooth: { x: 0.5, y: 0.5 },
  tier: "T2",
  hold: 0,
  holding: false,
  clues: [],
  beat: 1,
  queue: [],
  pending: null,
  busy: false,
  placed: [],
  closed: false
};

const HOLD_MS = 700;
const R = {
  stage: $("#stage"), beam: $("#beam-torch"), bloom: $("#beam-bloom"),
  ret: $("#reticle"), fill: $("#ret-fill"), mark: $("#mark-wall"),
  sw: $("#sw-wall"), lamp: $("#prop-lamp"), door: $("#room-door"),
  sub: $("#subtitle"), subName: $("#sub-name"), subText: $("#sub-text"),
  thought: $("#thought"), placard: $("#placard"),
  pHead: $("#placard-head"), pBody: $("#placard-body"),
  prompt: $("#prompt"), promptText: $("#prompt-text"),
  objText: $("#objective-text"), toasts: $("#toasts"),
  hudTorch: $("#hud-torch"), hudWatch: $("#hud-watch")
};

function show(name) {
  $$(".screen").forEach(s => s.classList.toggle("is-on", s.dataset.screen === name));
  S.screen = name;
  if (name === "stage") requestAnimationFrame(tick);
}

/* ---------- SUBTITLE / THOUGHT ---------- */

let typeTimer = null;

function say(name, text) {
  return new Promise(res => {
    clearTimeout(typeTimer);
    R.sub.classList.add("is-on");
    R.subName.textContent = name || "";
    R.subText.textContent = "";
    R.subText.classList.remove("is-done");
    R.thought.classList.remove("is-on");
    let i = 0;
    const step = () => {
      if (i < text.length) {
        R.subText.textContent += text[i++];
        typeTimer = setTimeout(step, 18 + Math.random() * 26);
      } else {
        R.subText.classList.add("is-done");
        typeTimer = setTimeout(() => { R.sub.classList.remove("is-on"); res(); }, 900 + text.length * 22);
      }
    };
    step();
  });
}

function think(text, hold = 2600) {
  return new Promise(res => {
    R.sub.classList.remove("is-on");
    R.thought.textContent = text;
    R.thought.classList.add("is-on");
    setTimeout(() => { R.thought.classList.remove("is-on"); res(); }, hold);
  });
}

/* ---------- TOASTS / CLUES ---------- */

function toast(id) {
  const c = CONTENT.clues[id];
  if (!c || S.clues.includes(id)) return;
  S.clues.push(id);
  const el = document.createElement("div");
  el.className = "toast";
  el.innerHTML = `<div class="toast-tag">CLUE ${id}</div><div class="toast-title">${c.title}</div>`;
  R.toasts.appendChild(el);
  setTimeout(() => { el.classList.add("out"); setTimeout(() => el.remove(), 500); }, 4200);
  buildNotebook();
}

/* ---------- BEAT SCRIPT ---------- */

function run(steps) {
  S.queue = steps.slice();
  next();
}

function next() {
  if (S.busy) return;
  const step = S.queue.shift();
  if (!step) { S.pending = null; return; }
  S.busy = true;

  switch (step.t) {
    case "thought":
      think(step.s).then(() => { S.busy = false; next(); });
      break;
    case "placard":
      R.pHead.textContent = step.head;
      R.pBody.textContent = step.body;
      R.placard.classList.add("is-on");
      setTimeout(() => { R.placard.classList.remove("is-on"); S.busy = false; next(); }, 4200);
      break;
    case "do":
      S.pending = step.s;
      setObjective(step.s === "throwA" ? "Throw switch A" : "Throw switch B");
      break;
    case "objective":
      setObjective(step.s);
      S.busy = false; next();
      break;
    case "clue":
      toast(step.id);
      S.busy = false; next();
      break;
    case "waitMark":
      S.pending = "mark";
      break;
    case "tape":
      openTape().then(() => { S.busy = false; next(); });
      break;
    case "openConnect":
      openNotebook("connect");
      S.busy = false; next();
      break;
    case "waitConnect":
      S.pending = "connect";
      break;
  }
}

function setObjective(t) { R.objText.textContent = t; }

function resolvePending(name) {
  if (S.pending !== name) return false;
  S.pending = null;
  S.busy = false;
  next();
  return true;
}

/* ---------- STAGE / TORCH ---------- */

function onMove(e) {
  const r = R.stage.getBoundingClientRect();
  S.mouse.x = (e.clientX - r.left) / r.width;
  S.mouse.y = (e.clientY - r.top) / r.height;
}

function tick() {
  if (S.screen !== "stage") return;
  S.smooth.x += (S.mouse.x - S.smooth.x) * 0.16;
  S.smooth.y += (S.mouse.y - S.smooth.y) * 0.16;

  const x = S.smooth.x * 100, y = S.smooth.y * 100;
  R.beam.style.left = x + "%";
  R.beam.style.top = y + "%";
  R.bloom.style.left = x + "%";
  R.bloom.style.top = y + "%";
  R.ret.style.left = x + "%";
  R.ret.style.top = y + "%";

  const dx = x - 50, dy = y - 44;
  const deg = Math.atan2(dx, -dy) * 180 / Math.PI;
  R.beam.style.transform = `rotate(${deg}deg)`;
  R.bloom.style.transform = `translate(-50%,-50%)`;

  const ang = ((deg % 360) + 360) % 360;
  const centred = ang > 62 || ang < 298;
  R.beam.style.opacity = S.torch && centred ? "1" : "0";
  R.bloom.style.opacity = S.torch && centred ? "1" : "0";

  const m = R.mark.getBoundingClientRect();
  const sr = R.stage.getBoundingClientRect();
  const mx = (m.left + m.width / 2 - sr.left) / sr.width;
  const my = (m.top + m.height / 2 - sr.top) / sr.height;
  const dist = Math.hypot(S.smooth.x - mx, S.smooth.y - my);

  const onMark = dist < 0.055;
  const lit = S.torch && onMark;
  R.mark.classList.toggle("is-lit", lit);

  const tier = S.torch ? (onMark ? "T3" : "T2") : "T1";
  if (tier !== S.tier) {
    S.tier = tier;
    R.ret.className = "reticle " + tier.toLowerCase();
    $("#ret-tier").textContent = tier;
  }

  if (lit) {
    S.hold += 1000 / 60;
    const p = Math.min(1, S.hold / HOLD_MS);
    R.fill.style.strokeDashoffset = String(163.4 * (1 - p));
    R.mark.classList.add("is-locked");
    if (S.hold >= HOLD_MS) {
      S.hold = 0;
      R.fill.style.strokeDashoffset = "163.4";
      revealSunwriting();
    }
  } else if (S.hold > 0) {
    S.hold = Math.max(0, S.hold - 900 / 60 * 0.016);
    R.fill.style.strokeDashoffset = String(163.4 * (1 - S.hold / HOLD_MS));
  }

  R.hudWatch.classList.toggle("is-shown", !S.torch);
  requestAnimationFrame(tick);
}

function revealSunwriting() {
  if (R.sw.classList.contains("is-shown")) return;
  R.sw.textContent = "9:14";
  R.sw.classList.add("is-shown");
  R.mark.classList.remove("is-locked");
  R.lamp.classList.add("is-lit");
  setTimeout(() => run(CONTENT.beats.reveal), 700);
}

function toggleTorch() {
  S.torch = !S.torch;
  R.hudTorch.dataset.on = String(S.torch);
  R.beam.classList.toggle("is-on", S.torch);
  R.bloom.classList.toggle("is-on", S.torch);
}

/* ---------- SWITCHES ---------- */

$$(".switch").forEach(sw => {
  sw.addEventListener("click", e => {
    e.stopPropagation();
    const k = sw.dataset.switch;
    if (sw.classList.contains("is-thrown")) return;
    sw.classList.add("is-thrown");
    if (resolvePending("throw" + k)) return;
    if (k === "C" || k === "D") think("C. Of course C. Nobody has ever needed C.", 2200);
  });
});

/* ---------- NOTEBOOK ---------- */

function openNotebook(tab) {
  buildNotebook();
  if (tab) selectTab(tab);
  show("notebook");
}

function closeNotebook() {
  show("stage");
  if (S.pending === "connect") return;
}

function selectTab(name) {
  $$(".nb-tab").forEach(t => t.classList.toggle("is-on", t.dataset.tab === name));
  $$(".nb-pane").forEach(p => p.classList.toggle("is-on", p.dataset.pane === name));
}

$$(".nb-tab").forEach(t => t.addEventListener("click", () => selectTab(t.dataset.tab)));
$("#nb-close").addEventListener("click", closeNotebook);

function buildNotebook() {
  const list = $("#nb-clues");
  const ids = S.clues.slice().reverse();
  list.innerHTML = ids.length ? "" : `<div class="nb-detail-empty" style="padding:24px">Nothing found yet.</div>`;
  ids.forEach(id => {
    const c = CONTENT.clues[id];
    const row = document.createElement("div");
    row.className = "nb-row";
    row.dataset.id = id;
    row.innerHTML = `<div class="nb-row-id">${id}</div>
      <div><div class="nb-row-t">${c.title}</div>
      <div class="nb-row-s">${c.tag} · BEAT ${c.beat}</div></div>`;
    row.addEventListener("click", () => {
      $$(".nb-row").forEach(r => r.classList.remove("is-on"));
      row.classList.add("is-on");
      $("#nb-detail").innerHTML = `
        <div class="nd-tag">CLUE ${id} · ${c.tag}</div>
        <div class="nd-title">${c.title}</div>
        ${c.quote ? `<div class="nd-quote">${c.quote}</div>` : ""}
        <div class="nd-field"><div class="nd-k">WHERE</div><div class="nd-v">${c.where}</div></div>
        <div class="nd-field"><div class="nd-k">WHAT IT MEANS</div><div class="nd-v">${c.means}</div></div>
        <div class="nd-field"><div class="nd-k">WHO REACTS</div><div class="nd-v">${c.reacts}</div></div>
        <div class="nd-field"><div class="nd-k">WHAT IT UNLOCKS</div><div class="nd-v">${c.unlocks}</div></div>`;
    });
    list.appendChild(row);
  });

  $("#nb-count-clues").textContent = S.clues.length;

  const known = new Set(S.clues.map(id => id[0]));
  const people = CONTENT.people;
  const show = [];
  if (known.has("S")) show.push("moon", "wick", "sir");
  if (known.has("C")) show.push("clouds");
  if (known.has("V")) show.push("marlow");
  if (known.has("F") || known.has("N")) show.push("lumen");
  if (show.length < 6) show.push("locked");

  $("#nb-people").innerHTML = show.map(k => {
    const p = people[k];
    return `<div class="p-card ${p.lock ? "is-locked" : ""}">
      <div class="p-name">${p.name}</div>
      <div class="p-role">${p.role}</div>
      <div class="p-say">${p.say}</div></div>`;
  }).join("");
  $("#nb-count-people").textContent = Math.min(6, show.filter(k => k !== "locked").length);

  $("#nb-know").innerHTML = CONTENT.know
    .filter((_, i) => (i === 0 && S.clues.includes("I-06")) || i === 1)
    .map(k => `<div class="know-line ${k.glow ? "glow" : ""}">${k.text}</div>`).join("");
}

/* ---------- CONNECT ---------- */

function buildChips() {
  const box = $("#conn-chips");
  box.innerHTML = "";
  CONTENT.chips.forEach(ch => {
    const el = document.createElement("div");
    el.className = "chip";
    el.dataset.id = ch.id;
    el.textContent = ch.label;
    box.appendChild(el);
  });
}

function initDrag() {
  let drag = null;
  $("#conn-chips").addEventListener("pointerdown", e => {
    const chip = e.target.closest(".chip");
    if (!chip) return;
    drag = chip;
    chip.classList.add("is-drag");
    chip.setPointerCapture(e.pointerId);
  });
  document.addEventListener("pointermove", e => {
    if (!drag) return;
    drag.style.transform = `translate(${e.clientX - drag.offsetLeft - drag.offsetWidth / 2}px,
      ${e.clientY - drag.offsetTop - drag.offsetHeight / 2}px) scale(1.06)`;
  });
  document.addEventListener("pointerup", e => {
    if (!drag) return;
    const t = $("#conn-target").getBoundingClientRect();
    const inside = e.clientX > t.left && e.clientX < t.right && e.clientY > t.top && e.clientY < t.bottom;
    const chip = drag;
    drag.style.transform = "";
    chip.classList.remove("is-drag");
    drag = null;
    if (inside) placeChip(chip);
    else chip.style.transform = "";
  });
  const t = $("#conn-target");
  t.addEventListener("pointerenter", () => { if (drag) t.classList.add("is-over"); });
  t.addEventListener("pointerleave", () => t.classList.remove("is-over"));
}

function placeChip(chip) {
  place(CONTENT.chips.find(c => c.id === chip.dataset.id).id, chip);
}

function place(id, chip) {
  if (S.placed.includes(id)) return;
  S.placed.push(id);
  if (chip) chip.classList.add("is-placed");

  const slot = document.createElement("div");
  slot.className = "conn-slot";
  slot.textContent = CONTENT.chips.find(c => c.id === id).label;
  $("#conn-dropped").appendChild(slot);
  $("#conn-count").textContent = S.placed.length + " / 3";

  if (S.placed.length < 2) return;

  const def = CONTENT.chips.find(c => c.id === id);
  const prior = S.placed.length === 2 ? S.placed[0] : null;
  const box = $("#conn-reason");
  box.innerHTML = def.pairs[prior];
  box.classList.add("is-on");

  if (S.placed.length === 3) {
    setTimeout(completeCase, 2400);
  } else {
    setTimeout(() => box.classList.remove("is-on"), 2400);
  }
}

function completeCase() {
  if (S.closed) return;
  S.closed = true;
  const box = $("#conn-reason");
  box.classList.remove("is-on");
  box.classList.add("final");
  box.textContent = "Case closed.";
  setTimeout(() => {
    show("stage");
    endCard();
  }, 2600);
}

function endCard() {
  show("end");
  const host = $("#end-lines");
  host.innerHTML = "";
  CONTENT.endLines.forEach((l, i) => {
    setTimeout(() => {
      const d = document.createElement("div");
      d.textContent = l;
      d.style.opacity = "0";
      d.style.transition = "opacity .9s";
      host.appendChild(d);
      requestAnimationFrame(() => { d.style.opacity = "1"; });
    }, 700 + i * 900);
  });
}

/* ---------- TAPE ---------- */

function openTape() {
  return new Promise(res => {
    show("tape");
    const body = $("#tape-body");
    body.innerHTML = "";
    CONTENT.tape.split("\n").forEach((line, i) => {
      setTimeout(() => {
        const d = document.createElement("div");
        d.textContent = line || " ";
        body.appendChild(d);
      }, 500 + i * 620);
    });
  });
}

$("#tape-close").addEventListener("click", () => show("stage"));
$("#screen-tape").addEventListener("click", e => { if (e.target === e.currentTarget) show("stage"); });

/* ---------- GALLERY ---------- */

const GALLERY = [
  { cap: "SUNWRITING · T3", html: `<div class="gal-sw">9:14</div>` },
  { cap: "RAY · INTERNAL MONOLOGUE",
    html: `<div class="gal-sub" style="color:var(--moon);font-style:italic">"A team, A and B. Of course. Why would a thing need a team."</div>` },
  { cap: "SPOKEN · NAMEPLATE",
    html: `<div class="gal-sub"><em>MARLOW</em>I DIDN'T DO IT.</div>` },
  { cap: "LIGHT TIERS", html: `<div class="gal-tiers">
      <span class="gal-tier m">T1 MOONLIGHT</span>
      <span class="gal-tier t">T2 BEAM</span>
      <span class="gal-tier p">T3 AGREED</span></div>` },
  { cap: "HUD · CLOCK + TORCH", html: `<div class="gal-hud">
      <span class="hud-clock">9:14:00</span>
      <span class="hud-torch" data-on="true"><span class="dot"></span><span class="lbl">TORCH</span></span>
      <span class="hud-watch is-shown">9:27<span>:41</span></span></div>` },
  { cap: "CLUE TOAST",
    html: `<div class="gal-toast"><div class="toast-tag">CLUE V-03</div>
      <div class="toast-title">TECH 4 / MARLOW — and CD-19</div></div>` },
  { cap: "NOTECARD · DETAIL",
    html: `<div style="text-align:left">
      <div class="nd-tag">CLUE F-04 · DOCUMENT</div>
      <div class="nd-title" style="font-size:17px;margin-bottom:12px">The access log tape</div>
      <div class="nd-quote" style="font-size:16px;margin:0 0 12px">HELLO, RAY.</div>
      <div class="nd-k">WHO REACTS</div>
      <div class="nd-v" style="font-size:12px">Ray, without flinching.</div></div>` },
  { cap: "WHAT I KNOW · HANDWRITING",
    html: `<div class="know-line glow" style="font-size:30px;margin:0;opacity:1">It was me.</div>` },
  { cap: "CUSTODY TRANSFER · PANEL",
    html: `<div class="gal-sub" style="font-family:var(--mono);font-size:11px;letter-spacing:.14em;color:var(--txt-dim);line-height:2">
      A SHUTDOWN HOLDS ONLY WHILE A CASE IS OPEN.<br>
      IT RELEASES WHEN THE CASE IS CLOSED BY A DETECTIVE<br>WITH NO MEMORY OF CLOSING IT.</div>` },
  { cap: "RETICLE · HOLD STATE",
    html: `<div style="position:relative;width:64px;height:64px">
      <svg viewBox="0 0 64 64" style="transform:rotate(-90deg)">
        <circle cx="32" cy="32" r="26" fill="none" stroke="rgba(190,205,230,.16)" stroke-width="1.5"/>
        <circle cx="32" cy="32" r="26" fill="none" stroke="#d9f2a8" stroke-width="1.5"
          stroke-linecap="round" stroke-dasharray="163.4" stroke-dashoffset="70"
          style="filter:drop-shadow(0 0 5px rgba(217,242,168,.8))"/></svg>
      <span style="position:absolute;left:50%;top:50%;width:5px;height:5px;margin:-2.5px 0 0 -2.5px;
        border-radius:50%;background:#d9f2a8;box-shadow:0 0 14px #d9f2a8"></span></div>` },
  { cap: "PLACARD · WORLD TEXT",
    html: `<div style="border:1px solid rgba(190,205,230,.1);background:rgba(6,8,14,.82);
      border-radius:3px;padding:20px 24px;text-align:center;width:100%">
      <div class="placard-head" style="margin-bottom:12px">THE MARK</div>
      <div class="placard-body" style="font-size:12px">SUNWRITING IS INVISIBLE UNTIL THE LIGHT IS AGREED UPON. HOLD YOUR BEAM ON THE MARK.</div></div>` },
  { cap: "END CARD", html: `<div style="width:100%;background:#000;padding:26px">
      <div class="end-card" style="margin:0 0 26px;padding:22px 26px">
        <div class="end-card-head" style="margin-bottom:14px">LOG ENTRY 914</div>
        <div class="end-card-line" style="font-size:10px">LINE 12 …</div>
        <div class="end-card-black"></div></div>
      <div class="end-time" style="font-size:30px">9:13:41</div></div>` }
];

function openGallery() {
  $("#gal-body").innerHTML = GALLERY.map(g =>
    `<div class="gal-item"><div class="gal-cap">${g.cap}</div>
     <div class="gal-stage">${g.html}</div></div>`).join("");
  show("gallery");
}

$("#btn-gallery-title").addEventListener("click", openGallery);
$("#gal-close").addEventListener("click", () => show(S.closed ? "end" : S.screen === "title" ? "title" : "stage"));

/* ---------- INPUT ---------- */

document.addEventListener("mousemove", e => { if (S.screen === "stage") onMove(e); });

document.addEventListener("keydown", e => {
  const k = e.key.toLowerCase();
  if (k === "f" && S.screen === "stage") toggleTorch();
  if (k === "g" && S.screen !== "gallery") { S.wasScreen = S.screen; openGallery(); }
  if (k === "escape") {
    if (S.screen === "gallery") { $("#gal-close").click(); return; }
    if (S.screen === "notebook") { closeNotebook(); return; }
    if (S.screen === "tape") { show("stage"); }
  }
  if (k === "tab") {
    e.preventDefault();
    if (S.screen === "stage") openNotebook();
    else if (S.screen === "notebook") closeNotebook();
  }
});

$("#btn-start").addEventListener("click", () => {
  show("stage");
  setObjective("Throw switches A and B");
  setTimeout(() => run(CONTENT.beats[1]), 700);
});

$("#btn-again").addEventListener("click", () => location.reload());

buildChips();
initDrag();
show("title");