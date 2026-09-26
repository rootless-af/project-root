extends Node

@export var debug_messages: bool = false;

var active_players: Array[AudioStreamPlayer] = [];
var active_players_2D: Array[AudioStreamPlayer2D] = [];

var player_shots: Dictionary = {};
var last_played: Dictionary = {};

func play(shot: AudioShot) -> void:
	_play(shot);

func play_at(shot: AudioShot, pos: Vector2) -> void:
	_play(shot,pos);

func _play(shot:AudioShot, pos: Variant = null) -> void:
	if shot == null:
		return;
	
	if shot.audio == null:
		push_warning("
		AudioShot: '%s' has no audio assigned" % shot.id)
		return;
	
	if _is_on_cooldown(shot):
		return;

	if shot.max_instances > 0:
		if _get_active_count(shot) >= shot.max_instances:
			return;
	
	var stream := _get_audio(shot);
	
	if stream == null:
		return;
	
	var player;
	
	if pos == null:
		player = AudioStreamPlayer.new();
	else:
		player = AudioStreamPlayer2D.new();
		player.global_position = pos;
	
	player.name = "Shot_%s" % shot.id;
	player.stream = stream;
	player.volume_db = shot.volume_db;
	player.pitch_scale = _get_pitch(shot);
	player.bus = shot.bus;
	
	add_child(player);
	
	player_shots[player] = shot;
	
	if pos == null:
		active_players.append(player);
	else:
		active_players_2D.append(player);
	
	player.finished.connect(
		func():
			_remove_player(player);
	);
	
	last_played[shot] = Time.get_ticks_msec() / 1000.0;
	
	if debug_messages:
		print(
			"[Audio Shot Manager] Playing: ",
			shot.id,
			" pitch = ",
			player.pitch_scale
		);
	
	player.play();

func _get_audio(shot: AudioShot) -> AudioStream:
	if shot.variations.is_empty():
		return shot.audio;
	
	return shot.variations.pick_random();

func _get_pitch(shot: AudioShot) -> float:
	if not shot.rand_pitch:
		return 1.0;	
	
	if shot.pitch_randomness <= 0.0:
		return 1.0;
	
	return randf_range(
		1.0 - shot.pitch_randomness,
		1.0 + shot.pitch_randomness
	);

func _is_on_cooldown(shot: AudioShot) -> bool:
	if shot.cooldown <= 0.0:
		return false;
	
	if not last_played.has(shot):
		return false;
	
	var now := Time.get_ticks_msec() / 1000.0;
	var last_time: float = last_played[shot];
	
	return now - last_time < shot.cooldown;

func _get_active_count(shot: AudioShot) -> int:
	var count := 0;
	
	for player in active_players:
		if is_instance_valid(player) and player_shots.get(player) == shot:
			if player.stream == shot.audio:
				count += 1;
		
	for player in active_players_2D:
		if is_instance_valid(player) and player_shots.get(player) == shot:
			if player.stream == shot.audio:
				count += 1;
	
	return count;

func _remove_player(player: Node) -> void:
	player_shots.erase(player);
	
	if player is AudioStreamPlayer:
		active_players.erase(player);
	elif player is AudioStreamPlayer2D:
		active_players_2D.erase(player);
	
	if is_instance_valid(player):
		player.queue_free();

func stop_all() -> void:
	for player in active_players:
		if is_instance_valid(player):
			player.stop();
			player.queue_free();
	
	for player in active_players_2D:
		if is_instance_valid(player):
			player.stop();
			player.queue_free();
	
	active_players.clear();
	active_players_2D.clear();
	player_shots.clear();

func set_master_volume_db(volume_db: float) -> void:
	for player in active_players:
		if is_instance_valid(player):
			player.volume_db = volume_db

	for player in active_players_2D:
		if is_instance_valid(player):
			player.volume_db = volume_db	
