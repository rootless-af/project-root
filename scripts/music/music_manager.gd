extends Node

@export var debug_messages: bool = false;

var current_track: MusicTrack;
var stem_players: Dictionary = {}
var active_stems: Dictionary = {}
@export var master_volume_db: float = 0.0

var active_roots := {
	"normal": 0,
	"water": 0,
	"fire": 0,
	"metal": 0,
	"alien": 0
}

var is_camera_underground: bool = false;

var stem_tweens: Dictionary = {};

@export_group("Track Rotation")
@export var tracks: Array[MusicTrack] = [];
@export var track_min_time: float = 180.0;
@export var track_max_time: float = 300.0;
@export var track_fade_out_beats: float = 4.0;

var track_timer: Timer;
var is_transitioning: bool = false;

func _ready() -> void:
	track_timer = Timer.new();
	track_timer.one_shot = true;
	track_timer.timeout.connect(_on_track_timer_timeout);
	add_child(track_timer);

	_start_random_track();

func _start_random_track() -> void:
	if tracks.is_empty():
		push_warning("[Music Manager] No tracks assigned.");
		return;

	var track: MusicTrack = tracks.pick_random();

	load_track(track);
	_restore_music_state();
	_start_track_timer();

func _start_track_timer() -> void:
	var duration := randf_range(
		track_min_time,
		track_max_time
	);

	track_timer.start(duration);

	if debug_messages:
		print(
			"[Music Manager] Next track in ",
			duration,
			" seconds."
		);

func _on_track_timer_timeout() -> void:
	if is_transitioning:
		return;

	is_transitioning = true;

	await _fade_out_current_track();

	_start_next_random_track();

	is_transitioning = false;

func _start_next_random_track() -> void:
	if tracks.is_empty():
		is_transitioning = false;
		return;

	var next_track: MusicTrack = tracks.pick_random();

	if tracks.size() > 1:
		while next_track == current_track:
			next_track = tracks.pick_random();

	load_track(next_track);
	_restore_music_state();
	_start_track_timer();

func _fade_out_current_track() -> void:
	if current_track == null:
		return;

	var fade_time := _beats_to_seconds(track_fade_out_beats);

	for id in stem_players.keys():
		var player: AudioStreamPlayer = stem_players[id];

		if not is_instance_valid(player):
			continue;

		var tween := create_tween();
		tween.set_trans(Tween.TRANS_SINE);
		tween.set_ease(Tween.EASE_IN_OUT);

		tween.tween_property(
			player,
			"volume_db",
			-80.0,
			fade_time
		);

	await get_tree().create_timer(fade_time).timeout;

func _restore_music_state() -> void:
	# Base music is always active.
	set_stem("base", true);

	# Restore currently active root types.
	for root_type in active_roots.keys():
		if active_roots[root_type] <= 0:
			continue;

		var stem_id := _root_type_to_stem(root_type);

		if stem_id != "":
			set_stem(stem_id, true);

	# Restore underground/overground state.
	if is_camera_underground:
		set_stem("underground", true);
		set_stem("overground", false);
	else:
		set_stem("underground", false);
		set_stem("overground", true);

func load_track(track: MusicTrack) -> void:
	_clear_current_track();
	current_track = track;
	
	if current_track == null:
		return;
	
	for stem in current_track.stems:
		if stem == null:
			continue;
		
		if stem.audio == null:
			push_warning("Music stem '%s' has no audio assigned." % stem.id)
			continue;
		
		var player := AudioStreamPlayer.new();
		
		player.name = "Stem_%s" % stem.id;
		player.stream = stem.audio;
		player.bus = "Music";
		
		add_child(player);
		
		var stem_id := StringName(stem.id)
		
		stem_players[stem_id] = player;
		active_stems[stem_id] = false;
		
		# Start all stems at the same time
		player.volume_db = -80.0;
		player.play();

func _clear_current_track() -> void:
	for player in stem_players.values():
		if is_instance_valid(player):
			player.stop();
			player.queue_free();
	
	stem_players.clear();
	active_stems.clear();
	
	for tween in stem_tweens.values():
		if is_instance_valid(tween):
			tween.kill();
	
	stem_tweens.clear();

func set_stem(id: StringName,enabled:bool) -> void:
	if debug_messages:
		print("[Music Manager] SET STEM: ", id, " enabled = ", enabled);
	
	if not stem_players.has(id):
		push_warning("Music player doesn't have stems for '%s' " % id);
		return;
	
	var player: AudioStreamPlayer = stem_players[id];
	
	if enabled:
		fade_stem_in(id);
	else:
		fade_stem_out(id);


func fade_stem_in(id: StringName) -> void:
	if not stem_players.has(id):
		return;
	
	var player: AudioStreamPlayer = stem_players[id];
	var stem: MusicStem = _get_stem(id);
	
	if stem == null:
		return;
	
	# already active
	if active_stems.get(id,false):
		return;
	
	active_stems[id] = true;
	
	_kill_stem_tween(id);
	
	# make sure player is actually playing
	if not player.playing:
		player.play();
	
	var fade_time := _beats_to_seconds(stem.fade_in_beats);
	var tween := create_tween();
	stem_tweens[id] = tween;
	
	tween.set_trans(Tween.TRANS_SINE);
	tween.set_ease(Tween.EASE_IN_OUT);
	
	tween.tween_property(
		player,
		"volume_db",
		stem.volume_db + master_volume_db,
		fade_time
	);
	
	tween.finished.connect(
		func():
			stem_tweens.erase(id);
	);

func fade_stem_out(id: StringName) -> void:
	if not stem_players.has(id):
		return;
	
	var player: AudioStreamPlayer = stem_players[id]
	var stem: MusicStem = _get_stem(id);
	
	if stem == null:
		return;
	
	# already inactive
	if not active_stems.get(id,false):
		return;
	
	active_stems[id] = false;
	
	_kill_stem_tween(id);
	
	var fade_time := _beats_to_seconds(stem.fade_out_beats);
	
	var tween := create_tween();
	stem_tweens[id] = tween;
	
	tween.set_trans(Tween.TRANS_SINE);
	tween.set_ease(Tween.EASE_IN_OUT);
	
	tween.tween_property(
		player,
		"volume_db",
		-80.0,
		fade_time
	);
	
	tween.finished.connect(
		func():
			stem_tweens.erase(id);
			
			# keep player alive
			# audio will remain synced with other stems
	);

func _get_stem(id: StringName) -> MusicStem:
	if current_track == null:
		return null;
	
	for stem in current_track.stems:
		if stem != null and stem.id == id:
			return stem;
	
	return null;

func _beats_to_seconds(beats: float) -> float:
	if current_track == null:
		return 0.0;
	
	if current_track.bpm <= 0.0: # lol
		return 0.0;

	return beats * (60.0 / current_track.bpm)

"""
func set_stem(id: StringName,enabled:bool) -> void:
	if not stem_players.has(id):
		return;
	
	var player: AudioStreamPlayer = stem_players[id];
	
	if enabled:
		fade_stem_in(id);
	else:
		fade_stem_out(id);
"""

func _kill_stem_tween(id: StringName) -> void:
	if stem_tweens.has(id):
		var tween: Tween = stem_tweens[id];
		
		if is_instance_valid(tween):
			tween.kill();
		
		stem_tweens.erase(id);


# We call this when root starts to grow. We register the roots to avoid trying
# to play the same stem multiple times.
func register_root(root_type: StringName) -> void:
	if debug_messages:
		print("[Music Manager] REGISTER ROOT: ", root_type);
	
	if not active_roots.has(root_type):
		push_warning(
			"Unknwn root type: %s" % root_type
		);
		return;
	
	active_roots[root_type] += 1;
	
	if debug_messages:
		print("[Music Manager] Root count: ", root_type, " = ", active_roots[root_type]);
	
	if active_roots[root_type] == 1:
		var stem_id := _root_type_to_stem(root_type);
		
		if debug_messages:
			print("[Music Manager] Mapped stem: ", stem_id);
		
		if stem_id != "":
			set_stem(stem_id, true);

func unregister_root(root_type: StringName) -> void:
	if not active_roots.has(root_type):
		push_warning(
			"Unknwn root type: %s" % root_type
		);
		return;
	
	active_roots[root_type] = max(
		0,
		active_roots[root_type] - 1
	);
	
	# Only turn of the stem when the last type of that root disappears.
	if active_roots[root_type] == 0:
		var stem_id := _root_type_to_stem(root_type);
		
		if stem_id != "":
			set_stem(stem_id, false);

func _root_type_to_stem(root_type: StringName) -> StringName:
	match root_type:
		"normal":
			return "normal_root";
		"water":
			return "water_root";
		"fire":
			return "fire_root";
		"metal":
			return "metal_root";
		"alien":
			return "alien_root";
	
	return "";

# -- Debug -- 

func enable_all_stems() -> void:
	for id in stem_players.keys():
		set_stem(id, true);

func disable_all_stems() -> void:
	for id in stem_players.keys():
		set_stem(id, false);

func set_master_volume_db(volume_db: float) -> void:
	master_volume_db = volume_db;
	
	for id in stem_players.keys():
		var player: AudioStreamPlayer = stem_players[id];
		var stem: MusicStem = _get_stem(id);
		
		if stem == null:
			continue;
		
		var target_volume := -80.0;
		
		if active_stems.get(id, false):
			target_volume = stem.volume_db + master_volume_db;
		
		player.volume_db = target_volume;

func set_camera_depth(pos_y: float) -> void:
	var underground := is_camera_underground;
	
	if pos_y > 750.0:
		underground = true;
	elif pos_y < 450.0:
		underground = false;
	
	if underground == is_camera_underground:
		return;
	
	is_camera_underground = underground;
	
	if underground:
		set_stem("underground", true);
		set_stem("overground", false);
	else:
		set_stem("underground", false);
		set_stem("overground", true);
