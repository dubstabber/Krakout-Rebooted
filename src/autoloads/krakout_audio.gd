extends Node

const AudioCueCatalogScript := preload("res://src/audio/krakout_audio_cue_catalog.gd")

const DEFAULT_MUSIC_CONTEXT := "main_menu"
const DEFAULT_MUSIC_NAME := "Abnormal"
const SFX_POOL_SIZE := 8
const MIN_VOLUME_DB := -80.0

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _music_enabled := true
var _sfx_enabled := true
var _music_volume := 80
var _sfx_volume := 85
var _current_music_name := ""
var _current_music_context := ""


func _ready() -> void:
	_ensure_players()
	_load_profile_settings()


func _exit_tree() -> void:
	stop_all(true)


func play_music(name: String = DEFAULT_MUSIC_NAME, restart := false) -> bool:
	var did_play := _play_music_name(name, restart)
	if did_play:
		_current_music_context = ""
	return did_play


func play_music_context(context_name: String = DEFAULT_MUSIC_CONTEXT, restart := false) -> bool:
	var music_name := music_name_for_context(context_name)
	if music_name.is_empty():
		push_warning("Unknown Krakout music context: %s" % context_name)
		return false

	var did_play := _play_music_name(music_name, restart)
	if did_play:
		_current_music_context = context_name
	return did_play


func music_name_for_context(context_name: String) -> String:
	return AudioCueCatalogScript.music_name_for_context(context_name)


func current_music_context() -> String:
	return _current_music_context


func _play_music_name(name: String, restart := false) -> bool:
	_ensure_players()
	var path := _music_path(name)
	if path.is_empty():
		push_warning("Unknown Krakout music track: %s" % name)
		return false

	if _current_music_name == name and _music_player.playing and not restart:
		return true

	_current_music_name = name
	if not _music_enabled or _music_volume <= 0:
		_music_player.stop()
		return true

	var stream := load(path) as AudioStream
	if stream == null:
		return false
	_music_player.stream = stream
	_music_player.volume_db = _volume_db(_music_volume)
	_music_player.play()
	return true


func stop_music() -> void:
	_ensure_players()
	_music_player.stop()


func stop_all(clear_streams := false) -> void:
	_ensure_players()
	_music_player.stop()
	if clear_streams:
		_music_player.stream = null

	for player: AudioStreamPlayer in _sfx_players:
		player.stop()
		if clear_streams:
			player.stream = null


func play_sfx(name: String) -> bool:
	_ensure_players()
	if not _sfx_enabled or _sfx_volume <= 0:
		return false

	var stream := _load_sfx_stream(name)
	if stream == null:
		return false

	var player := _next_sfx_player()
	player.stream = stream
	player.volume_db = _volume_db(_sfx_volume)
	player.play()
	return true


func play_sfx_event(event_name: String) -> bool:
	var sfx_name := sfx_name_for_event(event_name)
	if sfx_name.is_empty():
		return false
	return play_sfx(sfx_name)


func sfx_name_for_event(event_name: String) -> String:
	return AudioCueCatalogScript.sfx_name_for_event(event_name)


func has_sfx_event(event_name: String) -> bool:
	return AudioCueCatalogScript.has_sfx_event(event_name)


func apply_profile_settings() -> void:
	_load_profile_settings()
	_apply_volume_settings()


func music_enabled() -> bool:
	return _music_enabled


func set_music_enabled(is_enabled: bool) -> void:
	_music_enabled = is_enabled
	_apply_volume_settings()
	if _music_enabled and not _current_music_name.is_empty():
		_play_music_name(_current_music_name)
	else:
		stop_music()


func sfx_enabled() -> bool:
	return _sfx_enabled


func set_sfx_enabled(is_enabled: bool) -> void:
	_sfx_enabled = is_enabled
	if not _sfx_enabled:
		for player: AudioStreamPlayer in _sfx_players:
			player.stop()


func music_volume() -> int:
	return _music_volume


func set_music_volume(volume: int) -> void:
	_music_volume = clampi(volume, 0, 100)
	_apply_volume_settings()
	if _music_enabled and _music_volume > 0 and not _current_music_name.is_empty() and not _music_player.playing:
		_play_music_name(_current_music_name)


func sfx_volume() -> int:
	return _sfx_volume


func set_sfx_volume(volume: int) -> void:
	_sfx_volume = clampi(volume, 0, 100)
	_apply_volume_settings()


func current_music_name() -> String:
	return _current_music_name


func is_music_playing() -> bool:
	_ensure_players()
	return _music_player.playing


func music_stream_exists(name: String) -> bool:
	return _music_path(name) != ""


func sfx_stream_exists(name: String) -> bool:
	return _sfx_path(name) != ""


func _ensure_players() -> void:
	if _music_player == null:
		_music_player = AudioStreamPlayer.new()
		_music_player.name = "MusicPlayer"
		add_child(_music_player)

	while _sfx_players.size() < SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % (_sfx_players.size() + 1)
		_sfx_players.append(player)
		add_child(player)


func _load_profile_settings() -> void:
	var profile := get_node_or_null("/root/KrakoutProfile")
	if profile == null:
		return

	if profile.has_method("music_enabled"):
		_music_enabled = bool(profile.call("music_enabled"))
	if profile.has_method("sfx_enabled"):
		_sfx_enabled = bool(profile.call("sfx_enabled"))
	if profile.has_method("music_volume"):
		_music_volume = clampi(int(profile.call("music_volume")), 0, 100)
	if profile.has_method("sfx_volume"):
		_sfx_volume = clampi(int(profile.call("sfx_volume")), 0, 100)


func _apply_volume_settings() -> void:
	_ensure_players()
	_music_player.volume_db = _volume_db(_music_volume)
	if not _music_enabled or _music_volume <= 0:
		_music_player.stop()

	for player: AudioStreamPlayer in _sfx_players:
		player.volume_db = _volume_db(_sfx_volume)


func _next_sfx_player() -> AudioStreamPlayer:
	for player: AudioStreamPlayer in _sfx_players:
		if not player.playing:
			return player
	return _sfx_players[0]


func _load_sfx_stream(name: String) -> AudioStream:
	var path := _sfx_path(name)
	if path.is_empty():
		push_warning("Unknown Krakout sound effect: %s" % name)
		return null
	return load(path) as AudioStream


func _music_path(name: String) -> String:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("music_path"):
		return ""
	return String(assets.call("music_path", name))


func _sfx_path(name: String) -> String:
	var assets := get_node_or_null("/root/KrakoutAssets")
	if assets == null or not assets.has_method("sfx_path"):
		return ""
	return String(assets.call("sfx_path", name))


func _volume_db(volume: int) -> float:
	var normalized_volume := clampi(volume, 0, 100)
	if normalized_volume <= 0:
		return MIN_VOLUME_DB
	return linear_to_db(float(normalized_volume) / 100.0)
