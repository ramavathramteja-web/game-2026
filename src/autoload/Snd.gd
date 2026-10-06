extends Node

## Synthesised audio for THE MISSING SUN.
## All clips are generated (see README) - there are no sampled assets in the project.
## Registering this as autoload "Snd".

const TRACKS := {
	"dark": "res://assets/audio/music_dark.wav",
	"l1": "res://assets/audio/music_l1.wav",
	"l2": "res://assets/audio/music_l2.wav",
	"l3": "res://assets/audio/music_l3.wav",
	"l4": "res://assets/audio/music_l4.wav",
	"l5": "res://assets/audio/music_l5.wav",
}

const MUSIC_DB := -11.0

const CLIPS := {
	"torch": "res://assets/audio/sfx_torch.wav",
	"switch": "res://assets/audio/sfx_switch.wav",
	"interact": "res://assets/audio/sfx_interact.wav",
	"step": "res://assets/audio/sfx_step.wav",
	"clue": "res://assets/audio/sfx_clue.wav",
}

const VOICES := 6

var _pool: Array[AudioStreamPlayer] = []
var _streams: Dictionary = {}
var _music: AudioStreamPlayer = null
var _current: String = ""
var _next := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for i in VOICES:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)

	for key in CLIPS.keys():
		var path: String = CLIPS[key]
		if ResourceLoader.exists(path):
			_streams[key] = load(path)

	set_track("dark")

func set_track(key: String) -> void:
	if key == _current:
		return
	_current = key

	if _music != null:
		_music.queue_free()
		_music = null

	var path: String = TRACKS.get(key, "")
	if path == "" or not ResourceLoader.exists(path):
		return

	var stream := load(path)
	if stream is AudioStreamWAV:
		var w := stream as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		# Derive the frame count from get_length(), not from data.size(): Godot's
		# WAV importer may deliver ADPCM, where the byte count is not frames.
		w.loop_end = maxi(0, int(w.get_length() * float(w.mix_rate)) - 1)

	_music = AudioStreamPlayer.new()
	_music.stream = stream
	_music.volume_db = -40.0
	add_child(_music)
	_music.play()
	var tw := create_tween()
	tw.tween_property(_music, "volume_db", MUSIC_DB, 1.4)

## Browsers suspend the AudioContext until a user gesture. Call this from a real
## input event so music can actually start on web.
func unlock_audio() -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus < 0:
		return
	if not AudioServer.is_bus_mute(bus):
		AudioServer.set_bus_mute(bus, false)
	AudioServer.set_bus_volume_db(bus, 0.0)

func sfx(key: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if not _streams.has(key) or _pool.is_empty():
		return
	var p := _pool[_next]
	_next = (_next + 1) % _pool.size()
	p.stream = _streams[key]
	p.volume_db = volume_db
	p.pitch_scale = clampf(pitch, 0.5, 2.0)
	p.play()

func duck(amount_db: float, seconds: float = 1.5) -> void:
	if _music == null:
		return
	var target := MUSIC_DB - absf(amount_db)
	var tween := create_tween()
	tween.tween_property(_music, "volume_db", MUSIC_DB, seconds).from(target)