### AudioManager.gd
## Autoload singleton — handles all game music and sound effects.

extends Node

# --- Audio file paths ---
const PATH_BG       := "res://Assets/Music/1.2 Background music.wav"
const PATH_WALK     := "res://Assets/Music/1.1 walking sounds.wav"
const PATH_COLLECT  := "res://Assets/Music/2. Item Collected.wav"
const PATH_QUIZ     := "res://Assets/Music/3.Quiz Opens.wav"
const PATH_CORRECT  := "res://Assets/Music/4. correct answe.wav"
const PATH_WRONG    := "res://Assets/Music/5. wrong answer.wav"
const PATH_MUSEUM   := "res://Assets/Music/6 Reach museum.wav"
const PATH_FINAL    := "res://Assets/Music/7. Final quiz.wav"
const PATH_COMPLETE := "res://Assets/Music/8.Mission completed.wav"

# --- Players ---
var _bg_player:   AudioStreamPlayer   # looping background music
var _walk_player: AudioStreamPlayer   # looping walking footsteps
var _sfx_player:  AudioStreamPlayer   # one-shot sound effects
var _resume_bg_after_sfx: bool = false
var _duck_tween: Tween = null
var _current_bg_stream: AudioStream = null
const BG_NORMAL_DB  := -8.0
const BG_DUCKED_DB  := -20.0

# Preloaded streams
var _stream_bg:      AudioStream
var _stream_walk:    AudioStream
var _stream_collect: AudioStream
var _stream_quiz:    AudioStream
var _stream_correct: AudioStream
var _stream_wrong:   AudioStream
var _stream_museum:  AudioStream
var _stream_final:   AudioStream
var _stream_complete: AudioStream

func _ready():
	_bg_player   = _make_player(false)
	_walk_player = _make_player(false)
	_sfx_player  = _make_player(false)

	_stream_bg      = _load_stream(PATH_BG)
	_stream_walk    = _load_stream(PATH_WALK)
	_stream_collect = _load_stream(PATH_COLLECT)
	_stream_quiz    = _load_stream(PATH_QUIZ)
	_stream_correct = _load_stream(PATH_CORRECT)
	_stream_wrong   = _load_stream(PATH_WRONG)
	_stream_museum  = _load_stream(PATH_MUSEUM)
	_stream_final   = _load_stream(PATH_FINAL)
	_stream_complete= _load_stream(PATH_COMPLETE)

	# Connect sfx finished signal to resume background after one-shot stings
	_sfx_player.finished.connect(_on_sfx_finished)
	# Loop background by replaying when it finishes
	_bg_player.finished.connect(_on_bg_finished)

	# Start background music immediately
	_play_bg(_stream_bg)

# ---- Public API ----

func start_walking() -> void:
	if _walk_player.playing:
		return
	_walk_player.stream = _stream_walk
	_walk_player.play()

func stop_walking() -> void:
	if _walk_player.playing:
		_walk_player.stop()

func play_item_collected() -> void:
	_play_sfx(_stream_collect)

func play_quiz_opens() -> void:
	_play_sfx(_stream_quiz)

func play_correct() -> void:
	_play_sfx(_stream_correct)

func play_wrong() -> void:
	_play_sfx(_stream_wrong)

func play_reach_museum() -> void:
	# Stop background, play museum sting; _on_sfx_finished resumes background
	_bg_player.stop()
	_sfx_player.stream = _stream_museum
	_sfx_player.play()
	_resume_bg_after_sfx = true

func play_final_quiz() -> void:
	# Switch background music to final quiz loop
	_bg_player.stop()
	_play_bg(_stream_final)

func play_mission_completed() -> void:
	# Play congrats as SFX — bg will be restarted by Museum._ready()
	_bg_player.stop()
	_play_sfx(_stream_complete)

func start_background() -> void:
	# Restart the main background music (called when entering museum scene)
	_sfx_player.stop()
	_play_bg(_stream_bg)

func duck_background() -> void:
	if _duck_tween and _duck_tween.is_running():
		_duck_tween.kill()
	_duck_tween = create_tween()
	_duck_tween.tween_property(_bg_player, "volume_db", BG_DUCKED_DB, 0.4)

func unduck_background() -> void:
	if _duck_tween and _duck_tween.is_running():
		_duck_tween.kill()
	_duck_tween = create_tween()
	_duck_tween.tween_property(_bg_player, "volume_db", BG_NORMAL_DB, 0.4)

# ---- Helpers ----

func _make_player(autoplay: bool) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.autoplay = autoplay
	add_child(p)
	return p

func _load_stream(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: missing file – " + path)
		return null
	return load(path)

func _on_sfx_finished() -> void:
	if _resume_bg_after_sfx:
		_resume_bg_after_sfx = false
		_play_bg(_stream_bg)

func _on_bg_finished() -> void:
	# Restart current background track to loop it
	if _current_bg_stream != null:
		_bg_player.play()

func _play_bg(stream: AudioStream) -> void:
	if stream == null:
		return
	if _duck_tween and _duck_tween.is_running():
		_duck_tween.kill()
	_current_bg_stream = stream
	_bg_player.stream = stream
	_bg_player.volume_db = BG_NORMAL_DB
	_bg_player.play()

func _play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	_sfx_player.stop()
	_sfx_player.stream = stream
	_sfx_player.play()
